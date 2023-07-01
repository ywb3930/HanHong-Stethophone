//
//  KSImagePickerCameraCell.m
//  kinsun
//
//  Created by kinsun on 2018/12/3.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSImagePickerCameraCell.h"
#import <AVKit/AVKit.h>

@implementation KSImagePickerCameraCell {
    AVCaptureSession *_captureSession;
    __weak AVCaptureVideoPreviewLayer *_previewLayer;
    
    UIView *_maskView;
}

- (void)initView {
    UIView *contentView = self.contentView;

#if !TARGET_IPHONE_SIMULATOR
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    if ([captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
        captureSession.sessionPreset = AVCaptureSessionPresetLow;
    }
    _captureSession = captureSession;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].firstObject;
    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [contentView.layer addSublayer:previewLayer];
    _previewLayer = previewLayer;

#endif
    
    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = HEXCOLOR(0xFFFFFF, 0.1);
    maskView.hidden = NO;
    maskView.frame = self.bounds;
    [self addSubview:maskView];
    _maskView = maskView;
    
    [super initView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = [UIImage imageNamed:@"shot_img"];
    [self addSubview:imageView];
    imageView.frame = CGRectMake(self.frame.size.width/2-Ratio33, Ratio22, Ratio66, 54.f*screenRatio);
    //imageView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3f];
    
    UILabel *lbl = [UILabel new];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = Font15;
    lbl.textColor = WHITECOLOR;
    [self addSubview:lbl];
    lbl.text = @"拍摄";
    lbl.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio15).topSpaceToView(imageView, Ratio13);

#if !TARGET_IPHONE_SIMULATOR
    [captureSession startRunning];
#endif
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _maskView.frame = self.contentView.bounds;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    _previewLayer.frame = self.contentView.layer.bounds;
}

- (void)setLoseFocus:(BOOL)loseFocus {
    [super setLoseFocus:loseFocus];
    _maskView.hidden = !loseFocus;
    self.imageView.alpha = loseFocus ? 0.5f : 1.f;
}

- (void)dealloc {
    [_captureSession stopRunning];
}

@end
