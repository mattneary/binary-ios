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
