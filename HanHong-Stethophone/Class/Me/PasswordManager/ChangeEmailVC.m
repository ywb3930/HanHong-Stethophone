//
//  ChangeEmailVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/20.
//

#import "ChangeEmailVC.h"
#import "PasswordItemView.h"
#import "LabelTextFieldItemView.h"

@interface ChangeEmailVC ()

@property (retain, nonatomic) PasswordItemView              *itemViewPassword;
@property (retain, nonatomic) LabelTextFieldItemView              *itemViewEmail;

@end

@implementation ChangeEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    self.title = @"修改注册邮箱";
    [self initView];
}



- (void)actionToCommit:(UIBarButtonItem *)item{
    NSString *pass = self.itemViewPassword.textFieldPass.text;
    if([Tools isBlankString:pass]) {
        [self.view makeToast:@"请输入密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *email = self.itemViewEmail.textFieldInfo.text;
    if(![Tools IsEmail:email]) {
        [self.view makeToast:@"请输入正确的邮箱" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *saltPass = [NSString stringWithFormat:@"%@%@%@", saltnum1, pass, saltnum2];
    NSString *md5Pass = [Tools md5:saltPass];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"password"] = md5Pass;
    params[@"email"] = email;
    [Tools showWithStatus:@"正在修改邮箱"];
    [TTRequestManager userModifyEmail:params success:^(id  _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        if([responseObject[@"errorCode"] integerValue] == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        [self.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
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
    
    [self.view addSubview:self.itemViewPassword];
    [self.view addSubview:self.itemViewEmail];
    self.itemViewPassword.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(Ratio44);
    self.itemViewEmail.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewPassword, Ratio11).heightIs(Ratio44);
}

- (PasswordItemView *)itemViewPassword{
    if(!_itemViewPassword){
        _itemViewPassword = [[PasswordItemView alloc] initWithTitle:@"密码" bMust:NO placeholder:@"请输入密码"];
    }
    return _itemViewPassword;
}

- (LabelTextFieldItemView *)itemViewEmail{
    if(!_itemViewEmail) {
        _itemViewEmail = [[LabelTextFieldItemView alloc] initWithTitle:@"邮箱" bMust:NO placeholder:@"请输入您的邮箱"];
    }
    return _itemViewEmail;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
