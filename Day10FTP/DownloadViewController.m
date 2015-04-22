//
//  DownloadViewController.m
//  Day10FTP
//
//  Created by tarena on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//
#import "AsyncSocket.h"
#import "DownloadViewController.h"
#import "Utils.h"
@interface DownloadViewController ()<AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong)AsyncSocket *clientSocket;
@property (nonatomic, strong)NSMutableData *fileData;
@end

@implementation DownloadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fileData = [NSMutableData data];
    self.clientSocket = [[AsyncSocket alloc]initWithDelegate:self];
#warning 修改ip
    [self.clientSocket connectToHost:@"" onPort:8000 error:nil];
    
    NSString *headerString = [NSString stringWithFormat:@"download&&%@&&",self.downloadFile.name];
    NSMutableData *allData = [Utils getAllDataByHeaderString:headerString];
    [self.clientSocket writeData:allData withTimeout:-1 tag:0];
}
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    
    
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [self.fileData appendData:data];
    
    if (self.fileData.length == self.downloadFile.length) {
#warning 改路径
        NSString *newFilePath = [@"/Users/tarena/Desktop" stringByAppendingPathComponent:self.downloadFile.name];
        [self.fileData writeToFile:newFilePath atomically:YES];
        
    }
    
    [sock readDataWithTimeout:-1 tag:0];
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
