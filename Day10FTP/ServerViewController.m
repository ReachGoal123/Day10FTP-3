

//
//  ServerViewController.m
//  Day10FTP
//
//  Created by tarena on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//
#import "Utils.h"
#import "ServerViewController.h"
#import "AsyncSocket.h"
@interface ServerViewController ()<AsyncSocketDelegate>
@property (nonatomic, strong)AsyncSocket *serverSocket;
@property (nonatomic, strong)AsyncSocket *myNewSocket;
@property (nonatomic, copy)NSString *host;
@property (nonatomic, strong)NSMutableData *fileAllData;
@property (nonatomic, copy)NSString *fileName;
@property (nonatomic)int fileLength;
@property (weak, nonatomic) IBOutlet UIProgressView *myProgressView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ServerViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.serverSocket = [[AsyncSocket alloc]initWithDelegate:self];
    [self.serverSocket acceptOnPort:8000 error:nil];
    
}

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    self.myNewSocket = newSocket;
}
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    self.host = host;
    [self.myNewSocket readDataWithTimeout:-1 tag:0];
}
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSData *headerData = [data subdataWithRange:NSMakeRange(0, 100)];
    NSString *headerString = [[NSString alloc]initWithData:headerData encoding:NSUTF8StringEncoding];
    
    if (headerString&&[headerString componentsSeparatedByString:@"&&"].count==3) {
        NSArray *headers = [headerString componentsSeparatedByString:@"&&"];
        NSString *type = headers[0];
        if ([type isEqualToString:@"upload"]) {
            
            self.fileName = headers[1];
            self.fileLength = [headers[2]intValue];
            
            self.statusLabel.text = [NSString stringWithFormat:@"%@正在上传%@文件",self.host,self.fileName];
            self.fileAllData = [NSMutableData data];
            NSData *subFileData = [data subdataWithRange:NSMakeRange(100, data.length-100)];
            
            [self.fileAllData appendData:subFileData];
            //更新PV
            self.myProgressView.progress = self.fileAllData.length*1.0/self.fileLength;
//            判断是否完成
            [self checkingFinish];
            
        }else if ([type isEqualToString:@"getfilelist"]){
               self.statusLabel.text = [NSString stringWithFormat:@"%@获取文件列表",self.host];
            NSData *filesData = [Utils getFilesData];
            
            [self.myNewSocket writeData:filesData withTimeout:-1 tag:0];
            
            
        }else{//下载
            
            NSString *fileName = headers[1];
            self.statusLabel.text = [NSString stringWithFormat:@"%@正在下载%@文件",self.host,fileName];
            NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            
            [self.myNewSocket writeData:fileData withTimeout:-1 tag:0];
            
        }
        
        
        
        
    }else{//不是第一部分
        [self.fileAllData appendData:data];
        //更新PV
        self.myProgressView.progress = self.fileAllData.length*1.0/self.fileLength;
        
        [self checkingFinish];
        
    }
    
    //接续接收数据
    [sock readDataWithTimeout:-1 tag:0];
    
}

-(void)checkingFinish{
    
    if (self.fileAllData.length == self.fileLength) {
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *saveFilePath = [documentsPath stringByAppendingPathComponent:self.fileName];
        [self.fileAllData writeToFile:saveFilePath atomically:YES];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
