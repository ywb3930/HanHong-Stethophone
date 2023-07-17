//
//  LoginVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/13.
//

#import "LoginVC.h"
#import "LoginTypeVC.h"
#import "RegisterVC.h"
#import "LabelTextFieldItemView.h"
#import "PasswordItemView.h"
#import "CodeItemView.h"
#import "SelectOrgVC.h"
#import "OrgModel.h"
#import "ForgetPasswordVC.h"
#import "RightDirectionView.h"
//#import "ShareDataModel.h"

@interface LoginVC ()<CodeItemViewDelegate, SelectOrgVCDelegate, UITextFieldDelegate>

@property (retain, nonatomic) UIImageView      *imageViewIcon;
@property (retain, nonatomic) UILabel          *labelWelcome;
@property (retain, nonatomic) UIButton         *buttonLoginType;

@property (retain, nonatomic) UIButton         *buttonLoginPass;
@property (retain, nonatomic) UIView           *viewLinePass;
@property (retain, nonatomic) UIButton         *buttonLoginCode;
@property (retain, nonatomic) UIView           *viewLineCode;

@property (retain, nonatomic) LabelTextFieldItemView  *itemUser;
@property (strong, nonatomic) PasswordItemView  *itemPass;
@property (retain, nonatomic) UIView            *viewPass;

@property (retain, nonatomic) UIView            *viewCode;
@property (retain, nonatomic) LabelTextFieldItemView  *itemCodeUser;
@property (retain, nonatomic) CodeItemView      *codeItemView;

@property (retain, nonatomic) UIButton          *buttonLogin;
@property (retain, nonatomic) UIButton          *buttonAutoLogin;
@property (retain, nonatomic) UIButton          *buttonAutoLoginText;
@property (retain, nonatomic) UIButton          *buttonForgetPass;

@property (retain, nonatomic) UILabel           *labelNoNumber;
@property (retain, nonatomic) UIButton          *buttonRegister;

@property (assign, nonatomic) Boolean           loginTypePassword;
@property (assign, nonatomic) NSInteger         loginType;
@property (assign, nonatomic) NSInteger         teachRole;
@property (assign, nonatomic) NSInteger         org_type;

@property (retain, nonatomic) RightDirectionView *viewUnionType;
@property (retain, nonatomic) OrgModel          *orgModel;
@property (assign, nonatomic) Boolean           autoLogin;

@property (assign, nonatomic) NSInteger         delay;
@property (assign, nonatomic) Boolean          canBAutoLogin;//判断是否满足自动登录条件

//@property (retain, nonatomic) ShareDataModel    *shareDataModel;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delay = 0;
    self.canBAutoLogin = NO;//判断是否可以自动登录
    
    self.view.backgroundColor = WHITECOLOR;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionGetLoginType:) name:login_type_broadcast object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecordShareBeforeLogin:) name:record_share_before_login object:nil];
    self.loginTypePassword = YES;
    NSInteger loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
    if(loginType == 0) {
        self.loginType = login_type_personal;
        self.teachRole = CommUser_role;
        self.org_type = org_type_personal;
        [[NSUserDefaults standardUserDefaults] setInteger:login_type_personal forKey:@"login_type"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.loginType = loginType;
        self.teachRole = [[NSUserDefaults standardUserDefaults] integerForKey:@"teach_role"];
        self.org_type = [[NSUserDefaults standardUserDefaults] integerForKey:@"org_type"];
    }


    self.autoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_login"];
    //self.autoLogin = YES;
    [self initView];
    [self reloadView:YES];
    

//    self.itemUser.textFieldInfo.text = @"18902400417";
//    self.itemPass.textFieldPass.text = @"123456";
    

}

//- (void)actionRecordShareBeforeLogin:(NSNotification *)notification{
//    NSDictionary *data = notification.userInfo;
//    self.shareDataModel = (ShareDataModel *)data[@"model"];
//}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField.tag != 1000) {
        return YES;
    }
    if (string.length == 0) return YES;
    //第一个参数，被替换字符串的range，第二个参数，即将键入或者粘贴的string，返回的textfield的新的文本内容
    NSString *checkStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //正则表达式
    NSString *regex = @"^[0-9]+$";
    return [Tools validateStr:checkStr withRegex:regex];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
   // [self.itemPass.textFieldPass becomeFirstResponder];
    return YES;
}

- (void)actionAutoLogin:(UIButton *)button {
    button.selected = !button.selected;
    self.autoLogin = button.selected;
    //self.canBAutoLogin = self.autoLogin;
    [[NSUserDefaults standardUserDefaults] setBool:button.selected forKey:@"auto_login"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)actionForgetPass:(UIButton *)button{
    ForgetPasswordVC *forgetPassword = [[ForgetPasswordVC alloc] init];
    if(self.loginType == login_type_personal) {
        forgetPassword.org = @"hanhong";
    } else {
        forgetPassword.org = self.orgModel.code;
    }
    forgetPassword.role = self.teachRole;
    [self.navigationController pushViewController:forgetPassword animated:YES];
}

- (void)actionSelectItem:(OrgModel *)model{
    self.orgModel = model;

    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:model];
    if(self.org_type == org_type_union) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"orgModelUnion"];
    } else if(self.org_type == org_type_teaching) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"orgModelTeaching"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.viewUnionType.labelInfo.text = model.name;
}

- (void)actionSelectOrg:(UITapGestureRecognizer *)tap {
    SelectOrgVC *orgVC = [[SelectOrgVC alloc] init];
    orgVC.org_type = self.org_type;
    orgVC.delegate = self;
    [self.navigationController pushViewController:orgVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)actionToRegister:(UIButton *)button{
    if(self.loginType == login_type_teaching && !self.orgModel) {
        [self.view makeToast:@"请先选择院校" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    } else if(self.loginType == login_type_union && !self.orgModel) {
        [self.view makeToast:@"请先选择医院" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    RegisterVC *registerVC = [[RegisterVC alloc] init];
    registerVC.teachRole = self.teachRole;
    registerVC.loginType = self.loginType;
    if(self.loginType == login_type_personal) {
        registerVC.org = @"hanhong";
    } else {
        registerVC.org = self.orgModel.code;
    }
    
    [self.navigationController pushViewController:registerVC animated:YES];
}


- (void)reloadView:(Boolean)bLogin{
    if(self.loginType == login_type_personal) {
        [self.buttonLoginType setTitle:@"（个人版）" forState:UIControlStateNormal];
        self.buttonLoginType.sd_layout.widthIs(Ratio77);
        self.buttonLogin.sd_layout.topSpaceToView(self.viewPass, Ratio44);
        self.viewUnionType.hidden = YES;
        [self.buttonLogin updateLayout];
    } else if(self.loginType == login_type_union) {
        [self.buttonLoginType setTitle:@"（医联体）" forState:UIControlStateNormal];
        self.buttonLoginType.sd_layout.widthIs(Ratio77);
        self.buttonLogin.sd_layout.topSpaceToView(self.viewPass, Ratio77);
       // self.buttonLogin.hidden = YES;
        self.viewUnionType.hidden = NO;
        self.viewUnionType.labelName.text = @"医院";
        if(self.orgModel.type == org_type_union) {
            self.viewUnionType.labelInfo.text = self.orgModel.name;
        } else {
            self.viewUnionType.labelInfo.text = @"";
        }
       
        [self.buttonLogin updateLayout];
       
    } else if(self.loginType == login_type_teaching) {
        NSString *title = @"教学版";
        self.loginType = login_type_teaching;
        self.org_type = org_type_teaching;
        if (self.teachRole == Teacher_role) {
            title = [NSString stringWithFormat:@"（%@-教授）",title];
        } else if (self.teachRole == Student_role) {
            title = [NSString stringWithFormat:@"（%@-学生）", title];
        }
        [self.buttonLoginType setTitle:title forState:UIControlStateNormal];
        self.buttonLoginType.sd_layout.widthIs(110.f*screenRatio);
        self.buttonLogin.sd_layout.topSpaceToView(self.viewPass, Ratio77);
        self.viewUnionType.hidden = NO;
        self.viewUnionType.labelName.text = @"院校";
        if(self.orgModel.type == org_type_teaching) {
            self.viewUnionType.labelInfo.text = self.orgModel.name;
        } else {
            self.viewUnionType.labelInfo.text = @"";
        }
        //self.viewUnionType.labelInfo.text = self.orgModel.name;
    }
    
    NSData *data;
    Boolean bNull = NO;
    if(self.org_type == org_type_union) {
        data = [[NSUserDefaults standardUserDefaults] objectForKey:@"orgModelUnion"];
    } else if(self.org_type == org_type_teaching) {
        data = [[NSUserDefaults standardUserDefaults] objectForKey:@"orgModelTeaching"];
    } else {
        bNull = YES;
    }
    if (bNull) {
        self.viewUnionType.labelInfo.text = @"";
    } else if(data) {
        self.orgModel = (OrgModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.viewUnionType.labelInfo.text = self.orgModel.name;
    }
    
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    if(dic) {
        NSString *type = dic[@"type"];
        NSString *loginType = dic[@"login-type"];
        if([type isEqualToString:@"password"] && [loginType integerValue] == self.loginType) {
            NSString *number = dic[@"number"];
            NSString *password = dic[@"password"];
            self.itemUser.textFieldInfo.text = number;
            //self.itemPass.textFieldPass.text = password;
            if(self.autoLogin && bLogin && ![Tools isBlankString:number] && ![Tools isBlankString:password]) {
                self.canBAutoLogin = YES;
                self.delay = 0;
                [self actionLogin:self.buttonLoginPass];
            } else {
                self.canBAutoLogin = NO;
            }
        } else if([type isEqualToString:@"code"] && [loginType integerValue] == self.loginType) {
            self.itemCodeUser.textFieldInfo.text = dic[@"number"];
            self.canBAutoLogin = NO;
        }
    }
    
   
    
}

- (void)actionGetLoginType:(NSNotification *)noti{
    NSDictionary *info = noti.userInfo;
    NSInteger loginType =  [info[@"login_type"] integerValue];
    
    if(loginType == login_type_personal) {

        self.org_type = org_type_personal;
        self.loginType = login_type_personal;
        self.teachRole = CommUser_role;
    } else if(loginType == login_type_union) {

        self.teachRole = Union_role;
        self.org_type = org_type_union;
        self.loginType = login_type_union;
    } else if(loginType == login_type_teaching) {
        NSInteger teachRole = [info[@"teaching_role"] integerValue];
        self.teachRole = teachRole;
        self.loginType = login_type_teaching;
        self.org_type = org_type_teaching;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:self.teachRole forKey:@"teach_role"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.loginType forKey:@"login_type"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.org_type forKey:@"org_type"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([NSThread isMainThread]) {
        [self reloadView:NO];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self reloadView:NO];
        });
    }

    
}

- (void)actionToLoginType:(UIButton *)button {
    LoginTypeVC *loginType = [[LoginTypeVC alloc] init];
    [self.navigationController pushViewController:loginType animated:YES];
}

- (void)actionLogin:(UIButton *)button{
    [self.view endEditing:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *user = @"";
    if(self.loginTypePassword) {
        user = self.itemUser.textFieldInfo.text;
    } else {
        user = self.itemCodeUser.textFieldInfo.text;
    }
    if([Tools IsEmail:user]) {
        params[@"email"] = user;
    } else if([Tools IsPhoneNumber:user]) {
        params[@"phone"] = user;
    } else {
        [self.view makeToast:@"请输入正确的手机号或邮箱" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    
    if(self.loginTypePassword) {
        NSString *pass = @"";
        if(self.canBAutoLogin) {
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
            pass = dic[@"password"];
//            if ([Tools isBlankString:pass]) {
//                pass = self.itemPass.textFieldPass.text;
//               if([Tools isBlankString:pass]) {
//                   [self.view makeToast:@"请输入密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
//                   return;
//               }
//            }
        } else {
             pass = self.itemPass.textFieldPass.text;
            if([Tools isBlankString:pass]) {
                [self.view makeToast:@"请输入密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
                return;
            }
        }
       // pass = self.itemPass.textFieldPass.text;
        NSString *passwordString = [NSString stringWithFormat:@"%@%@%@", saltnum1, pass, saltnum2];
        NSString *password = [Tools md5:passwordString];
        params[@"password"] = password;
       NSLog(@"phone = %@, pas = %@", user, pass);
        
    } else {
        NSString *code= self.codeItemView.textFieldCode.text;
        if([Tools checkCodeNumber:code]) {
            params[@"ver_code"] = code;
        } else {
            [self.view makeToast:@"请输入正确的验证码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }

    if(self.loginType == login_type_personal) {
        params[@"org"] = @"hanhong";
    } else {
        if(self.org_type != self.orgModel.type) {
            NSString *message = [NSString stringWithFormat:@"请选择%@",self.org_type == org_type_union ? @"医院" : @"院校"];
            [self.view makeToast:message duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        params[@"org"] = self.orgModel.code;
    }
    params[@"force"] = @"1";
    params[@"role"] = [@(self.teachRole) stringValue];
    [Tools showWithStatus:@"正在登录"];
    __weak typeof(self) wself = self;
    [TTRequestManager userLogin:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            HHLoginData *loginData = [HHLoginData yy_modelWithDictionary:data];
            loginData.userID = [data[@"id"] doubleValue];
            [[HHLoginManager sharedManager] setCurrentHHLoginData:loginData];
            
            if (wself.loginType == login_type_personal) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:login_broadcast object:nil userInfo:@{@"type":@"1"}];
                    [SVProgressHUD dismiss];
                });
                [wself createUserDocument:@"hanhong"];
            } else {
                [wself getOrgList];
            }
        } else {
            [SVProgressHUD dismiss];
        }
        [kAppWindow makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
    
}

- (void)getOrgList{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    __weak typeof(self) wself = self;
    [TTRequestManager orgList:params success:^(id  _Nonnull responseObject) {

        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            NSArray *data = responseObject[@"data"];
            NSArray *list = [NSArray yy_modelArrayWithClass:[OrgModel class] json:data];
            for (OrgModel *model in list) {
                if ([model.code isEqualToString:self.orgModel.code]) {
                    wself.orgModel = model;
                    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:model];
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"orgModelLogin"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:login_broadcast object:nil userInfo:@{@"type":@"1"}];
                        [SVProgressHUD dismiss];
                    });
                    
                    [wself createUserDocument:model.code];
                    return;
                }
            }
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)createUserDocument:(NSString *)code{
    [HHFileLocationHelper getAppDocumentPath:code];
    NSString *pathUser = [NSString stringWithFormat:@"%@/%li",code, LoginData.userID];
    [HHFileLocationHelper getAppDocumentPath:pathUser];
    
    NSString *pathUserDB = [NSString stringWithFormat:@"%@/db",pathUser];
    [HHFileLocationHelper getAppDocumentPath:pathUserDB];
    
    NSString *pathUserAudio = [NSString stringWithFormat:@"%@/audio",pathUser];
    [HHFileLocationHelper getAppDocumentPath:pathUserAudio];
    [[NSUserDefaults standardUserDefaults] setObject:pathUser forKey:@"pathUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [Constant shareManager].userInfoPath = pathUser;
    [self saveUserInfo];
    
    NSString *filePath = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setObject:[@(NO) stringValue] forKey:@"auto_connect_echometer"];//自动连接
        [data setObject:[@(NO) stringValue] forKey:@"auscultation_sequence"];//录音顺序开关
        [data setObject:@"15" forKey:@"record_duration"];//录音时长
        [data setObject:@"60" forKey:@"remote_record_duration"];//远程录音时长
        [data setObject:@"1" forKey:@"battery_version"];//电池信号
        [data setObject:[@(open_filtration) stringValue] forKey:@"is_filtration_record"];//滤波
        [data setObject:[@(heart_sounds) stringValue] forKey:@"quick_record_default_type"];//快速录音类型
        [data writeToFile:filePath atomically:YES];
        //[[NSUserDefaults standardUserDefaults] setObject:data forKey:@""];
    }
   
}

- (void)saveUserInfo {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if(!self.loginType) {
        params[@"type"] = @"code";
        params[@"number"] = self.itemCodeUser.textFieldInfo.text;
    } else {
        params[@"type"] = @"password";
        params[@"number"] = self.itemUser.textFieldInfo.text;
        if (!self.canBAutoLogin) {
            params[@"password"] = self.itemPass.textFieldPass.text;
        } else {
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
            NSString *pass = dic[@"password"];
            params[@"password"] = pass;
        }
        
        params[@"login-type"] = [@(self.loginType) stringValue];
        params[@"teach-type"] = [@(self.teachRole) stringValue];
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:params forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)actionGetCode:(UIButton *)button{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *user = self.itemCodeUser.textFieldInfo.text;
    if([Tools IsEmail:user]) {
        [params addEntriesFromDictionary:@{@"email": user}];
    } else if([Tools IsPhoneNumber:user]) {
        [params addEntriesFromDictionary:@{@"phone": user}];
    } else {
        [self.view makeToast:@"请输入正确的手机号或邮箱" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if(self.loginType == login_type_personal) {
        params[@"org"] = @"hanhong";
        params[@"role"] = [@(CommUser_role) stringValue];
   
    } else if (self.loginType == login_type_teaching) {
        params[@"org"] = self.orgModel.code;
        params[@"role"] = [@(self.teachRole) stringValue];
    } else {
        params[@"org"] = self.orgModel.code;
        params[@"role"] = [@(Union_role) stringValue];
    }
    
    
    __weak typeof(self) wself = self;
    
    [TTRequestManager userSmsVerCodeLogin:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            [wself.codeItemView showTimer];
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)dealloc{
    [self.codeItemView deallocView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)actionLoginPass:(UIButton *)button{
    self.buttonLoginPass.selected = YES;
    self.buttonLoginCode.selected = NO;
    self.viewLinePass.hidden = NO;
    self.viewLineCode.hidden = YES;
    self.viewPass.hidden = NO;
    self.viewCode.hidden = YES;
    self.buttonAutoLogin.hidden = NO;
    self.buttonAutoLoginText.hidden = NO;
    self.buttonForgetPass.hidden = NO;
    self.loginTypePassword = YES;
}

- (void)actionLoginCode:(UIButton *)button{
    self.buttonLoginCode.selected = YES;
    self.buttonLoginPass.selected = NO;
    self.viewLineCode.hidden = NO;
    self.viewLinePass.hidden = YES;
    self.viewCode.hidden = NO;
    self.viewPass.hidden = YES;
    self.buttonAutoLogin.hidden = YES;
    self.buttonAutoLoginText.hidden = YES;
    self.buttonForgetPass.hidden = YES;
    self.loginTypePassword = NO;
}


- (void)initView{
    [self.view addSubview:self.imageViewIcon];
    [self.view addSubview:self.labelWelcome];
    [self.view addSubview:self.buttonLoginType];
    
    self.imageViewIcon.sd_layout.leftSpaceToView(self.view, Ratio20).topSpaceToView(self.view, kStatusBarHeight + 55.f*screenRatio).heightIs(Ratio30).widthIs(Ratio30);
    self.labelWelcome.sd_layout.leftEqualToView(self.imageViewIcon).topSpaceToView(self.imageViewIcon, Ratio13).heightIs(Ratio20).autoWidthRatio(Ratio135);
    [self.labelWelcome setSingleLineAutoResizeWithMaxWidth:screenW];
    self.buttonLoginType.sd_layout.leftSpaceToView(self.labelWelcome, 0).centerYEqualToView(self.labelWelcome).heightIs(Ratio20).widthIs(Ratio82);
    
    [self.view addSubview:self.buttonLoginPass];
    [self.view addSubview:self.buttonLoginCode];
    [self.view addSubview:self.viewLinePass];
    [self.view addSubview:self.viewLineCode];
    self.buttonLoginPass.sd_layout.leftSpaceToView(self.view, Ratio20).heightIs(Ratio20).widthIs(140.f*screenRatio).topSpaceToView(self.labelWelcome,44.f*screenRatio);
    self.buttonLoginCode.sd_layout.rightSpaceToView(self.view, Ratio20).heightIs(Ratio20).widthIs(140.f*screenRatio).centerYEqualToView(self.buttonLoginPass);
    self.viewLinePass.sd_layout.centerXEqualToView(self.buttonLoginPass).heightIs(1.5f*screenRatio).topSpaceToView(self.buttonLoginPass, Ratio3).widthIs(Ratio60);
    self.viewLineCode.sd_layout.centerXEqualToView(self.buttonLoginCode).heightIs(1.5f*screenRatio).topSpaceToView(self.buttonLoginPass, Ratio3).widthIs(Ratio77);
    
    [self.view addSubview:self.viewPass];
    self.viewPass.sd_layout.leftSpaceToView(self.view, Ratio20).rightSpaceToView(self.view, Ratio20).topSpaceToView(self.buttonLoginPass, Ratio33).heightIs(Ratio88);
    
    
    [self.viewPass addSubview:self.itemUser];
    [self.viewPass addSubview:self.itemPass];
    self.itemUser.sd_layout.leftSpaceToView(self.viewPass, 0).rightSpaceToView(self.viewPass, 0).topSpaceToView(self.viewPass, Ratio11).heightIs(Ratio33);
    self.itemPass.sd_layout.leftSpaceToView(self.viewPass, 0).rightSpaceToView(self.viewPass, 0).topSpaceToView(self.itemUser, Ratio11).heightIs(Ratio33);
    
    
    [self.view addSubview:self.viewCode];
    self.viewCode.sd_layout.leftSpaceToView(self.view, Ratio20).rightSpaceToView(self.view, Ratio20).topSpaceToView(self.buttonLoginPass, Ratio33).heightIs(Ratio88);
    self.viewCode.hidden = YES;
    
    [self.viewCode addSubview:self.itemCodeUser];
    [self.viewCode addSubview:self.codeItemView];
    self.itemCodeUser.sd_layout.leftSpaceToView(self.viewCode, 0).rightSpaceToView(self.viewCode, 0).topSpaceToView(self.viewCode, Ratio11).heightIs(Ratio33);
    self.codeItemView.sd_layout.leftSpaceToView(self.viewCode, 0).rightSpaceToView(self.viewCode, 0).topSpaceToView(self.itemCodeUser, Ratio11).heightIs(Ratio33);
    
    [self.view addSubview:self.buttonLogin];
    self.buttonLogin.sd_layout.leftSpaceToView(self.view, Ratio20).rightSpaceToView(self.view, Ratio20).heightIs(Ratio36).topSpaceToView(self.viewPass, Ratio44);
    
    [self.view addSubview:self.buttonAutoLogin];
    [self.view addSubview:self.buttonAutoLoginText];
    self.buttonAutoLogin.sd_layout.leftSpaceToView(self.view, Ratio20).heightIs(Ratio22).widthIs(Ratio22).topSpaceToView(self.buttonLogin, Ratio13);
    self.buttonAutoLoginText.sd_layout.leftSpaceToView(self.buttonAutoLogin, 0).heightIs(Ratio22).widthIs(Ratio99).centerYEqualToView(self.buttonAutoLogin);
    self.buttonAutoLogin.imageEdgeInsets = UIEdgeInsetsMake(Ratio4, Ratio4, Ratio4, Ratio4);
    
    [self.view addSubview:self.buttonForgetPass];
    self.buttonForgetPass.sd_layout.rightSpaceToView(self.view, Ratio22).heightIs(Ratio22).centerYEqualToView(self.buttonAutoLoginText).widthIs(Ratio50);
    
    [self.view addSubview:self.labelNoNumber];
    [self.view addSubview:self.buttonRegister];
    self.labelNoNumber.sd_layout.widthIs(screenW/2).bottomSpaceToView(self.view, kBottomSafeHeight + Ratio11).heightIs(Ratio18).leftSpaceToView(self.view, 0);
    self.buttonRegister.sd_layout.leftSpaceToView(self.labelNoNumber, Ratio11).centerYEqualToView(self.labelNoNumber).heightIs(Ratio18).widthIs(Ratio50);
    
    [self.view addSubview:self.viewUnionType];
    self.viewUnionType.sd_layout.leftEqualToView(self.viewPass).rightEqualToView(self.viewPass).topSpaceToView(self.viewPass, Ratio11).heightIs(Ratio33);

    self.viewUnionType.hidden = YES;
}

- (RightDirectionView *)viewUnionType{
    if(!_viewUnionType) {
        _viewUnionType = [[RightDirectionView alloc] initWithTitle:@"医院"];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionSelectOrg:)];
        [_viewUnionType addGestureRecognizer:gesture];
    }
    return _viewUnionType;
}

- (UILabel *)labelNoNumber{
    if(!_labelNoNumber) {
        _labelNoNumber = [[UILabel alloc] init];
        _labelNoNumber.font = [UIFont systemFontOfSize:Ratio12];
        _labelNoNumber.textColor = MainBlack;
        _labelNoNumber.textAlignment = NSTextAlignmentRight;
        _labelNoNumber.text = @"还没有账号？";
    }
    return _labelNoNumber;
}

- (UIButton *)buttonRegister{
    if(!_buttonRegister) {
        _buttonRegister = [[UIButton alloc] init];
        [_buttonRegister setTitle:@"申请注册" forState:UIControlStateNormal];
        [_buttonRegister addTarget:self action:@selector(actionToRegister:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonRegister setTitleColor:MainColor forState:UIControlStateNormal];
        _buttonRegister.titleLabel.font = [UIFont systemFontOfSize:Ratio12];
    }
    return _buttonRegister;
}

-(UIButton *)buttonAutoLogin{
    if(!_buttonAutoLogin){
        _buttonAutoLogin = [[UIButton alloc] init];
        [_buttonAutoLogin setImage:[UIImage imageNamed:@"check_true"] forState:UIControlStateSelected];
        [_buttonAutoLogin setImage:[UIImage imageNamed:@"check_false"] forState:UIControlStateNormal];
        _buttonAutoLogin.selected = self.autoLogin;
        [_buttonAutoLogin addTarget:self action:@selector(actionAutoLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonAutoLogin;
}

- (UIButton *)buttonAutoLoginText{
    if(!_buttonAutoLoginText) {
        _buttonAutoLoginText = [[UIButton alloc] init];
        [_buttonAutoLoginText setTitle:@"我想以后自动登录" forState:UIControlStateNormal];
        [_buttonAutoLoginText addTarget:self action:@selector(actionAutoLogin:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonAutoLoginText setTitleColor:MainBlack forState:UIControlStateNormal];
        _buttonAutoLoginText.titleLabel.font = [UIFont systemFontOfSize:Ratio12];
        //_buttonAutoLoginText.selected = YES;
    }
    return _buttonAutoLoginText;
}

- (UIButton *)buttonForgetPass{
    if(!_buttonForgetPass) {
        _buttonForgetPass = [[UIButton alloc] init];
        [_buttonForgetPass setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_buttonForgetPass setTitleColor:MainBlack forState:UIControlStateNormal];
        _buttonForgetPass.titleLabel.font = [UIFont systemFontOfSize:Ratio12];
        [_buttonForgetPass addTarget:self action:@selector(actionForgetPass:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonForgetPass;
}

- (UIButton *)buttonLogin{
    if(!_buttonLogin){
        _buttonLogin = [[UIButton alloc] init];
        _buttonLogin.backgroundColor = MainColor;
        [_buttonLogin setTitle:@"登录" forState:UIControlStateNormal];
        [_buttonLogin setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonLogin.titleLabel.font = Font15;
        _buttonLogin.layer.cornerRadius = Ratio18;
        _buttonLogin.clipsToBounds = YES;
        [_buttonLogin addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonLogin;
}


- (UIView *)viewCode{
    if(!_viewCode) {
        _viewCode = [[UIView alloc] init];
    }
    return _viewCode;
}

- (LabelTextFieldItemView *)itemCodeUser{
    if(!_itemCodeUser) {
        _itemCodeUser = [[LabelTextFieldItemView alloc] initWithTitle:@"手机/邮箱" bMust:NO placeholder:@"请输入您的手机号或邮箱"];
        _itemCodeUser.textFieldInfo.delegate = self;
        _itemCodeUser.textFieldInfo.returnKeyType = UIReturnKeyDone;
    }
    return _itemCodeUser;
}

- (PasswordItemView *)itemPass{
    if(!_itemPass) {
        _itemPass = [[PasswordItemView alloc] initWithTitle:@"密码" bMust:NO placeholder:@"请输入密码"];
        _itemPass.textFieldPass.delegate = self;
        _itemPass.textFieldPass.returnKeyType = UIReturnKeyDone;
    }
    return _itemPass;
}

- (CodeItemView *)codeItemView {
    if(!_codeItemView) {
        _codeItemView = [[CodeItemView alloc] initWithTitle:@"动态密码" bMust:NO placeholder:@"请输入动态密码"];
        _codeItemView.delegate = self;
        _codeItemView.textFieldCode.delegate = self;
        _codeItemView.textFieldCode.tag = 1000;
        _codeItemView.textFieldCode.returnKeyType = UIReturnKeyDone;
    }
    return _codeItemView;
}

- (UIView *)viewPass{
    if(!_viewPass) {
        _viewPass = [[UIView alloc] init];
    }
    return _viewPass;
}

- (LabelTextFieldItemView *)itemUser{
    if(!_itemUser) {
        _itemUser = [[LabelTextFieldItemView alloc] initWithTitle:@"用户" bMust:NO placeholder:@"请输入您的手机号或邮箱"];
        _itemUser.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemUser.textFieldInfo.delegate = self;
    }
    return _itemUser;
}

- (UIImageView *)imageViewIcon{
    if(!_imageViewIcon){
        _imageViewIcon = [[UIImageView alloc] init];
        _imageViewIcon.image = [UIImage imageNamed:@"icon"];
    }
    return _imageViewIcon;
}

- (UILabel *)labelWelcome{
    if(!_labelWelcome) {
        _labelWelcome = [[UILabel alloc] init];
        _labelWelcome.text = @"欢迎使用汉泓听诊工具";
        _labelWelcome.textColor = UIColor.blackColor;
        _labelWelcome.font = [UIFont systemFontOfSize:Ratio15];
    }
    return _labelWelcome;
}

- (UIButton *)buttonLoginType{
    if(!_buttonLoginType) {
        _buttonLoginType = [[UIButton alloc] init];
        [_buttonLoginType setTitle:@"（个人版）" forState:UIControlStateNormal];
        [_buttonLoginType setTitleColor:MainColor forState:UIControlStateNormal];
        _buttonLoginType.titleLabel.font = Font13;
        [_buttonLoginType addTarget:self action:@selector(actionToLoginType:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonLoginType;
}

- (UIButton *)buttonLoginPass{
    if(!_buttonLoginPass) {
        _buttonLoginPass = [[UIButton alloc] init];
        [_buttonLoginPass setTitle:@"用户登录" forState:UIControlStateNormal];
        [_buttonLoginPass setTitleColor:MainBlack forState:UIControlStateSelected];
        [_buttonLoginPass setTitleColor:MainNormal forState:UIControlStateNormal];
        [_buttonLoginPass addTarget:self action:@selector(actionLoginPass:) forControlEvents:UIControlEventTouchUpInside];
        _buttonLoginPass.titleLabel.font = Font15;
        _buttonLoginPass.selected = YES;
    }
    return _buttonLoginPass;
}

- (UIView *)viewLinePass{
    if(!_viewLinePass) {
        _viewLinePass = [[UIView alloc] init];
        _viewLinePass.backgroundColor = MainColor;
    }
    return _viewLinePass;
}

- (UIView *)viewLineCode{
    if(!_viewLineCode) {
        _viewLineCode = [[UIView alloc] init];
        _viewLineCode.backgroundColor = MainColor;
        _viewLineCode.hidden = YES;
    }
    return _viewLineCode;
}

- (UIButton *)buttonLoginCode{
    if(!_buttonLoginCode) {
        _buttonLoginCode = [[UIButton alloc] init];
        [_buttonLoginCode setTitle:@"验证码登录" forState:UIControlStateNormal];
        [_buttonLoginCode setTitleColor:MainBlack forState:UIControlStateSelected];
        [_buttonLoginCode setTitleColor:MainNormal forState:UIControlStateNormal];
        _buttonLoginCode.titleLabel.font = Font15;
        [_buttonLoginCode addTarget:self action:@selector(actionLoginCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonLoginCode;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
