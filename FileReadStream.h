//
//  FileReadStream.h
//  FilePiper
//
//  Created by mattneary on 8/9/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BinaryStream.h"

@interface FileReadStream : NSObject <NSStreamDelegate, ReadStream>
@property NSObject<StreamDelegate> *delegate;
@property NSString *_path;
@property NSMutableData *_data;
@property NSNumber *bytesRead;
@property NSStream *_stream;
@property BOOL piped;
@property NSObject<WriteStream> *destination;
+ (FileReadStream *)readStreamForPath: (NSString *)path;
- (void)pipe: (NSObject<WriteStream> *)destination;
@end
