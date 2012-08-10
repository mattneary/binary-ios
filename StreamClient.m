//
//  StreamClient.m
//  FilePiper
//
//  Created by mattneary on 8/7/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import "StreamClient.h"

@implementation StreamClient
@synthesize delegate, streams, _socket, _req, URL, clientCreatedStreamID;

// delegate methods
// <StreamSocketLayer>
- (void)writeToSocket:(NSData *)data {
    [self._socket send:data];
}
- (void)destroyStream:(int)ident {
    [self.streams removeObjectForKey:[NSNumber numberWithInt:ident]];
}

// <SRWebSocketDelegate>
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(clientOpened)] ) {
        [self.delegate clientOpened];
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(clientErred)] ) {
        [self.delegate clientErred: error];
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(clientClosedWithCode:reason:wasClean:)] ) {
        [self.delegate clientClosedWithCode:code reason:reason wasClean:wasClean];
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    // Parse packet
    StreamUnpacker *unpacker = [StreamUnpacker unpackerWithData:message];
    NSArray *msg = [unpacker unpack];
    int type = [(NSNumber *)msg[0] intValue];
    
    if( type == 0x01 ) { // Meta
        BinaryStream *stream = [[BinaryStream alloc] init];
        stream._id = [(NSNumber *)msg[2] intValue];
        stream.client = self;
        [self.streams setObject:stream forKey:(NSNumber *)msg[2]];
        // Fire event on stream
        [stream didOpen:msg[1]];
        [self.delegate streamCreated:stream withMeta:msg[1]];
    } else if( type == 0x02 ) { // Data
        BinaryStream *stream = [self.streams objectForKey:(NSNumber *)msg[2]];
        // Fire event on stream
        [stream didWrite:msg[1]];
    } else if( type == 0x03 ) { // Pause
        BinaryStream *stream = [self.streams objectForKey:(NSNumber *)msg[2]];
        // Fire event on stream
        [stream didPause];
    } else if( type == 0x04 ) { // Resume
        BinaryStream *stream = [self.streams objectForKey:(NSNumber *)msg[2]];
        // Fire event on stream
        [stream didResume];
    } else if( type == 0x05 ) { // End
        BinaryStream *stream = [self.streams objectForKey:(NSNumber *)msg[2]];
        // Fire event on stream
        [stream didEnd];
    } else { // Close
        BinaryStream *stream = [self.streams objectForKey:(NSNumber *)msg[2]];
        // Fire event on stream
        [stream didClose];
    }
}

// methods

+ (StreamClient *)clientWithAddress: (NSURL *)url {
    StreamClient *alloc = [[StreamClient alloc] init];
    alloc.URL = url;
    return alloc;
}
- (void)_reconnect {
    _socket.delegate = nil;
    [_socket close];
    
    self._req = [NSURLRequest requestWithURL:self.URL];
    _socket = [[SRWebSocket alloc] initWithURLRequest:_req];
    _socket.delegate = self;
        
    [_socket open];
}
- (BinaryStream *)createStream: (id)meta withDelegate: (NSObject<StreamDelegate> *)delegate {
    BinaryStream *stream = [[BinaryStream alloc] init];
    stream._id = clientCreatedStreamID;
    clientCreatedStreamID += 2;
    stream.client = self;
    stream.delegate = delegate;
    [self.streams setObject:stream forKey:[NSNumber numberWithInt:stream._id]];
    [stream openWithMeta:meta];
    return stream;
}
- (void)openClient {
    self.streams = [[NSMutableDictionary alloc] initWithCapacity:20];
    self.clientCreatedStreamID = 1;
    [self _reconnect];
}
@end
