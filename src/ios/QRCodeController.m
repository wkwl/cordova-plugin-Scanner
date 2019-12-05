    //
    //  QRCodeController.m
    //  Scan
    //
    //  Created by admin on 2019/12/2.
    //  Copyright © 2019年 admin. All rights reserved.
    //

#import "QRCodeController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeController ()<AVCaptureMetadataOutputObjectsDelegate>{
    BOOL isFirst;
    BOOL upOrdown;
    int num;
    NSTimer * timer;

}
    @property (nonatomic,strong)AVCaptureSession *Session;
    @property (nonatomic,strong)AVCaptureDevice *captureDevice;
    @property (nonatomic,strong)AVCaptureVideoPreviewLayer *Preview;
    @property (nonatomic,assign) BOOL  flag;
    @property (nonatomic,strong)UIButton *backBtn;
    @property (nonatomic,retain)UIImageView *lineIV;

    @end

@implementation QRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirst=YES;
    upOrdown = NO;
    num =0;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initDevice];
    [self checkAVAuthorizationStatus];
    [self createBtn];
    [self creatTimer];
}
- (void)viewWillAppear:(BOOL)animated {
    _lineIV = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - self.view.layer.bounds.size.width * 0.7)/2,self.view.layer.bounds.size.height * 0.25 , self.view.layer.bounds.size.width * 0.7, 5)];
    _lineIV.image =[self getImageName:@"line@2x"];
    [self.view addSubview:_lineIV];

    [self.Session startRunning];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}
- (void)createBtn {
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[self getImageName:@"btn_left"] forState:UIControlStateNormal];
    self.backBtn.frame = CGRectMake(20,30,22,34);
    [self.view addSubview:self.backBtn];
    [self.backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}
        //检测相机使用权限
- (void)checkAVAuthorizationStatus
    {
  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  NSString *tips = NSLocalizedString(@"AVAuthorization", @"您没有权限访问相机");
  if(status == AVAuthorizationStatusAuthorized) {
          // authorized
          //        [self initDevice];
  } else {
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请打开相机设置" preferredStyle:UIAlertControllerStyleAlert];

      UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
      UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];

      [alertController addAction:cancelAction];
      [alertController addAction:okAction];
      [self presentViewController:alertController animated:YES completion:nil];

      NSLog(@"%@",tips);
  }
    }
        //1.初始化摄像机调用准备
- (void)initDevice {
        //获取摄像头
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.captureDevice = device;
        //设置输入流（即将摄像头作为图像输入设备，也就是让摄像头作为扫码设备）
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        //创建输出流，对输入流捕获的图像，进行解析输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //设置输出流代理，通过代理方法读取信息.
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置输出类型，即扫码类型

    [self initQRScanSession:input outPut:output];

}
        //2.创建扫描会话
- (void)initQRScanSession:(AVCaptureDeviceInput *)input outPut:(AVCaptureMetadataOutput *)output {
        //初始化扫描session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.Session = session;
    if ([session canAddInput:input]) {
        [session addInput:input];//将输入添加到会话中
    }
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
        //需要设置在addOutput之后，否则会报错：（[AVCaptureMetadataOutput setMetadataObjectTypes:] Unsupported type found ）
    output.rectOfInterest = CGRectMake(0.25,([UIScreen mainScreen].bounds.size.width - self.view.layer.bounds.size.width * 0.7)/2/self.view.layer.bounds.size.width,  self.view.layer.bounds.size.width * 0.7/self.view.layer.bounds.size.height,(self.view.layer.bounds.size.width * 0.7)/self.view.layer.bounds.size.width);
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    UIImageView *codeFrame = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - self.view.layer.bounds.size.width * 0.7)/2, self.view.layer.bounds.size.height * 0.25,  self.view.layer.bounds.size.width * 0.7, self.view.layer.bounds.size.width * 0.7)];
    codeFrame.contentMode = UIViewContentModeScaleAspectFit;
    [codeFrame setImage:[self getImageName:@"codeframe@2x"]];
    [self.view addSubview:codeFrame];
        //创建二维码扫描之外的其他视图
    [self initOtherView:codeFrame];
        //创建扫描框
    [self initQRScanView:session];
}

- (void)initOtherView:(UIImageView *)codeFrame {
    UILabel * introLab = [[UILabel alloc] initWithFrame:CGRectMake(codeFrame.frame.origin.x, codeFrame.frame.origin.y + codeFrame.frame.size.height, codeFrame.frame.size.width, 40)];
    introLab.numberOfLines = 1;
    introLab.textAlignment = NSTextAlignmentCenter;
    introLab.textColor = [UIColor whiteColor];
    introLab.adjustsFontSizeToFitWidth = YES;
    introLab.text = @"将二维码/条码放入框内，即可自动扫描";
    [self.view addSubview:introLab];

    UIButton * theLightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    theLightBtn.frame = CGRectMake(self.view.frame.size.width / 2 - 100 / 2, introLab.frame.origin.y + introLab.frame.size.height + 20, 100, introLab.frame.size.height);
    [theLightBtn setImage:[self getImageName:@"light@2x"] forState:UIControlStateNormal];
    [theLightBtn setImage:[self getImageName:@"lighton@2x"] forState:UIControlStateSelected];
    [theLightBtn addTarget:self action:@selector(lightOnOrOff:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:theLightBtn];
}
        //3.创建扫描框
- (void)initQRScanView:(AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    self.Preview = preview;
    preview.videoGravity = AVLayerVideoGravityResize;
    [preview setFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view.layer insertSublayer:preview atIndex:0];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        [self deleteTimer];
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *result = obj.stringValue;//这就是扫描的结果啦
                                           //对结果进行处理...
        NSLog(@"%@",result);
        [self deleteView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.ScanBlock(result);
        });


            //        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:result preferredStyle:UIAlertControllerStyleAlert];
            //
            //        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //            [self deleteView];
            //        }];
            //        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //            [self deleteView];
            //            self.ScanBlock(result);
            //        }];
            //
            //        [alertController addAction:cancelAction];
            //        [alertController addAction:okAction];
            //        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (void)deleteView {
    [self.Session stopRunning];//停止会话
    [self.Preview removeFromSuperlayer];//移除取景器
    [self dismissViewControllerAnimated:YES completion:nil];
    [self deleteTimer];
    self.flag = false;
}
#pragma mark - action
- (void)back {
    [self.Session stopRunning];
    [self deleteTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)animation {

    if (upOrdown == NO) {
        num ++;
        _lineIV.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width- self.view.layer.bounds.size.width * 0.7)/2,self.view.layer.bounds.size.height * 0.25+ 2 * num, self.view.layer.bounds.size.width * 0.7, 5);

        NSLog(@"%f",(int)self.view.frame.size.width*.7);
        if ((2 * num == (int)(self.view.layer.bounds.size.width *.7))||(2 * num == (int)(self.view.layer.bounds.size.width *.7)-1)) {
            upOrdown = YES;
        }

    }else {
        num --;
        _lineIV.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - self.view.layer.bounds.size.width * 0.7)/2, self.view.layer.bounds.size.height * 0.25 + 2 * num, self.view.layer.bounds.size.width * 0.7, 5);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}
        //手电筒的开和关
- (void)lightOnOrOff:(UIButton *)sender {
    sender.selected = !sender.selected;

    if (sender.selected) {
        [self turnOnLed:YES];
    }
    else {
        [self turnOffLed:YES];
    }
}

        //打开手电筒
- (void) turnOnLed:(bool)update {
    [self.captureDevice lockForConfiguration:nil];
    [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
    [self.captureDevice unlockForConfiguration];
}
        //关闭手电筒
- (void) turnOffLed:(bool)update {
    [self.captureDevice lockForConfiguration:nil];
    [self.captureDevice setTorchMode: AVCaptureTorchModeOff];
    [self.captureDevice unlockForConfiguration];
}
#pragma mark - 删除timer
- (void)deleteTimer
    {
  if (timer) {
      [timer invalidate];
      timer=nil;
  }
    }
#pragma mark - 创建timer
- (void)creatTimer
    {
  if (!timer) {
      timer=[NSTimer scheduledTimerWithTimeInterval:0.015 target:self selector:@selector(animation) userInfo:nil repeats:YES];
  }
    }
#pragma mark - 获取图片
- (UIImage *)getImageName:(NSString *)name {
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"ScannerBundle" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}
    @end
