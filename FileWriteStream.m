//
//  FileWriteStream.m
//  FilePiper
//
//  Created by mattneary on 8/8/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import "FileWriteStream.h"

@implementation FileWriteStream
@synthesize queue, fileHandle_writer, _path;

+ (FileWriteStream *)writeStreamForPath: (NSString *)filePath {
    FileWriteStream *alloc = [[FileWriteStream alloc] init];
    if(!alloc.queue) {
        alloc.queue = dispatch_queue_create("fileWriteQueue", NULL);
    }
    alloc._path = filePath;
    return alloc;
}
- (void)end {
    NSLog(@"end");
    // TODO
}
- (void)write: (NSData *)data {
    //NSString *newFilePath = [NSHomeDirectory()  stringByAppendingPathComponent:@"/Documents/MyFile.xml"];
    NSString *newFilePath = self._path;
    if(![[NSFileManager defaultManager]  fileExistsAtPath:newFilePath ]) {
        [[NSFileManager defaultManager] createFileAtPath:newFilePath contents:nil attributes:nil];
    }
    
    if(!fileHandle_writer) {
        self.fileHandle_writer = [NSFileHandle fileHandleForWritingAtPath:newFilePath];
    }
    dispatch_async( queue , ^ {
       // execute asynchronously
       [fileHandle_writer seekToEndOfFile];
       [fileHandle_writer writeData:data];
    });
}
@end
