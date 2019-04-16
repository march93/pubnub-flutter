#import "PubnubPlugin.h"

@implementation PubnubPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"pubnub"
            binaryMessenger:[registrar messenger]];
  PubnubPlugin* instance = [[PubnubPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

@end

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if  ([@"create" isEqualToString:call.method]) {
        result([self handleCreate:call]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (id) handleCreate:(FlutterMethodCall*)call {
    NSString *publishKey = call.arguments[@"publishKey"];
    NSString *subscribeKey = call.arguments[@"subscribeKey"];
    NSString *uuid = call.arguments[@"uuid"];
    if(publishKey && subscribeKey) {       
        self.config =
        [PNConfiguration configurationWithPublishKey:publishKey
                                        subscribeKey:subscribeKey];
        self.config.stripMobilePayload = NO;
        if(uuid) {
            self.config.uuid = uuid;
        } else {
            self.config.uuid = [NSUUID UUID].UUIDString.lowercaseString;
        }
        self.client = [PubNub clientWithConfiguration:self.config];
        [self.client addListener:self];
    }
    // Nothing to return, just return NULL
    return NULL;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"pubnub"
                                     binaryMessenger:[registrar messenger]];
    PubnubFlutterPlugin* instance = [[PubnubFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    // Event channel for streams
    instance.messageStreamHandler = [MessageStreamHandler new];
    FlutterEventChannel* messageChannel =
    [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/pubnub_message"
                              binaryMessenger:[registrar messenger]];
    [messageChannel setStreamHandler:instance.messageStreamHandler];
    // Event channel for streams
    instance.statusStreamHandler = [StatusStreamHandler new];
    FlutterEventChannel* statusChannel =
    [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/pubnub_status"
                              binaryMessenger:[registrar messenger]];
    [statusChannel setStreamHandler:instance.statusStreamHandler];
    instance.errorStreamHandler = [ErrorStreamHandler new];
}

@implementation MessageStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}
- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}
- (void) sendMessage:(PNMessageResult *)message {
     if(self.eventSink) {
         NSDictionary *result = @{@"uuid": message.uuid, @"channel": message.data.channel, @"message": message.data.message};
         self.eventSink(result);
     }
}

@end

@implementation StatusStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}
- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}
- (void) sendStatus:(PNStatus *)status {
    if(self.eventSink) {
        self.eventSink(status.stringifiedOperation);
    }
}

@end