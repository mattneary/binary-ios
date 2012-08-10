//
//  BinaryStream.m
//  FilePiper
//
//  Created by mattneary on 8/7/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import "BinaryStream.h"
#import "StreamPacker.h"
#import "StreamUnpacker.h"
#import "SRWebSocket.h"
#import "StreamClient.h"

@implementation BinaryStream
@synthesize _socket, _id, delegate, client, destination, piped;

// methods

- (void)didWrite: (id)data {    
    if( self.delegate != nil ) {
        [self.delegate streamGotData:data];
    }
    if( self.piped ) {
        [self.destination write:data];
    }
}
- (void)didOpen: (id)meta {
    // not necessary
}
- (void)didPause {
    if( self.piped && [self.destination respondsToSelector:@selector(pause)] ) {
        [self.destination pause];
    }
}
- (void)didResume {
    if( self.piped && [self.destination respondsToSelector:@selector(resume)] ) {
        [self.destination resume];
    }
}
- (void)didEnd {
    if( self.piped ) {
        [self.destination end];
    }
    [self.client destroyStream:self._id];
}
- (void)didClose {
    if( self.piped ) {
        [self.destination end];
    }
    [self.client destroyStream:self._id];
}

- (void)openWithMeta: (id)meta {
    StreamPacker *packer = [StreamPacker packerWithCapacity:sizeof(meta)+255];
    [self.client writeToSocket:[packer pack:@[@0x01, meta, [NSNumber numberWithInt:self._id]]]];    
}
- (void)pause {
    // TODO
}
- (void)resume {
    // TODO
}
- (void)end {
    StreamPacker *packer = [StreamPacker packerWithCapacity:255];
    [self.client writeToSocket:[packer pack:@[@0x05, [NSNull null], [NSNumber numberWithInt:self._id]]]];
    self.readable = NO;
}
- (void)destroy {
    [self._socket close];
}
- (void)write: (id)data {
    StreamPacker *packer = [StreamPacker packerWithCapacity:sizeof(data)+255];
    [self.client writeToSocket:[packer pack:@[@0x02, data, [NSNumber numberWithInt:self._id]]]];    
}
- (void)pipe: (NSObject<WriteStream> *)destination {
    self.piped = YES;
    self.destination = destination;
}
@end
