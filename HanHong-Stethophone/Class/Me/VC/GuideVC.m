//
//  GuideVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/8.
// s/h = 720/2353

#import "GuideVC.h"

@interface GuideVC ()

@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UIImageView   *imageView;

@end

@implementation GuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"蓝牙连接指引";
    [self setupView];
}

- (void)setupView{
    CGFloat height = 2353.f * screenW / 720.f;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, kBottomSafeHeight);
    self.imageView.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).topSpaceToView(self.scrollView, 0).heightIs(height);
    self.scrollView.contentSize = CGSizeMake(screenW, height);
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"connection_guide"];
    }
    return _imageView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
