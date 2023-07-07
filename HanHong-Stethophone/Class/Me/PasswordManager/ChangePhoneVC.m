//
//  ChangePhoneVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/19.
//

#import "ChangePhoneVC.h"
#import "LabelTextFieldItemView.h"
#import "PasswordItemView.h"
#import "CodeItemView.h"

@interface ChangePhoneVC ()<CodeItemViewDelegate>

@property (retain, nonatomic) PasswordItemView  *itemPass;
@property (retain, nonatomic) LabelTextFieldItemView  *itemUser;
@property (retain, nonatomic) CodeItemView      *itemCode;
@end

@implementation ChangePhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"更换注册手机";
    [self initView];
}

- (void)dealloc{
    [self.itemCode deallocView];
    
}

- (void)actionGetCode:(UIButton *)button{
    NSString *phone = self.itemUser.textFieldInfo.text;
    if(![Tools IsPhoneNumber:phone]) {
        [self.view makeToast:@"请输入正确的手机号" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"phone"] = phone;
    [Tools showWithStatus:@"正在修改手机号"];
    __weak typeof(self) wself = self;
    [TTRequestManager userSmsVerCodeModifyPhone:params success:^(id  _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        if([responseObject[@"errorCode"] integerValue] == 0) {
            [wself.itemCode showTimer];
            
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)actionToCommit:(UIButton *)button{
    NSString *phone = self.itemUser.textFieldInfo.text;
    if(![Tools IsPhoneNumber:phone]) {
        [self.view makeToast:@"请输入正确的手机号" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *pass = self.itemPass.textFieldPass.text;
    if([Tools isBlankString:pass]) {
        [self.view makeToast:@"请输入密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *code = self.itemCode.textFieldCode.text;
    if(![Tools checkCodeNumber:code]) {
        [self.view makeToast:@"请输入正确的验证码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *saltPass = [NSString stringWithFormat:@"%@%@%@", saltnum1, pass, saltnum2];
    NSString *md5Pass = [Tools md5:saltPass];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"password"] = md5Pass;
    params[@"phone"] = phone;
    params[@"ver_code"] = code;
    [Tools showWithStatus:@"正在修改密码"];
    __weak typeof(self) wself = self;
    [TTRequestManager userModifyPhone:params success:^(id  _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        if([responseObject[@"errorCode"] integerValue] == 0) {
            
            [wself.navigationController popViewControllerAnimated:YES];
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
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
    
    [self.view addSubview:self.itemUser];
    [self.view addSubview:self.itemPass];
    [self.view addSubview:self.itemCode];
    self.itemUser.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(Ratio44);
    self.itemPass.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemUser, Ratio11).heightIs(Ratio44);
    self.itemCode.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemPass, Ratio11).heightIs(Ratio44);
}

- (LabelTextFieldItemView *)itemUser{
    if(!_itemUser) {
        _itemUser = [[LabelTextFieldItemView alloc] initWithTitle:@"新手机" bMust:NO placeholder:@"请输入新的手机号码"];
    }
    return _itemUser;
}

- (PasswordItemView *)itemPass{
    if(!_itemPass){
        _itemPass = [[PasswordItemView alloc] initWithTitle:@"密码" bMust:NO placeholder:@"输入原密码"];
        //_itemPass.textFieldPass.delegate = self;
    }
    return _itemPass;
}

- (CodeItemView *)itemCode{
    if(!_itemCode) {
        _itemCode = [[CodeItemView alloc] initWithTitle:@"验证码" bMust:NO placeholder:@"请输入验证码"];
    }
    return _itemCode;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
