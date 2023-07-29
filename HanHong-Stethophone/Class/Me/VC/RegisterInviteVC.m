//
//  RegisterInviteVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/20.
//

#import "RegisterInviteVC.h"
#import "OrgModel.h"
#import "WXApi.h"

@interface RegisterInviteVC ()

@property (retain, nonatomic) UILabel               *labelOrgName;
@property (retain, nonatomic) UILabel               *labelInviteTitle;
@property (retain, nonatomic) UILabel               *labelAppDownlod;
@property (retain, nonatomic) UIImageView           *imageViewQrCode;
@property (retain, nonatomic) UILabel               *labelInvite;
@property (retain, nonatomic) UILabel               *labelInviteNumber;
@property (retain, nonatomic) UIButton              *buttonShare;
@property (assign, nonatomic) NSInteger             loginType;

@end

@implementation RegisterInviteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
    self.view.backgroundColor = WHITECOLOR;
    self.title = @"注册邀请";
    [self setupView];
    [self initData];
}

- (void)initData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [TTRequestManager userInviteCode:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            self.labelInviteNumber.text = responseObject[@"data"][@"invite_code"];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)setupView{
    [self.view addSubview:self.labelOrgName];
    [self.view addSubview:self.labelInviteTitle];
    [self.view addSubview:self.labelAppDownlod];
    [self.view addSubview:self.imageViewQrCode];
    [self.view addSubview:self.labelInvite];
    [self.view addSubview:self.labelInviteNumber];
    [self.view addSubview:self.buttonShare];
    self.labelOrgName.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight + Ratio33).heightIs(Ratio20);
    self.labelInviteTitle.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.labelOrgName, Ratio3).heightIs(Ratio22);
    self.labelAppDownlod.sd_layout.leftSpaceToView(self.view, Ratio15).heightIs(Ratio16).topSpaceToView(self.labelInviteTitle, Ratio22).rightSpaceToView(self.view, 0);
    self.imageViewQrCode.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.labelAppDownlod, Ratio22).heightIs(Ratio135).widthIs(Ratio135);
    self.labelInvite.sd_layout.leftSpaceToView(self.view, Ratio15).heightIs(Ratio16).topSpaceToView(self.imageViewQrCode, Ratio33).rightSpaceToView(self.view, 0);
    self.labelInviteNumber.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.labelInvite, Ratio22).heightIs(Ratio22).widthIs(screenW);
    self.buttonShare.sd_layout.bottomSpaceToView(self.view, kBottomSafeHeight + Ratio33).heightIs(Ratio44).leftSpaceToView(self.view, Ratio20).rightSpaceToView(self.view, Ratio22);
    
    
    self.imageViewQrCode.image = [Tools generateQRCodeWithString:app_download_url Size:Ratio135];
    
    NSData *data;

    if(self.loginType == login_type_teaching) {
        self.labelInviteTitle.text = @"教学版注册邀请";
        data = [[NSUserDefaults standardUserDefaults] objectForKey:@"orgModelTeaching"];
    } else {
        self.labelInviteTitle.text = @"医联体注册邀请";
        data = [[NSUserDefaults standardUserDefaults] objectForKey:@"orgModelUnion"];
    }
    if(data) {
        OrgModel *model = (OrgModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.labelOrgName.text = model.name;
    }
}


- (UILabel *)labelOrgName{
    if (!_labelOrgName) {
        _labelOrgName = [[UILabel alloc] init];
        _labelOrgName.textColor = MainBlack;
        _labelOrgName.font = FontBold18;
        _labelOrgName.textAlignment = NSTextAlignmentCenter;
    }
    return _labelOrgName;
}

- (UILabel *)labelInviteTitle{
    if (!_labelInviteTitle) {
        _labelInviteTitle = [[UILabel alloc] init];
        _labelInviteTitle.textColor = MainBlack;
        _labelInviteTitle.font = FontBold18;
        _labelInviteTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _labelInviteTitle;
}

-(UILabel *)labelAppDownlod{
    if (!_labelAppDownlod) {
        _labelAppDownlod = [[UILabel alloc] init];
        _labelAppDownlod.textColor = MainBlack;
        _labelAppDownlod.font = Font15;
        _labelAppDownlod.text = @"APP下载:";
    }
    return _labelAppDownlod;
}

- (UIImageView *)imageViewQrCode{
    if (!_imageViewQrCode) {
        _imageViewQrCode = [[UIImageView alloc] init];
    }
    return _imageViewQrCode;
}

-(UILabel *)labelInvite{
    if (!_labelInvite) {
        _labelInvite = [[UILabel alloc] init];
        _labelInvite.textColor = MainBlack;
        _labelInvite.font = Font15;
        _labelInvite.text = @"邀请码:";
    }
    return _labelInvite;
}

-(UILabel *)labelInviteNumber{
    if (!_labelInviteNumber) {
        _labelInviteNumber = [[UILabel alloc] init];
        _labelInviteNumber.textColor = MainBlack;
        _labelInviteNumber.font = FontBold20;
        _labelInviteNumber.textAlignment = NSTextAlignmentCenter;
    }
    return _labelInviteNumber;
}

- (UIButton *)buttonShare{
    if (!_buttonShare) {
        _buttonShare = [[UIButton alloc] init];
        _buttonShare.backgroundColor = MainColor;
        [_buttonShare setTitle:@"分享邀请码" forState:UIControlStateNormal];
        [_buttonShare setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonShare.titleLabel.font = Font15;
        _buttonShare.layer.cornerRadius = Ratio22;
        _buttonShare.clipsToBounds = YES;
        [_buttonShare addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonShare;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (UIImage *)captureScreenshot:(CGRect)frame{
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);

    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
    }

    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenshot;
}

- (void)actionShare:(UIButton *)button{
    //[Tools showWithStatus:@"正在分享"];
    
    CGFloat maxY = CGRectGetMinY(self.buttonShare.frame);
    UIImage *screenshot = [self captureScreenshot:CGRectMake(0, kNavBarAndStatusBarHeight, screenW, maxY - Ratio11 - kNavBarAndStatusBarHeight)];
    
    //UIImage *image = [UIImage imageNamed:@"yourImage"]; // 要分享的图片

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[screenshot] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];

    // 将截屏图片分享至微信
//    NSData *imageData = UIImagePNGRepresentation(screenshot);
//    WXMediaMessage *message = [WXMediaMessage message];
//    [message setThumbImage:screenshot]; // 设置缩略图
//    WXImageObject *imageObject = [WXImageObject object];
//    imageObject.imageData = imageData;
//    message.mediaObject = imageObject;
//
//    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
//    req.bText = NO;
//    req.message = message;
//    req.scene = WXSceneSession; // 分享至微信好友
//
//    [WXApi sendReq:req completion:^(BOOL success) {
//        [Tools hiddenWithStatus];
//    }];
}

@end
