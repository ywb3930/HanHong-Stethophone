//
//  LogoffUserVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/20.
//

#import "LogoffUserVC.h"
#import "PasswordItemView.h"

@interface LogoffUserVC ()

@property (retain, nonatomic) PasswordItemView              *itemViewPassword;

@end

@implementation LogoffUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITECOLOR;
    self.title = @"注销用户";
    [self setupView];
}

- (void)actionToCommit:(UIBarButtonItem *)item {
    NSString *pass = self.itemViewPassword.textFieldPass.text;
    if([Tools isBlankString:pass]) {
        [self.view makeToast:@"请输入密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }

    NSString *saltPass = [NSString stringWithFormat:@"%@%@%@", saltnum1, pass, saltnum2];
    NSString *md5Pass = [Tools md5:saltPass];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"password"] = md5Pass;
    [Tools showWithStatus:@"正在注销用户"];
    [TTRequestManager userLogoff:params success:^(id  _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        if([responseObject[@"errorCode"] integerValue]  == 0) {
            [self.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"phone"];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [Tools logout:@""];
            }];
        } else {
            [self.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
    
}

- (void)setupView{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = item;
    item.action = @selector(actionToCommit:);
    
    [self.view addSubview:self.itemViewPassword];
    self.itemViewPassword.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.view, kNavBarAndStatusBarHeight).heightIs(Ratio44);
}

- (PasswordItemView *)itemViewPassword{
    if(!_itemViewPassword){
        _itemViewPassword = [[PasswordItemView alloc] initWithTitle:@"密码" bMust:NO placeholder:@"请输入密码"];
    }
    return _itemViewPassword;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
