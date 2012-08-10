//
//  ExampleViewController.h
//  FilePiper
//
//  Created by mattneary on 8/5/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"
#import "StreamClient.h"
#import "FileReadStream.h"

@interface ExampleViewController : UIViewController <StreamClientDelegate, StreamDelegate> {
    SRWebSocket *_webSocket;
    NSURLRequest *_req;
    IBOutlet UILabel *_meta;
    IBOutlet UILabel *_data;
    NSMutableData *_dataStore;
    StreamClient *_client;
    BinaryStream *initialStream;
    FileReadStream *readStream;
}
@end
