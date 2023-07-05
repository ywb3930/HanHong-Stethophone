//
//  ForgetPasswordVC.m
//  HM-Stethophone
//  
//  Created by Eason on 2023/6/15.
//

#import "ForgetPasswordVC.h"
#import "RegisterItemView.h"
#import "PasswordItemView.h"
#import "CodeItemView.h"

@interface ForgetPasswordVC ()<CodeItemViewDelegate>

@property (retain, nonatomic) RegisterItemView          *itemViewUser;
@property (retain, nonatomic) PasswordItemView          *itemViewPassword;
@property (retain, nonatomic) CodeItemView              *itemViewCode;

@end

@implementation ForgetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"忘记密码";
    self.view.backgroundColor = WHITECOLOR;
    [self initView];
}

- (void)actionToCommit:(UIBarButtonItem *)button{
    NSString *user = self.itemViewUser.textFieldInfo.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if([Tools IsPhoneNumber:user]) {
        params[@"phone"] = user;
    } else if([Tools IsEmail:user]) {
        params[@"email"] = user;
    } else {
        [self.view makeToast:@"请输入正确的账号" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *pass = self.itemViewPassword.textFieldPass.text;
    if([Tools isBlankString:pass]) {
        [self.view makeToast:@"请输入密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *code = self.itemViewCode.textFieldCode.text;
    if(![Tools checkCodeNumber:code]) {
        [self.view makeToast:@"请输入正确的验证码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *password = [NSString stringWithFormat:@"%@%@%@", saltnum1, pass, saltnum2];
    NSString *passwordMd5 = [Tools md5:password];
    params[@"password"] = passwordMd5;
    params[@"ver_code"] = code;
    params[@"org"] = self.org;
    params[@"role"] = [@(self.role) stringValue];
    [Tools showWithStatus:@""];
    __weak typeof(self) wself = self;
    [TTRequestManager userForgetPassword:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                    [wself.navigationController popViewControllerAnimated:YES];
                }];
            });
            
        } else {
            [wself.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

//获取验证码
- (void)actionGetCode:(UIButton *)button{
    NSString *user = self.itemViewUser.textFieldInfo.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if([Tools IsPhoneNumber:user]) {
        params[@"phone"] = user;
    } else if([Tools IsEmail:user]) {
        params[@"email"] = user;
    } else {
        [self.view makeToast:@"请输入正确的账号" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    params[@"org"] = self.org;
    params[@"role"] = [@(self.role) stringValue];
    [Tools showWithStatus:@""];
    __weak typeof(self) wself = self;
    [TTRequestManager userSmsVerCodeModifyPassword:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            [wself.itemViewCode showTimer];
            
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)initView{
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;

    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItems = @[item0,item2];
    item2.action = @selector(actionToCommit:);
 
    [self.view addSubview:self.itemViewUser];
    [self.view addSubview:self.itemViewPassword];
    [self.view addSubview:self.itemViewCode];
    self.itemViewUser.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.view, Ratio20 + kNavBarAndStatusBarHeight).heightIs(Ratio33);
    self.itemViewPassword.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewUser, Ratio11).heightIs(Ratio33);
    self.itemViewCode.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewPassword, Ratio11).heightIs(Ratio33);
}



- (RegisterItemView *)itemViewUser{
    if(!_itemViewUser) {
        _itemViewUser = [[RegisterItemView alloc] initWithTitle:@"账号" bMust:NO placeholder:@"请输入您的手机号码或邮箱"];
    }
    return _itemViewUser;
}

- (PasswordItemView *)itemViewPassword{
    if(!_itemViewPassword) {
        _itemViewPassword = [[PasswordItemView alloc] initWithTitle:@"新密码" bMust:NO placeholder:@"请输入新密码"];
    }
    return _itemViewPassword;
}

- (CodeItemView *)itemViewCode{
    if(!_itemViewCode) {
        _itemViewCode = [[CodeItemView alloc] initWithTitle:@"验证码" bMust:NO placeholder:@"请输入验证码"];
        _itemViewCode.delegate = self;
    }
    return _itemViewCode;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)dealloc{
    [self.itemViewCode deallocView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


@end
