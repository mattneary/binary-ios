//
//  FileReadStream.m
//  FilePiper
//
//  Created by mattneary on 8/9/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import "FileReadStream.h"

@implementation FileReadStream
@synthesize _path, _data, bytesRead, _stream, piped, destination;
+ (FileReadStream *)readStreamForPath: (NSString *)path {
    FileReadStream *alloc = [[FileReadStream alloc] init];
    alloc._path = path;
    return alloc;
}
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            if(!_data) {
                _data = [NSMutableData data];
            }
            uint8_t buf[4096];
            unsigned int len = 0;
            len = [(NSInputStream *)_stream read:buf maxLength:4096];
            if(len) {
                [_data appendBytes:(const void *)buf length:len];
                if( self.piped ) {
                    [self.destination write:[NSData dataWithBytes:buf length:len]];
                }
                if( self.delegate ) {
                    [self.delegate streamGotData:[NSData dataWithBytes:buf length:len]];
                }
                // bytesRead is an instance variable of type NSNumber.
                bytesRead = [NSNumber numberWithInt:[bytesRead intValue]+len];
            } else {
                NSLog(@"no buffer");
            }
            break;
        }
        case NSStreamEventEndEncountered:
        {
            if( self.piped ) {
                [self.destination end];
            }
            [_stream close];
            [_stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            _stream = nil; // stream is ivar, so reinit it
            break;
        }
    }
}
- (void)open {
    self._stream = [[NSInputStream alloc] initWithFileAtPath:self._path];
    self._stream.delegate = self;
    [self._stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self._stream open];
}
- (void)pipe: (NSObject<WriteStream> *)destination {
    self.piped = YES;
    self.destination = destination;
}
@end
