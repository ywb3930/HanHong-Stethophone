//
//  ChangePasswordVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import "ChangePasswordVC.h"
#import "PasswordItemView.h"

@interface ChangePasswordVC ()<UITextFieldDelegate>

@property (retain, nonatomic) PasswordItemView  *itemViewOld;
@property (retain, nonatomic) PasswordItemView  *itemViewNew;

@end

@implementation ChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"修改密码";
    self.view.backgroundColor = WHITECOLOR;
    [self initView];
}

- (void)actionToCommit:(UIButton *)button{
    NSString *oldPass = self.itemViewOld.textFieldPass.text;
    if([Tools isBlankString:oldPass]) {
        [self.view makeToast:@"请输入原密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *newPass = self.itemViewNew.textFieldPass.text;
    if([Tools isBlankString:newPass]) {
        [self.view makeToast:@"请输入新密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *saltOldPass = [NSString stringWithFormat:@"%@%@%@", saltnum1, oldPass, saltnum2];
    NSString *saltNewPass = [NSString stringWithFormat:@"%@%@%@", saltnum1, newPass, saltnum2];
    NSString *md5OldPass = [Tools md5:saltOldPass];
    NSString *md5NewPass = [Tools md5:saltNewPass];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"password"] = md5OldPass;
    params[@"new_password"] = md5NewPass;
    [Tools showWithStatus:@"正在修改密码"];
    [TTRequestManager userModifyPassword:params success:^(id  _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        if([responseObject[@"errorCode"] integerValue] == 0) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        [self.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)initView{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = item;
    item.action = @selector(actionToCommit:);
    
    [self.view addSubview:self.itemViewOld];
    [self.view addSubview:self.itemViewNew];
    self.itemViewOld.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(Ratio36);
    self.itemViewNew.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewOld, Ratio11).heightIs(Ratio36);
}

- (PasswordItemView *)itemViewOld{
    if(!_itemViewOld){
        _itemViewOld = [[PasswordItemView alloc] initWithTitle:@"原密码" bMust:NO placeholder:@"请输入原密码"];
        _itemViewOld.textFieldPass.delegate = self;
    }
    return _itemViewOld;
}

- (PasswordItemView *)itemViewNew{
    if(!_itemViewNew){
        _itemViewNew = [[PasswordItemView alloc] initWithTitle:@"新密码" bMust:NO placeholder:@"请输入新密码"];
    }
    return _itemViewNew;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
