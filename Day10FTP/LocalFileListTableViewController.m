//
//  LocalFileListTableViewController.m
//  Day10FTP
//
//  Created by tarena on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "LocalFileListTableViewController.h"
#import "Utils.h"
@interface LocalFileListTableViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong)NSMutableArray *filePaths;
@property (nonatomic, strong)AsyncSocket *clientSocket;
@property (nonatomic, copy)NSString *uploadPath;
@end

@implementation LocalFileListTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.filePaths = [NSMutableArray array];
    
    
    if (!self.direcotryPath) {
        self.direcotryPath = @"/Users";
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *fileNames = [fm contentsOfDirectoryAtPath:self.direcotryPath error:nil];
    
    for (NSString *fileName in fileNames) {
        if ([fileName hasPrefix:@"."]) {
            continue;
        }
        NSString *filePath = [self.direcotryPath stringByAppendingPathComponent:fileName];
        [self.filePaths addObject:filePath];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 
    return self.filePaths.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    NSString *filePath = self.filePaths[indexPath.row];
    cell.textLabel.text = [filePath lastPathComponent];
    
    NSString *size = @"";
    if ([self isDirWithPath:filePath]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:filePath];
        int length = (int)[fh seekToEndOfFile];
        
       size = length>1024*1024?[NSString stringWithFormat:@"%dM",length/1024/1024] : [NSString stringWithFormat:@"%dKB",length/1024];
        
    }
    cell.detailTextLabel.text = size;
    
    
    
    
    return cell;
}

-(BOOL)isDirWithPath:(NSString *)path{
    BOOL isDir;
    if ([[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDir]&&isDir) {
        return YES;
    }
    return NO;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *filePath = self.filePaths[indexPath.row];
    if ([self isDirWithPath:filePath]) {
        LocalFileListTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalFileListTableViewController"];
        vc.direcotryPath = filePath;
        [self.navigationController pushViewController:vc animated:YES];
    }else{//点击了文件
        
        self.uploadPath = filePath;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要上传此文件吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1) {
        //上传文件
        
        self.clientSocket = [[AsyncSocket alloc]initWithDelegate:self];
#warning 修改ip
        [self.clientSocket connectToHost:@"对方ip" onPort:8000 error:nil];
        NSData *fileData = [NSData dataWithContentsOfFile:self.uploadPath];
        NSString *headerString = [NSString stringWithFormat:@"upload&&%@&&%d",[self.uploadPath lastPathComponent],fileData.length];
        
        NSMutableData *allData = [Utils getAllDataByHeaderString:headerString];
        [allData appendData:fileData];
        
        [self.clientSocket writeData:allData withTimeout:-1 tag:0];
        
    }
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
