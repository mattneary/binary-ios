//
//  StreamPacker.h
//  FilePiper
//
//  Created by mattneary on 8/7/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamPacker : NSObject
@property NSMutableData *_bufferBuilder;

+ (StreamPacker *)packerWithCapacity: (int)size;
- (NSData *)pack: (id)value;

- (void)pack_bin: (NSData *)blob;
- (void)pack_string: (NSString *)str;
- (void)pack_array: (NSArray *)ary;
- (void)pack_object: (NSDictionary *)obj;

- (void)pack_integer: (NSNumber *)num;
- (void)pack_double: (NSNumber *)num;
- (void)pack_uint8: (NSNumber *)num;
- (void)pack_uint16: (NSNumber *)num;
- (void)pack_uint32: (NSNumber *)num;
- (void)pack_uint64: (NSNumber *)num;

- (void)pack_int8: (NSNumber *)num;
- (void)pack_int16: (NSNumber *)num;
- (void)pack_int32: (NSNumber *)num;
- (void)pack_int64: (NSNumber *)num;

@end
