//
//  ChangePhoneVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import "ChangePhoneVC.h"
#import "LabelTextFieldItemView.h"
#import "PasswordItemView.h"
#import "CodeItemView.h"

@interface ChangePhoneVC ()<CodeItemViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) PasswordItemView  *itemPass;
@property (retain, nonatomic) LabelTextFieldItemView  *itemUser;
@property (retain, nonatomic) CodeItemView      *itemCode;
@end

@implementation ChangePhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"更换注册手机";
    self.view.backgroundColor = WHITECOLOR;
    [self initView];
}

- (void)dealloc{
    [self.itemCode deallocView];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 99) {
        if (string.length == 0) return YES;
        //第一个参数，被替换字符串的range，第二个参数，即将键入或者粘贴的string，返回的textfield的新的文本内容
        NSString *checkStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //正则表达式
        NSString *regex = @"^[0-9]+$";
        return [Tools validateStr:checkStr withRegex:regex];
    } else {
        return YES;
    }
    
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
        [Tools hiddenWithStatus];
        if([responseObject[@"errorCode"] integerValue] == 0) {
            [wself.itemCode showTimer];
            
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [Tools hiddenWithStatus];
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
        [Tools hiddenWithStatus];
        if([responseObject[@"errorCode"] integerValue] == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wself.navigationController popViewControllerAnimated:YES];
            });
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [Tools hiddenWithStatus];
    }];
}

- (void)initView{

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = item;
    item.action = @selector(actionToCommit:);
    
    [self.view addSubview:self.itemUser];
    [self.view addSubview:self.itemPass];
    [self.view addSubview:self.itemCode];
    self.itemUser.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(Ratio36);
    self.itemPass.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemUser, Ratio11).heightIs(Ratio36);
    self.itemCode.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemPass, Ratio11).heightIs(Ratio36);
}

- (LabelTextFieldItemView *)itemUser{
    if(!_itemUser) {
        _itemUser = [[LabelTextFieldItemView alloc] initWithTitle:@"新手机" bMust:NO placeholder:@"请输入新的手机号码"];
        _itemUser.textFieldInfo.delegate = self;
        _itemUser.textFieldInfo.keyboardType = UIKeyboardTypePhonePad;
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
        _itemCode.textFieldCode.delegate = self;
        _itemCode.textFieldCode.tag = 99;
        _itemCode.textFieldCode.keyboardType = UIKeyboardTypePhonePad;
    }
    return _itemCode;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
