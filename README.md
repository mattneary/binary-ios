Setup
=====

![Frameworks and Sources](http://f.cl.ly/items/2r0F2N1i1X413P37090b/Screen%20Shot%202012-08-11%20at%201.26.46%20PM.png)

Usage
=====

Include StreamClient.h:

```objective-c
#import "StreamClient.h"
```

Create a client to a websocket, set to an instance variable then set a delegate and open:

```objective-c
- (void)viewWillAppear:(BOOL)animated {
    _client = [StreamClient clientWithAddress:[NSURL URLWithString:@"ws://filepiper.com/abcd"]];
    _client.delegate = self;
    [_client openClient];
}
```

Abide to `StreamClientDelegate` Protocol: 

```objective-c
@protocol StreamClientDelegate <NSObject>
- (void)streamCreated: (BinaryStream *)stream withMeta: (id)meta;
@optional
- (void)clientOpened;
- (void)clientClosedWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)clientErred: (NSError *)error;
@end
```	


When handling created streams, a delegate should follow the `StreamDelegate` protocol:

```objective-c
@protocol StreamDelegate <NSObject>
- (void)streamGotData: (id)data;
- (void)streamGotError: (NSError *)error;
- (void)streamEnded;
@end
```

Create, write to, listen to, end, and pipe streams as you please. Use the `FileReadStream` and `FileWriteStream` which are file interfaces following the same protocols as `BinaryStream`s:

```objective-c
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
```
