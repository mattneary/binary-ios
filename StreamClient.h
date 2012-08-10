//
//  StreamClient.h
//  FilePiper
//
//  Created by mattneary on 8/7/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BinaryStream.h"
#import "SRWebSocket.h"
#import "StreamPacker.h"
#import "StreamUnpacker.h"
#import "FileReadStream.h"
#import "FileWriteStream.h"

@class BinaryStream;

@protocol StreamClientDelegate <NSObject>
- (void)streamCreated: (BinaryStream *)stream withMeta: (id)meta;
@optional
- (void)clientOpened;
- (void)clientClosedWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)clientErred: (NSError *)error;
@end

@interface StreamClient : NSObject <StreamSocketLayer, SRWebSocketDelegate>
@property NSMutableDictionary *streams;
@property NSURL *URL;
@property SRWebSocket *_socket;
@property NSURLRequest *_req;
@property int clientCreatedStreamID;
@property NSObject<StreamClientDelegate> *delegate;

+ (StreamClient *)clientWithAddress: (NSURL *)url;
- (BinaryStream *)createStream: (id)meta withDelegate: (NSObject<StreamDelegate> *)delegate;
- (void)openClient;
@end