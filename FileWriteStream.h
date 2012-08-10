//
//  FileWriteStream.h
//  FilePiper
//
//  Created by mattneary on 8/8/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BinaryStream.h"

@interface FileWriteStream : NSObject <WriteStream>
@property dispatch_queue_t queue;
@property NSFileHandle *fileHandle_writer;
@property NSString *_path;
+ (FileWriteStream *)writeStreamForPath: (NSString *)filePath;

- (void)write: (NSData *)data;
- (void)end;
@end
