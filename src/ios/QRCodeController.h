    //
    //  QRCodeController.h
    //  Scan
    //
    //  Created by admin on 2019/12/2.
    //  Copyright © 2019年 admin. All rights reserved.
    //

#import <UIKit/UIKit.h>

typedef void(^ScannerBlock)(NSString *);

@interface QRCodeController : UIViewController
@property(nonatomic,copy)ScannerBlock  ScanBlock;

@end
