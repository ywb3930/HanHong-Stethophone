//
//  AboutUsVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/20.
//

#import "AboutUsVC.h"

@interface AboutUsVC ()

@property (retain, nonatomic) UIImageView           *imageViewLogo;
@property (retain, nonatomic) UILabel               *labelVersion;
@property (retain, nonatomic) UIImageView           *imageViewOrgInfo;
@property (retain, nonatomic) UIScrollView          *scrollView;

@end

@implementation AboutUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"关于我们";
    self.view.backgroundColor = WHITECOLOR;
    [self setupView];
    [self getData];
}

- (void)getData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [TTRequestManager orgInfo:params success:^(id  _Nonnull responseObject) {
        if([responseObject[@"errorCode"] integerValue] == 0) {
            NSString *imagePath = responseObject[@"data"][@"org_info"];
            [self showOrgInfo:imagePath];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)showOrgInfo:(NSString *)url {
    __weak typeof(self) wself = self;
    [self.imageViewOrgInfo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageWaitStoreCache completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        CGFloat height = (screenW - Ratio40 ) * image.size.height / image.size.width;
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.imageViewOrgInfo.sd_layout.leftSpaceToView(wself.scrollView, 0).topSpaceToView(wself.scrollView, 0).rightSpaceToView(wself.scrollView, 0).heightIs(height);
            wself.scrollView.contentSize = CGSizeMake(screenW, height);
        });
    }];

}

- (void)setupView{
    [self.view addSubview:self.imageViewLogo];
    [self.view addSubview:self.labelVersion];
    self.imageViewLogo.sd_layout.centerXEqualToView(self.view).widthIs(Ratio77).heightIs(Ratio77).topSpaceToView(self.view, kNavBarAndStatusBarHeight + Ratio22);
    self.labelVersion.sd_layout.centerXEqualToView(self.imageViewLogo).topSpaceToView(self.imageViewLogo, Ratio11).heightIs(Ratio15).widthIs(screenW);
    self.labelVersion.text = [NSString stringWithFormat:@"软件版本：V%@", [Tools getAppVersion]];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageViewOrgInfo];
    self.scrollView.sd_layout.leftSpaceToView(self.view, Ratio20).rightSpaceToView(self.view, Ratio20).topSpaceToView(self.labelVersion, Ratio11).bottomSpaceToView(self.view, kBottomSafeHeight);
}

- (UILabel *)labelVersion{
    if (!_labelVersion) {
        _labelVersion = [[UILabel alloc] init];
        _labelVersion.textAlignment = NSTextAlignmentCenter;
        _labelVersion.font = Font13;
        _labelVersion.textColor = MainBlack;
    }
    return _labelVersion;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIImageView *)imageViewLogo{
    if(!_imageViewLogo) {
        _imageViewLogo = [[UIImageView alloc] init];
        _imageViewLogo.image = [UIImage imageNamed:@"icon"];
        _imageViewLogo.layer.cornerRadius = Ratio8;
        _imageViewLogo.clipsToBounds = YES;
    }
    return _imageViewLogo;
}

- (UIImageView *)imageViewOrgInfo{
    if(!_imageViewOrgInfo) {
        _imageViewOrgInfo = [[UIImageView alloc] init];
        _imageViewOrgInfo.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageViewOrgInfo;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
