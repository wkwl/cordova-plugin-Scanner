//
//  testPlugin.h
//  
//
//  Created by admin on 2019/11/27.
//
#import <Cordova/CDV.h>
#import "QRCodeController.h"
@interface Scanner : CDVPlugin {
        // Member variables go here.
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
@end
