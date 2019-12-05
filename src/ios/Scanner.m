/********* Scanner.m Cordova Plugin Implementation *******/

#import "Scanner.h"

@implementation Scanner

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    QRCodeController *vc = [[QRCodeController alloc] init];
    vc.ScanBlock = ^(NSString *result){
        CDVPluginResult *pluginResult = nil;
        if (result!=nil) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"扫码失败"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    [self.viewController presentViewController:vc animated:YES completion:nil];
//    CDVPluginResult* pluginResult = nil;
//    NSString* echo = [command.arguments objectAtIndex:0];
//
//    if (echo != nil && [echo length] > 0) {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
//    } else {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//    }
//
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
