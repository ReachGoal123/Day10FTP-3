//
//  File.h
//  Day10FTP
//
//  Created by tarena on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject<NSCoding>
@property (nonatomic, copy)NSString *name;
@property (nonatomic)int length;
@end
