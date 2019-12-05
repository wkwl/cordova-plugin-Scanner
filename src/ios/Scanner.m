/********* Scanner.m Cordova Plugin Implementation *******/

#import "Scanner.h"

@implementation Scanner

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

@end
