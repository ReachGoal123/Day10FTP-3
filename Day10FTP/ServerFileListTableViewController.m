

//
//  ServerFileListTableViewController.m
//  Day10FTP
//
//  Created by tarena on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//
#import "DownloadViewController.h"
#import "ServerFileListTableViewController.h"
#import "AsyncSocket.h"
#import "Utils.h"
#import "File.h"
@interface ServerFileListTableViewController ()<AsyncSocketDelegate>
@property (nonatomic, strong)AsyncSocket *clientSocket;
@property (nonatomic, strong)NSArray *files;
@end

@implementation ServerFileListTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clientSocket = [[AsyncSocket alloc]initWithDelegate:self];
#warning 修改ip
    [self.clientSocket connectToHost:@"" onPort:8000 error:nil];
    
    NSString *headerString = @"getfilelist&& &&";
    NSMutableData *allData = [Utils getAllDataByHeaderString:headerString];
    [self.clientSocket writeData:allData withTimeout:-1 tag:0];
    
    
}
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    self.files = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.files.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    File *file = self.files[indexPath.row];
    
    cell.textLabel.text = file.name;
    
    NSString *size = file.length>1024*1024?[NSString stringWithFormat:@"%dM",file.length/1024/1024]:[NSString stringWithFormat:@"%dkb",file.length/1024];
    cell.detailTextLabel.text = size;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    File *file = self.files[indexPath.row];
    
    [self performSegueWithIdentifier:@"download" sender:file];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DownloadViewController*vc = segue.destinationViewController;
    vc.downloadFile = sender;
}
 

@end
