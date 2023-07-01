//
//  ScanTeachCodeVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/26.
//
#import "ScanTeachCodeVC.h"
#import <AVFoundation/AVFoundation.h>
 
//static const float lightWidth = 300.f;
//static const float lightHeight = 300.f;
//static const float crossLineWidth = 2.f;
//static const float crossLineHeight = 15.f;
 
@interface ScanTeachCodeVC ()<AVCaptureMetadataOutputObjectsDelegate>


@property (assign, nonatomic) CGFloat       leftWith;
@property (assign, nonatomic) CGFloat       topHeight;
@property (assign, nonatomic) CGFloat       lightWidth;
@property (assign, nonatomic) CGFloat       lightHeight;
@property (assign, nonatomic) CGFloat       crossLineWidth;
@property (assign, nonatomic) CGFloat       crossLineHeight;


@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureOutput;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *capturePreview;
 
@property (strong, nonatomic) UIButton *flashLightBtn;
@property (strong, nonatomic) UIImageView *lineImageView;
@property (assign, nonatomic) Boolean isShowNavigationItem;
@property (assign, nonatomic) Boolean isRectScan;
 
@end
 
@implementation ScanTeachCodeVC

- (void)viewDidLoad {
   
    [super viewDidLoad];
    self.isShowNavigationItem = YES;
    self.lightWidth = screenW/2;
    self.lightHeight = self.lightWidth;
    self.crossLineWidth = Ratio2;
    self.crossLineHeight = Ratio15;
    
    self.leftWith = screenW / 4;
    self.topHeight = (screenH - self.lightHeight) / 2;
   
#if !TARGET_IPHONE_SIMULATOR
    [self initScanCode];
#endif
    [self initLayer];
    [self initViewControl];



    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
}
 
-(void)viewWillDisappear:(BOOL)animated {
    [self stopScanCode];
    [super viewWillDisappear:animated];
}
 
- (void)willResignActiveNotification {
    self.flashLightBtn.selected = NO;
}
- (void)didBecomeActiveNotification {
 
}
//加载界面上的控件，如：加上闪光灯按钮等
- (void)initViewControl {
    UIButton * openLightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openLightBtn.cs_imagePositionMode = ImagePositionModeTop;
    openLightBtn.cs_imageSize = CGSizeMake(Ratio44, Ratio44);
    openLightBtn.cs_middleDistance = Ratio5;
    [openLightBtn setImage:[UIImage imageNamed:@"open_flashlight_btn"] forState:UIControlStateNormal];
    [openLightBtn setTitle:@"打开手电" forState:UIControlStateNormal];
    [openLightBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    openLightBtn.titleLabel.font = Font11;
    openLightBtn.contentMode = UIViewContentModeScaleAspectFit;
    [openLightBtn addTarget:self action:@selector(systemFlashLight) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openLightBtn];
    openLightBtn.sd_layout.bottomSpaceToView(self.view, kBottomSafeHeight + Ratio22).widthIs(Ratio66).heightIs(Ratio66).centerXEqualToView(self.view);
    self.lineImageView = [[UIImageView alloc] init];
    self.lineImageView.frame = CGRectMake(self.leftWith, self.topHeight, self.lightWidth, 2);
    self.lineImageView.backgroundColor = UIColor.redColor;
    [self.view addSubview:self.lineImageView];
   [self scanLineAnimation];
   
}
 
- (void)scanLineAnimation {
    [UIView animateWithDuration:2.5f delay:0 options:UIViewAnimationOptionRepeat animations:^{
        self.lineImageView.frame = CGRectMake(self.leftWith, self.topHeight + self.lightHeight, self.lightWidth, 2);
    } completion:^(BOOL finished) {
    }];
    
}
 
- (void)insertLayerWithFrame:(CGRect)frame withBackgroundColor:(UIColor *)backgroundColor {
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = backgroundColor.CGColor;
    layer.frame = frame;
    [self.view.layer addSublayer:layer];
}
//初始化layer层，绘制半透明区域
-(void) initLayer {
    //公共参数
    UIColor *fillColor = [UIColor colorWithRed:0xae/255.f green:0xae/255.f blue:0xae/255.f alpha:0.4];
    UIColor *crossColor = [UIColor greenColor];
    [self insertLayerWithFrame:CGRectMake(0, 0, self.leftWith, screenH) withBackgroundColor:fillColor];
    [self insertLayerWithFrame:CGRectMake(self.leftWith, 0, self.lightWidth, self.topHeight) withBackgroundColor:fillColor];
    [self insertLayerWithFrame:CGRectMake(self.leftWith + self.lightWidth, 0, self.leftWith, screenH) withBackgroundColor:fillColor];
    [self insertLayerWithFrame:CGRectMake(self.leftWith, self.topHeight + self.lightHeight, self.lightWidth, self.topHeight) withBackgroundColor:fillColor];


    [self insertLayerWithFrame:CGRectMake(self.leftWith, self.topHeight, self.crossLineWidth, self.crossLineHeight) withBackgroundColor:crossColor];
    [self insertLayerWithFrame:CGRectMake(self.leftWith, self.topHeight, self.crossLineHeight, self.crossLineWidth) withBackgroundColor:crossColor];

    [self insertLayerWithFrame:CGRectMake(self.leftWith + self.lightWidth - self.crossLineHeight, self.topHeight, self.crossLineHeight, self.crossLineWidth) withBackgroundColor:crossColor];
    [self insertLayerWithFrame:CGRectMake(self.leftWith + self.lightWidth - self.crossLineWidth, self.topHeight, self.crossLineWidth, self.crossLineHeight) withBackgroundColor:crossColor];

    [self insertLayerWithFrame:CGRectMake(self.leftWith, self.topHeight + self.lightHeight - self.crossLineHeight, self.crossLineWidth, self.crossLineHeight) withBackgroundColor:crossColor];
    [self insertLayerWithFrame:CGRectMake(self.leftWith, self.topHeight + self.lightHeight - self.crossLineWidth, self.crossLineHeight, self.crossLineWidth) withBackgroundColor:crossColor];

    [self insertLayerWithFrame:CGRectMake(self.leftWith + self.lightWidth - self.crossLineHeight, self.topHeight + self.lightHeight - self.crossLineWidth, self.crossLineHeight, self.crossLineWidth) withBackgroundColor:crossColor];
    [self insertLayerWithFrame:CGRectMake(self.leftWith + self.lightWidth - self.crossLineWidth, self.topHeight + self.lightHeight - self.crossLineHeight, self.crossLineWidth, self.crossLineHeight) withBackgroundColor:crossColor];
}
 
-(void)initScanCode {
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType : AVMediaTypeVideo];
    self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice : self.captureDevice error : nil];
    self.captureOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureOutput setMetadataObjectsDelegate: self queue : dispatch_get_main_queue ()];
    if (_isRectScan) {
        [self.captureOutput setRectOfInterest : CGRectMake (self.topHeight / screenH, self.leftWith / screenW, self.lightHeight/screenH, self.lightWidth / screenW)];
    }
 
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset : AVCaptureSessionPresetHigh];
    if ([self.captureSession canAddInput : self.captureInput])
    {
        [self.captureSession addInput : self.captureInput];
    }
    if ([self.captureSession canAddOutput : self.captureOutput])
    {
        [self.captureSession addOutput : self.captureOutput];
    }
    self.captureOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode] ;
     
    self.capturePreview =[AVCaptureVideoPreviewLayer layerWithSession :self.captureSession];
    self.capturePreview.videoGravity = AVLayerVideoGravityResizeAspectFill ;
    self.capturePreview.frame = self.view.layer.bounds ;
    [self.view.layer insertSublayer : self.capturePreview atIndex : 0];
    [self.captureSession startRunning];
}
 
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *scanCodeResult;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self stopScanCode];
            scanCodeResult = metadataObj.stringValue;
            [self.view makeToast:scanCodeResult duration:showToastViewWarmingTime position:CSToastPositionCenter];
            //回调信息
            if (self.delegate && [self.delegate respondsToSelector:@selector(scanCodeResultCallback:)]) {
                [self.delegate scanCodeResultCallback:scanCodeResult];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            NSLog(@"扫描信息错误！");
        }
    }
}
 
- (void)systemFlashLight
{
#if !TARGET_IPHONE_SIMULATOR
    if([self.captureDevice hasTorch] && [self.captureDevice hasFlash])
    {
        [self.captureSession beginConfiguration];
        [self.captureDevice lockForConfiguration:nil];
        if(self.captureDevice.torchMode == AVCaptureTorchModeOff)
        {
            self.flashLightBtn.selected = YES;
            [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
            [self.captureDevice setFlashMode:AVCaptureFlashModeOn];
        }
        else {
            self.flashLightBtn.selected = NO;
            [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
            [self.captureDevice setFlashMode:AVCaptureFlashModeOff];
        }
        [self.captureDevice unlockForConfiguration];
        [self.captureSession commitConfiguration];
    }
#else
    //[CommonUtil showAlert:G_ALERTTITLE withMessage:@"虚拟设备不能运行摄像头！"];
#endif
}
 
-(void)stopScanCode {
    [self.captureSession stopRunning];
    self.captureSession = nil;
    self.captureDevice = nil;
    self.captureInput = nil;
    self.captureOutput = nil;
    [self.capturePreview removeFromSuperlayer];
}
 
- (void)didReceiveMemoryWarning {
    
}
 
@end
