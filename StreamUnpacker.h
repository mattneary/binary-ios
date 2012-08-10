//
//  StreamUnpacker.h
//  FilePiper
//
//  Created by mattneary on 8/7/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamUnpacker : NSObject
@property NSData *_dataSource;
@property int _index;

+ (StreamUnpacker *)unpackerWithData: (NSData *)data;
- (Byte *)simplifyData: (NSData *)data;
- (id)unpack;

- (NSNumber *)unpack_uint8;
- (NSNumber *)unpack_uint16;
- (NSNumber *)unpack_uint32;
- (NSNumber *)unpack_uint64;

- (NSNumber *)unpack_int8;
- (NSNumber *)unpack_int16;
- (NSNumber *)unpack_int32;
- (NSNumber *)unpack_int64;

- (NSNumber *)unpack_raw: (int)size;
- (NSNumber *)unpack_string: (int)size;
- (NSArray *)unpack_array: (int)size;
- (NSNumber *)unpack_map: (int)size;

- (NSNumber *)unpack_float;
- (NSNumber *)unpack_double;
@end
