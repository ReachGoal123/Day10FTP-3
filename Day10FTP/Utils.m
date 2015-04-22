

//
//  Utils.m
//  Day10FTP
//
//  Created by tarena on 15-3-25.
//  Copyright (c) 2015年 tarena. All rights reserved.
//

#import "Utils.h"
#import "File.h"
@implementation Utils
+(NSMutableData *)getAllDataByHeaderString:(NSString *)headerString{
    NSMutableData *allData = [NSMutableData dataWithLength:100];
    NSData *headerData = [headerString dataUsingEncoding:NSUTF8StringEncoding];
    [allData replaceBytesInRange:NSMakeRange(0, headerData.length) withBytes:headerData.bytes];
    return allData;
}
+(NSData *)getFilesData{
    
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSArray *fileNames = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:documentsPath error:nil];
    NSMutableArray *files = [NSMutableArray array];
    for (NSString *fileName in fileNames) {
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        File *file = [[File alloc]init];
        file.name = fileName;
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:filePath];
        file.length = (int)[fh seekToEndOfFile];
        [files addObject:file];
        
    }
    
    NSData *filesData = [NSKeyedArchiver archivedDataWithRootObject:files];
    return filesData;
    
}
@end
