//
//  BinaryStream.h
//  FilePiper
//
//  Created by mattneary on 8/7/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
@class BinaryStream;

@protocol StreamSocketLayer <NSObject>
- (void)writeToSocket: (NSData *)data;
- (void)destroyStream:(int)ident;
@optional
- (void)streamPaused;   //TODO
- (void)streamResumed;  //TODO
- (void)streamEnded;    //TODO
- (void)streamClosed;   //TODO
- (void)streamDrained;  //TODO
- (void)streamErred;    //TODO
@end

@protocol StreamDelegate <NSObject>
- (void)streamGotData: (id)data;
- (void)streamGotError: (NSError *)error;
- (void)streamEnded;
@end

@protocol WriteStream <NSObject>
- (void)write: (id)data;
- (void)end;
@optional
- (void)pause;  //TODO
- (void)resume; //TODO
@end

@protocol ReadStream <NSObject>
- (void)open;
@optional
- (void)pipe: (NSObject<WriteStream> *)destination;
- (void)pause;  //TODO
- (void)resume; //TODO
@end

@interface BinaryStream : NSObject
@property int _id;
@property BOOL readable;    //TODO
@property BOOL writable;    //TODO
@property BOOL paused;      //TODO
@property BOOL piped;
@property NSObject<WriteStream> *destination;
@property SRWebSocket *_socket;
@property NSObject<StreamSocketLayer> *client;
@property NSObject<StreamDelegate> *delegate;

// Methods called to send messages to the server
- (void)openWithMeta: (id)meta;
- (void)pause;
- (void)resume;
- (void)end;
- (void)destroy;
- (void)pipe: (NSObject<WriteStream> *)destination;
- (void)write: (id)data;

// Events from the server that bubble to the delegate
- (void)didWrite: (id)data;
- (void)didOpen: (id)meta;
- (void)didPause;
- (void)didResume;
- (void)didEnd;
- (void)didClose;
@end