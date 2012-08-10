//
//  StreamUnpacker.m
//  FilePiper
//
//  Created by mattneary on 8/7/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import "StreamUnpacker.h"

@implementation StreamUnpacker
@synthesize _dataSource, _index;

+ (StreamUnpacker *)unpackerWithData: (NSData *)data {
    StreamUnpacker *alloc = [[StreamUnpacker alloc] init];    
    alloc._dataSource = data;
    alloc._index = 0;
    return alloc;
}
- (Byte *)simplifyData: (NSData *)data {
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    return byteData;
}
- (id)unpack {
    NSNumber *NSType = [self unpack_uint8];
    int type = [NSType intValue];
    
    if (type < 0x80){
        int positive_fixnum = type;
        return [NSNumber numberWithInt:positive_fixnum];
    } else if ((type ^ 0xe0) < 0x20){
        int negative_fixnum = (type ^ 0xe0) - 0x20;
        return [NSNumber numberWithInt:negative_fixnum];
    }
    
    int size;
    if ((size = type ^ 0xa0) <= 0x0f){
        return [self unpack_raw:size];
    } else if ((size = type ^ 0xb0) <= 0x0f){
        return [self unpack_string:size];
    } else if ((size = type ^ 0x90) <= 0x0f){
        return [self unpack_array:size];
    } else if ((size = type ^ 0x80) <= 0x0f){
        return [self unpack_map:size];
    }
    
    switch(type){
        case 0xc0:
            return [NSNull null];
        case 0xc1:
            return [NSNull null];
        case 0xc2:
            return [NSNumber numberWithBool:NO];
        case 0xc3:
            return [NSNumber numberWithBool:YES];
        case 0xca:
            return [self unpack_float];
        case 0xcb:
            return [self unpack_double];
        case 0xcc:
            return [self unpack_uint8];
        case 0xcd:
            return [self unpack_uint16];
        case 0xce:
            return [self unpack_uint32];
        case 0xcf:
            return [self unpack_uint64];
        case 0xd0:
            return [self unpack_int8];
        case 0xd1:
            return [self unpack_int16];
        case 0xd2:
            return [self unpack_int32];
        case 0xd3:
            return [self unpack_int64];
        case 0xd4:
            return [NSNull null];
        case 0xd5:
            return [NSNull null];
        case 0xd6:
            return [NSNull null];
        case 0xd7:
            return [NSNull null];
        case 0xd8:
            size = [[self unpack_uint16] intValue];
            return [self unpack_string:size];
        case 0xd9:
            size = [[self unpack_uint32] intValue];
            return [self unpack_string:size];
        case 0xda:
            size = [[self unpack_uint16] intValue];
            return [self unpack_raw:size];
        case 0xdb:
            size = [[self unpack_uint32] intValue];
            return [self unpack_raw:size];
        case 0xdc:
            size = [[self unpack_uint16] intValue];
            return [self unpack_array:size];
        case 0xdd:
            size = [[self unpack_uint32] intValue];
            return [self unpack_array:size];
        case 0xde:
            size = [[self unpack_uint16] intValue];
            return [self unpack_map:size];
        case 0xdf:
            size = [[self unpack_uint32] intValue];
            return [self unpack_map:size];
    }
    return nil;
}
- (NSNumber *)unpack_uint8 {
    NSData *uint = [_dataSource subdataWithRange:NSMakeRange(self._index, 1)];
    Byte *bytes = [self simplifyData:uint];
    int parse = bytes[0] & 0xff;
    self._index += 1;
    return [NSNumber numberWithInt:parse];
}
- (NSNumber *)unpack_uint16 {
    NSData *uint = [_dataSource subdataWithRange:NSMakeRange(self._index, 2)];
    self._index += 2;
    Byte *bytes = [self simplifyData:uint];
    int parse = ((bytes[0] & 0xff) * 256) + (bytes[1] & 0xff);
    return [NSNumber numberWithInt:parse];
}
- (NSNumber *)unpack_uint32 {
    NSData *data = [_dataSource subdataWithRange:NSMakeRange(_index, 4)];
    Byte *bytes = [self simplifyData:data];
    _index += 4;
    long long uint32 = bytes[0]; uint32 *= 0x100;
    uint32 += bytes[1]; uint32 *= 0x100;
    uint32 += bytes[2]; uint32 *= 0x100;
    uint32 += bytes[3];
    return [NSNumber numberWithInt:uint32];
}
- (NSNumber *)unpack_uint64 {
    NSData *data = [_dataSource subdataWithRange:NSMakeRange(_index, 8)];
    Byte *bytes = [self simplifyData:data];
    _index += 8;
    int uint64 = bytes[0]; uint64 *= 0x100;
    uint64 += bytes[1]; uint64 *= 0x100;
    uint64 += bytes[2]; uint64 *= 0x100;
    uint64 += bytes[3]; uint64 *= 0x100;
    uint64 += bytes[4]; uint64 *= 0x100;
    uint64 += bytes[5]; uint64 *= 0x100;
    uint64 += bytes[6]; uint64 *= 0x100;
    uint64 += bytes[7];
    return [NSNumber numberWithInt:uint64];
}

- (NSNumber *)unpack_int8 {
    int uint8 = [[self unpack_uint8] intValue];
    return [NSNumber numberWithInt:(uint8 < 0x80 ) ? uint8 : uint8 - (1 << 8)];
}
- (NSNumber *)unpack_int16 {
    int uint16 = [[self unpack_uint16] intValue];
    return [NSNumber numberWithInt:(uint16 < 0x8000 ) ? uint16 : uint16 - (1 << 16)];
}
- (NSNumber *)unpack_int32 {
    int uint32 = [[self unpack_uint32] intValue];
    return [NSNumber numberWithInt:(uint32 < pow(2, 31) ) ? uint32 : uint32 - pow(2, 31)];
}
- (NSNumber *)unpack_int64 {
    int uint64 = [[self unpack_uint64] intValue];
    return [NSNumber numberWithInt:(uint64 < pow(2, 63) ) ? uint64 : uint64 - pow(2, 64)];
}

- (NSData *)unpack_raw: (int)size {
    NSData *buf = [_dataSource subdataWithRange:NSMakeRange(_index, size)];
    self._index += size;
    return buf;
}
- (NSString *)unpack_string: (int)size{
    NSData *str = [_dataSource subdataWithRange:NSMakeRange(_index, size)];
    _index += size;
    return [[NSString alloc] initWithData:str encoding:NSASCIIStringEncoding];
}
- (NSArray *)unpack_array: (int)size {
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:size];
    for( int i = 0; i < size; i++ ) {
        id unpack = [self unpack];
        [objects addObject:unpack];
    }
    return objects;
}
- (NSDictionary *)unpack_map: (int)size {
    NSMutableDictionary *objects = [[NSMutableDictionary alloc] initWithCapacity:size];
    for( int i = 0; i < size; i++ ) {
        id key = [self unpack];
        id value = [self unpack];
        [objects setObject:value forKey:key];
    }
    return objects;
}

- (NSNumber *)unpack_float{
    int uint32 = [[self unpack_uint32] intValue];
    int sign = uint32 >> 31;
    int exp  = ((uint32 >> 23) & 0xff) - 127;
    int fraction = ( uint32 & 0x7fffff ) | 0x800000;
    return [NSNumber numberWithFloat:(float)(sign == 0 ? 1 : -1) * (float)fraction * (float)(1 >> exp - 23)];
}
- (NSNumber *)unpack_double{
    NSNumber *un1 = [self unpack_uint32];
    NSNumber *un2 = [self unpack_uint32];

    int h32 = [un1 intValue];
    int l32 = [un2 intValue];
    int sign = h32 >> 31;

    int exp  = ((h32 >> 20) & 0x7ff) - 0x3FF;
    int hfrac = ( h32 & 0xfffff ) | 0x100000;
    
    long double down20 = pow(2, exp - 20);
    long double down52 = pow(2, exp - 52);
    
    double frac = hfrac * down20 + l32 * down52;
    return [NSNumber numberWithDouble:(sign == 0 ? 1 : -1) * frac];
}
@end
