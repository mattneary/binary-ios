//
//  StreamPacker.m
//  FilePiper
//
//  Created by mattneary on 8/7/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import "StreamPacker.h"

@implementation StreamPacker
@synthesize _bufferBuilder;

+ (StreamPacker *)packerWithCapacity: (int)size {
    StreamPacker *alloc = [[StreamPacker alloc] init];
    alloc._bufferBuilder = [[NSMutableData alloc] initWithCapacity:size];
    return alloc;
}
- (NSData *)pack: (id)value {
	if ([value isKindOfClass:[NSString class]]){
        [self pack_string:value];
	} else if ([value isKindOfClass:[NSNumber class]]){
        if (floor([(NSNumber *)value doubleValue]) == [(NSNumber *)value doubleValue]){
            [self pack_integer:value];
        } else{
            [self pack_double:value];
        }
	} else if (value == nil){
        int byte = 0xc0;
        [_bufferBuilder appendBytes:&byte length:1];
	} else if ([value isKindOfClass:[NSArray class]]) {
        [self pack_array:value];
	} else if([value isKindOfClass:[NSData class]]) {
        [self pack_bin:value];
	} else if([value isKindOfClass:[NSDictionary class]]) {
        [self pack_object:value];
	}
    return _bufferBuilder;
};

- (void)pack_bin: (NSData *)blob {
    int length = [blob length];
    if (length <= 0x0f){
        [self pack_uint8:[NSNumber numberWithInt:0xa0 + length]];
    } else if (length <= 0xffff){
        int byte = 0xda;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint16:[NSNumber numberWithInt:length]];
    } else if (length <= 0xffffffff){
        int byte = 0xdb;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint32:[NSNumber numberWithInt:length]];
    }
    [_bufferBuilder appendData:blob];
}
- (void)pack_string: (NSString *)str {
    int length = [str length];
    if (length <= 0x0f){
        [self pack_uint8:[NSNumber numberWithInt:(0xb0 + length)]];
    } else if (length <= 0xffff){
        int byte = 0xD8;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint16:[NSNumber numberWithInt:length]];
    } else if (length <= 0xffffffff){
        int byte = 0xD9;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint32:[NSNumber numberWithInt:length]];
    }
    [_bufferBuilder appendData:[str dataUsingEncoding:NSStringEncodingConversionAllowLossy]];
}
- (void)pack_array: (NSArray *)ary {
    int length = [ary count];
    if (length <= 0x0f){
        [self pack_uint8:[NSNumber numberWithInt:(0x90 + length)]];
    } else if (length <= 0xffff){
        int byte = 0xDC;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint16:[NSNumber numberWithInt:length]];
    } else if (length <= 0xffffffff){
        int byte = 0xDD;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint32:[NSNumber numberWithInt:length]];
    }
    for(int i = 0; i < length ; i++){
        [self pack:ary[i]];
    }
}
- (void)pack_object: (NSDictionary *)obj {
    NSArray *keys = [obj allKeys];
    int length = [keys count];
    if (length <= 0x0f){
        [self pack_uint8:[NSNumber numberWithInt:(0x80 + length)]];
    } else if (length <= 0xffff){
        int byte = 0xde;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint16:[NSNumber numberWithInt:length]];
    } else if (length <= 0xffffffff){
        int byte = 0xdf;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint32:[NSNumber numberWithInt:length]];
    }
    for(id prop in obj){
        [self pack:prop];
        [self pack:obj[prop]];
    }
}

- (void)pack_integer: (NSNumber *)num {
    int number = [num intValue];
    if ( -0x20 <= number && number <= 0x7f){
        int byte = [num intValue] & 0xff;
        [_bufferBuilder appendBytes:&byte length:1];
    } else if (0x00 <= number && number <= 0xff){
        int byte = 0xcc;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint8:num];
    } else if (-0x80 <= number && number <= 0x7f){
        int byte = 0xd0;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_int8:num];
    } else if ( 0x0000 <= number && number <= 0xffff){
        int byte = 0xcd;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint16:num];
    } else if (-0x8000 <= number && number <= 0x7fff){
        int byte = 0xd1;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_int16:num];
    } else if ( 0x00000000 <= number && number <= 0xffffffff){
        int byte = 0xce;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint32:num];
    } else if (-0x80000000 <= number && number <= 0x7fffffff){
        int byte = 0xd2;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_int32:num];
    } else if (-0x8000000000000000 <= number && number <= 0x7FFFFFFFFFFFFFFF){
        int byte = 0xd3;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_int64:num];
    } else if (0x0000000000000000 <= number && number <= 0xFFFFFFFFFFFFFFFF){
        int byte = 0xcf;
        [_bufferBuilder appendBytes:&byte length:1];
        [self pack_uint64:num];
    }
}
- (void)pack_double: (NSNumber *)num {
    int sign = 0;
    double number = [num doubleValue];
    if (num < 0){
        sign = 1;
        number = -1 * [num doubleValue];
    }
    int exp  = floor(log(number) / log(2));
    long double frac0 = number / pow(2, exp) - 1;
    long long frac1 = floor(frac0 * pow(2, 52));
    long long b32   = pow(2, 32);
    long h32 = (sign << 31) | ((exp+1023) << 20) | ((frac1 / b32) & 0x0fffff);
    int l32 = frac1 % b32;
    
    int byte = 0xcb;
    [_bufferBuilder appendBytes:&byte length:1];
    
    [self pack_int32:[NSNumber numberWithLong:h32]];
    [self pack_int32:[NSNumber numberWithLong:l32]];
}
- (void)pack_uint8: (NSNumber *)num {
    int byte = [num intValue];
    [_bufferBuilder appendBytes:&byte length:1];
}
- (void)pack_uint16: (NSNumber *)num{
    int byte = [num intValue] >> 8;
    [_bufferBuilder appendBytes:&byte length:1];
    byte = [num intValue] & 0xff;
    [_bufferBuilder appendBytes:&byte length:1];
}
- (void)pack_uint32: (NSNumber *)num {
    long n = [num longLongValue] & 0xffffffff;
    
    // unsigned shift = >>>
    long byte = (unsigned int)(n & 0xff000000) >> 24;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(n & 0x00ff0000) >> 16;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(n & 0x0000ff00) >>  8;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(n & 0x000000ff);
    [_bufferBuilder appendBytes:&byte length:1];
}
- (void)pack_uint64: (NSNumber *)num {
    int number = [num intValue];
    
    int high = number / pow(2, 32);
    int low  = number % (long)pow(2, 32);
    
    int byte = (unsigned int)(high & 0xff000000) >> 24;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(high & 0x00ff0000) >> 16;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(high & 0x0000ff00) >>  8;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(high & 0x000000ff);
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(low  & 0xff000000) >> 24;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(low  & 0x00ff0000) >> 16;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(low  & 0x0000ff00) >>  8;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(low  & 0x000000ff);
    [_bufferBuilder appendBytes:&byte length:1];
}

- (void)pack_int8: (NSNumber *)num {
    int byte = [num intValue] & 0xff;
    [_bufferBuilder appendBytes:&byte length:1];
}
- (void)pack_int16: (NSNumber *)num {
    long byte = ([num intValue] & 0xff00) >> 8;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = [num intValue] & 0xff;
    [_bufferBuilder appendBytes:&byte length:1];
}
- (void)pack_int32: (NSNumber *)num {
    long byte = ((unsigned int)[num intValue] >> 24) & 0xff;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)([num intValue] & 0x00ff0000) >> 16;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)([num intValue] & 0x0000ff00) >> 8;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)([num intValue] & 0x000000ff);
    [_bufferBuilder appendBytes:&byte length:1];
}
- (void)pack_int64: (NSNumber *)num {
    long number = [num longLongValue];
    
    long high = floor(number / pow(2, 32));
    long low  = number % (long)pow(2, 32);
    
    long byte = (unsigned int)(high & 0xff000000) >> 24;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(high & 0x00ff0000) >> 16;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(high & 0x0000ff00) >>  8;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(high & 0x000000ff);
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(low  & 0xff000000) >> 24;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(low  & 0x00ff0000) >> 16;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(low  & 0x0000ff00) >>  8;
    [_bufferBuilder appendBytes:&byte length:1];
    
    byte = (unsigned int)(low  & 0x000000ff);
    [_bufferBuilder appendBytes:&byte length:1];
}

@end
