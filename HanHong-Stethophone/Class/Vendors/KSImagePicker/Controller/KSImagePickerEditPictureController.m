//
//  KSImagePickerEditPictureController.m
//  kinsun
//
//  Created by kinsun on 2018/12/10.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSImagePickerEditPictureController.h"
#import "KSImagePickerEditPictureView.h"
#import "KSImagePickerItemModel.h"
#import "KSImagePickerController.h"

@interface KSImagePickerEditPictureController ()

@property (nonatomic, strong) KSImagePickerEditPictureView *view;
@property (retain, nonatomic) UIButton                  *btnRight;


@end

@implementation KSImagePickerEditPictureController
@dynamic view;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view setNeedsLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑照片";
    CGSize size = k_SCREEN_BOUNDS.size;
    __weak typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestImageForAsset:_model.asset targetSize:size contentMode:PHImageContentModeAspectFill options:KSImagePickerItemModel.pictureViewerOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.view.imageView.image = result;
    }];
    UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithCustomView:self.btnRight];
    self.navigationItem.rightBarButtonItem = barButtonRight;
}

- (void)loadView {
    KSImagePickerEditPictureView *view = [[KSImagePickerEditPictureView alloc] init];
    [view.navigationView.doneButton addTarget:self action:@selector(_didClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [view.navigationView.backButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    view.circularMask = _circularMask;
    self.view = view;
}

- (void)dismissViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_didClickDoneButton:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(imagePickerEditPicture:didFinishSelectedImage:assetModel:)]) {
        KSImagePickerEditPictureView *view = self.view;
        __block UIImage *snapshotImg = nil;
        [view snapshotWithOperation:^{
            snapshotImg = [KSImagePickerEditPictureController renderingImageInView:view];
        }];
        CGRect contentRect = view.contentRect;
        CGSize size = contentRect.size;
        CGPoint origin = contentRect.origin;
        CGFloat scale = k_SCREEN_SCALE;
        CGRect rect = (CGRect){origin.x*scale, origin.y*scale, size.width*scale, size.height*scale};
        UIImage *newimage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(snapshotImg.CGImage, rect)];
        [_delegate imagePickerEditPicture:self didFinishSelectedImage:newimage assetModel:_model];
        
        NSArray<UIViewController *> *viewControllers = self.navigationController.viewControllers;
        NSUInteger index = [viewControllers indexOfObject:_delegate];
        if (index <= 0) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIViewController *controller = [viewControllers objectAtIndex:index-1];
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

+ (UIImage *)renderingImageInView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (UIButton *)btnRight{
    if (!_btnRight) {
        _btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, Ratio55, Ratio22)];
        [_btnRight setTitle:@"完成" forState:UIControlStateNormal];
        [_btnRight setTitleColor:MainColor forState:UIControlStateNormal];
        [_btnRight addTarget:self action:@selector(_didClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
        
        //[_btnRight sizeToFit];
    }
    return _btnRight;
}


@end
