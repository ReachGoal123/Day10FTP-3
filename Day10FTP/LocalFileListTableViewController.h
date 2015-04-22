//
//  LocalFileListTableViewController.h
//  Day10FTP
//
//  Created by tarena on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
@interface LocalFileListTableViewController : UITableViewController<AsyncSocketDelegate>
@property (nonatomic, copy)NSString *direcotryPath;
@end
