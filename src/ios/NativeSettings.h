#import <Cordova/CDV.h>

@interface NativeSettings : CDVPlugin

- (void)open:(CDVInvokedUrlCommand*)command;
- (void)isAvailable:(CDVInvokedUrlCommand*)command;

@end