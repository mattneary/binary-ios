//
//  ExampleViewController.m
//  FilePiper
//
//  Created by mattneary on 8/5/12.
//  Copyright (c) 2012 mattneary. All rights reserved.
//

#import "ExampleViewController.h"
#import "StreamClient.h"

@implementation ExampleViewController

// delegate methods
// <StreamClientDelegate>
- (void)streamCreated:(BinaryStream *)stream withMeta:(id)meta {
    // Fired for server created streams
    stream.delegate = self;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *outPath = [basePath stringByAppendingPathComponent:@"out.txt"];
    // Create or Clear File
    [[NSFileManager defaultManager] createFileAtPath:outPath contents:nil attributes:nil];
    // Write stream to file with pipe
    [stream pipe:[FileWriteStream writeStreamForPath:outPath]];
    
    NSLog(@"stream was created: %@", meta);
}
- (void)clientOpened {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;    
    // Make a reader
    readStream = [FileReadStream readStreamForPath:[basePath stringByAppendingPathComponent:@"out.txt"]];
    readStream.delegate = self; // Handle file stream just like BinaryStreams
    [readStream open];
    
    // Stream created on the client, delegate called as always
    BinaryStream *stream = [_client createStream:@{@"name": @"matt", @"type": @"message"} withDelegate:self];
    // manipulate the returned stream to write etc.
    [stream write:@"hello"];
}
- (void)clientClosedWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"closed %d (%@): - %@", code, wasClean?@"clean":@"unclean", reason);
}
- (void)clientErred:(NSError *)error {
    NSLog(@"error %@", [error description]);
}

// <StreamDelegate>
- (void)streamGotData: (id)data {
    NSLog(@"streamGotData %@", data);
}
- (void)streamGotError: (NSError *)error {
    NSLog(@"error %@", error);
}

// methods

- (void)viewWillAppear:(BOOL)animated {
    _client = [StreamClient clientWithAddress:[NSURL URLWithString:@"ws://filepiper.com/abcd"]];
    _client.delegate = self;
    [_client openClient];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
