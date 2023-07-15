//
//  RegisterVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/13.
//

#import "RegisterVC.h"
#import "LabelTextFieldItemView.h"
#import "PasswordItemView.h"
#import "CodeItemView.h"
#import "TTWebVC.h"
#import "BRPickerView.h"
#import "SettingDepartmentVC.h"

@interface RegisterVC ()<UITextFieldDelegate, TTActionSheetDelegate, CodeItemViewDelegate, SettingDepartmentViewDelegate>

@property (retain, nonatomic) UIScrollView      *scrollView;

@property (retain, nonatomic) UIImageView       *imageViewBg;
@property (retain, nonatomic) UIButton          *buttonBack;
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewInvite;//邀请码
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewName;//姓名
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewSex;//性别
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewBirthDay;//生日
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewArea;//姓名
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewCompany;//企业（医院）
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewDepartent;//部门（科室）
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewTechnical;//职称
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewPhone;//手机
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewEmail;//邮箱
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewSchool;//院校

@property (retain, nonatomic) LabelTextFieldItemView  *itemViewProfessional;//专业
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewClass;//班级
@property (retain, nonatomic) LabelTextFieldItemView  *itemViewStudentNumber;//学号

@property (retain, nonatomic) PasswordItemView  *itemViewPassword;//密码
@property (retain, nonatomic) CodeItemView      *itemViewCode;//验证码
@property (retain, nonatomic) UITextField       *currentTextField;

@property (retain, nonatomic) UIButton                         *btnAgree;
@property (retain, nonatomic) YYLabel                          *yyLabel;
@property (retain, nonatomic) UIButton                          *buttonRegister;

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self initView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)actionSettingDepartmentCallback:(NSString *)string{
    self.itemViewDepartent.textFieldInfo.text = string;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField.tag == 1000 || textField.tag == 1001) {
        if (string.length == 0) return YES;
        //第一个参数，被替换字符串的range，第二个参数，即将键入或者粘贴的string，返回的textfield的新的文本内容
        NSString *checkStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //正则表达式
        NSString *regex = @"^[0-9]+$";
        return [Tools validateStr:checkStr withRegex:regex];
    } else if(textField.tag == 999) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>24){
            [self.view makeToast:@"您的姓名过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    } else if (textField.tag == 510 || textField.tag == 511 || textField.tag == 512 || textField.tag == 514 || textField.tag == 515) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>64){
            [self.view makeToast:@"你输入的内容过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    } else if (textField.tag == 513 || textField.tag == 516) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>32){
            [self.view makeToast:@"你输入的内容过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    }
    return YES;
}

- (void)actionGetCode:(UIButton *)button{
    if(!self.btnAgree.selected) {
        [self.view makeToast:@"请先阅读并同意用户协议" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *phone = self.itemViewPhone.textFieldInfo.text;
    if(![Tools IsPhoneNumber:phone]){
        [self.view makeToast:@"请输入正确的手机号" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"org"] = self.org;
    params[@"phone"] = phone;
    params[@"role"] = [@(self.teachRole) stringValue];
    __weak typeof(self) wself = self;
    [Tools showWithStatus:@"正在获取验证码"];
    [TTRequestManager userSmsVerCodeRegister:params success:^(id  _Nonnull responseObject) {
        //NSLog(<#NSString * _Nonnull format, ...#>)
        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            [wself.itemViewCode showTimer];
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)actionRegister:(UIButton *)button {
    NSString *invite = self.itemViewInvite.textFieldInfo.text;//邀请码
    if(self.loginType != login_type_personal) {
        if([Tools isBlankString:invite]) {
            [self.view makeToast:@"请输入您的邀请码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        
    }
    NSString *name = self.itemViewName.textFieldInfo.text;//姓名
    if([Tools isBlankString:name]) {
        [self.view makeToast:@"请输入您的姓名" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *sex = self.itemViewSex.textFieldInfo.text;//性别
    if([Tools isBlankString:sex]) {
        [self.view makeToast:@"请选择您的性别" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *birthday = self.itemViewBirthDay.textFieldInfo.text;//生日
    if([Tools isBlankString:birthday] && self.loginType == login_type_personal) {
        [self.view makeToast:@"请选择您的生日" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *school = self.itemViewSchool.textFieldInfo.text;//学校
    NSString *professional = self.itemViewProfessional.textFieldInfo.text;//专业
    NSString *classs = self.itemViewClass.textFieldInfo.text;//班级
    NSString *studentNumber = self.itemViewStudentNumber.textFieldInfo.text;//学号
    if(self.loginType == login_type_teaching) {
        if(self.teachRole == Teacher_role) {
            if([Tools isBlankString:school]) {
                [self.view makeToast:@"请输入您的院校" duration:showToastViewWarmingTime position:CSToastPositionCenter];
                return;
            }
        } else {
            if([Tools isBlankString:professional]) {
                [self.view makeToast:@"请输入您的专业" duration:showToastViewWarmingTime position:CSToastPositionCenter];
                return;
            } else if([Tools isBlankString:classs]) {
                [self.view makeToast:@"请输入您的班级" duration:showToastViewWarmingTime position:CSToastPositionCenter];
                return;
            } else if([Tools isBlankString:studentNumber]) {
                [self.view makeToast:@"请输入您的学号" duration:showToastViewWarmingTime position:CSToastPositionCenter];
                return;
            }
        }
    }
    
    NSString *phone = self.itemViewPhone.textFieldInfo.text;//手机号
    if(![Tools IsPhoneNumber:phone]) {
        [self.view makeToast:@"请输入正确的手机号" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *email = self.itemViewEmail.textFieldInfo.text;//邮箱
    if(![Tools IsEmail:email]) {
        [self.view makeToast:@"请输入正确的邮箱" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *password = self.itemViewPassword.textFieldPass.text;//登录密码
    if([Tools isBlankString:password]) {
        [self.view makeToast:@"请输入您的登录密码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *code = self.itemViewCode.textFieldCode.text;//验证码
    if(![Tools checkCodeNumber:code]) {
        [self.view makeToast:@"请输入正确的验证码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *area = self.itemViewArea.textFieldInfo.text;//地区
    NSString *company = self.itemViewCompany.textFieldInfo.text;//公司
    NSString *technical = self.itemViewTechnical.textFieldInfo.text;//职称
    NSString *departent = self.itemViewDepartent.textFieldInfo.text;//部门
    NSString *saltPassword = [NSString stringWithFormat:@"%@%@%@", saltnum1, password, saltnum2];
    NSString *md5Password = [Tools md5:saltPassword];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"org"] = self.org;
    params[@"role"] = [@(self.teachRole) stringValue];
    params[@"phone"] = phone;
    params[@"email"] = email;
    params[@"ver_code"] = code;//验证码
    params[@"password"] = md5Password;
    NSInteger s = [sex isEqualToString:@"男"] ? 1 : 0;
    params[@"sex"] = [@(s) stringValue];
    params[@"name"] = name;
    if(self.loginType == login_type_personal) {
        params[@"birthday"] = birthday;
        params[@"company"] = company;//公司
        params[@"department"] = departent;//部门
        params[@"title"] = technical;//职称
        params[@"area"] = area;//地区
    } else if(self.loginType == login_type_teaching){
        params[@"academy"] = school;//院校
        params[@"invite_code"] = invite;//邀请码
        if(self.teachRole == Teacher_role) {
            
            params[@"company"] = company;//公司
            params[@"department"] = departent;//部门
            params[@"title"] = technical;//职称
        } else {
            params[@"major"] = professional;//专业
            params[@"class_"] = classs;//班级
            params[@"number"] = studentNumber;//学号
        }
    } else if(self.loginType == login_type_union) {
        params[@"invite_code"] = invite;//邀请码
        params[@"company"] = company;//公司
        params[@"department"] = departent;//部门
        params[@"title"] = technical;//职称
    }
    __weak typeof(self) wself = self;
    [Tools showWithStatus:@"正在注册"];
    [TTRequestManager userRegister:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                [wself.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
    
}


- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    self.itemViewSex.textFieldInfo.text = (index == man) ? @"女" : @"男";
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.currentTextField = textField;
    if(textField == self.itemViewSex.textFieldInfo) {
        [self.view endEditing:YES];
        TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[@"男", @"女"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        actionSheet.delegate = self;
        [actionSheet showInView:self.view];
        return NO;
    } else if(textField == self.itemViewArea.textFieldInfo) {
        [self.view endEditing:YES];
        [self actionToSelectArea];
        return NO;
    } else if(textField == self.itemViewBirthDay.textFieldInfo) {
        [self.view endEditing:YES];
        [self actionToSelectBirthDay];
        return NO;
    } else if(textField == self.itemViewDepartent.textFieldInfo) {
        [self.view endEditing:YES];
        SettingDepartmentVC *settingDeparent = [[SettingDepartmentVC alloc] init];
        settingDeparent.delegate = self;
        [self.navigationController pushViewController:settingDeparent animated:YES];
        return NO;
    }
    return YES;
}



- (void)actionToSelectBirthDay{
    NSDate *minDate = [Tools dateWithYearsBeforeNow:120];
    NSDate *maxDate = [Tools dateWithYearsBeforeNow:0];
    NSString *showDate = [Tools dateToStringYMD:maxDate];
    __weak typeof(self) wself = self;
    [BRDatePickerView showDatePickerWithTitle:@"请选择您的生日" dateType:BRDatePickerModeYMD defaultSelValue:showDate minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:MainColor resultBlock:^(NSString *selectValue) {
        wself.itemViewBirthDay.textFieldInfo.text = selectValue;
    } cancelBlock:^{
        
    }];
}

- (void)actionToSelectArea{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];//[plistBundle pathForResource:@"BRCity" ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataSource = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //NSArray *dataSource = [NSArray arrayWithContentsOfFile:filePath];
    __weak typeof(self) wself = self;
    [BRAddressPickerView showAddressPickerWithShowType:BRAddressPickerModeArea dataSource:dataSource defaultSelected:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(BRProvinceModel *province, BRCityModel *city, BRAreaModel *area) {

        wself.itemViewArea.textFieldInfo.text = [NSString stringWithFormat:@"%@%@%@", province.name, city.name, area.name];

    } cancelBlock:^{
        DDLogInfo(@"点击了背景视图或取消按钮");
    }];
}

- (void)initView{

    
    [self.view addSubview:self.imageViewBg];
    [self.view addSubview:self.buttonBack];
    self.imageViewBg.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).heightIs(320.f/1280*766);
    self.buttonBack.sd_layout.leftSpaceToView(self.view, Ratio5).topSpaceToView(self.view, kStatusBarHeight).heightIs(Ratio50).widthIs(41.f*screenRatio);
    
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, kBottomSafeHeight);
    
    [self.scrollView addSubview:self.itemViewInvite];
    self.itemViewInvite.sd_layout.leftSpaceToView(self.scrollView, Ratio20).topSpaceToView(self.scrollView, Ratio11 + 0.6*screenW - kNavBarAndStatusBarHeight).rightSpaceToView(self.scrollView, Ratio20).heightIs(Ratio33);
    
    if(self.loginType == login_type_personal) {
        self.itemViewInvite.sd_layout.heightIs(0);
        self.itemViewInvite.hidden = YES;
    } else {
        
    }
    
   
    [self.scrollView addSubview:self.itemViewName];
    self.itemViewName.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewInvite, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    [self.scrollView addSubview:self.itemViewSex];
    self.itemViewSex.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewName, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    LabelTextFieldItemView *lastItemView = self.itemViewSex;
    if(self.loginType == login_type_personal) {
        [self.scrollView addSubview:self.itemViewBirthDay];
        [self.scrollView addSubview:self.itemViewArea];
        self.itemViewBirthDay.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewSex, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
        self.itemViewArea.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewBirthDay, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
        lastItemView = self.itemViewArea;
    }
    
    
    [self.scrollView addSubview:self.itemViewCompany];
    self.itemViewCompany.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(lastItemView, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    [self.scrollView addSubview:self.itemViewDepartent];
    self.itemViewDepartent.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewCompany, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    [self.scrollView addSubview:self.itemViewTechnical];
    self.itemViewTechnical.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewDepartent, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    
    lastItemView = self.itemViewTechnical;
    if(self.loginType == login_type_teaching) {
        [self.scrollView addSubview:self.itemViewSchool];
       
        
        if(self.teachRole == Student_role) {
            self.itemViewCompany.sd_layout.heightIs(0);
            self.itemViewDepartent.sd_layout.heightIs(0);
            self.itemViewTechnical.sd_layout.heightIs(0);
            self.itemViewCompany.hidden = YES;
            self.itemViewDepartent.hidden = YES;
            self.itemViewTechnical.hidden = YES;
            self.itemViewSchool.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewSex, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
            
            [self.scrollView addSubview:self.itemViewProfessional];
            [self.scrollView addSubview:self.itemViewClass];
            [self.scrollView addSubview:self.itemViewStudentNumber];
            self.itemViewProfessional.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewSchool, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
            self.itemViewClass.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewProfessional, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
            self.itemViewStudentNumber.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewClass, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
            lastItemView = self.itemViewStudentNumber;
        } else {
            self.itemViewSchool.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(lastItemView, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
            lastItemView = self.itemViewSchool;
        }
        
    }
    [self.scrollView addSubview:self.itemViewPhone];
    self.itemViewPhone.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(lastItemView, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    [self.scrollView addSubview:self.itemViewEmail];
    self.itemViewEmail.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewPhone, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    [self.scrollView addSubview:self.itemViewPassword];
    self.itemViewPassword.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewEmail, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    [self.scrollView addSubview:self.itemViewCode];
    self.itemViewCode.sd_layout.leftEqualToView(self.itemViewInvite).topSpaceToView(self.itemViewPassword, Ratio5).rightEqualToView(self.itemViewInvite).heightIs(Ratio33);
    [self initYYLabel];
    
    [self.scrollView addSubview:self.buttonRegister];
    self.buttonRegister.sd_layout.leftSpaceToView(self.scrollView, Ratio22).rightSpaceToView(self.scrollView, Ratio22).heightIs(Ratio36).topSpaceToView(self.yyLabel, Ratio15);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat maxY = CGRectGetMaxY(self.buttonRegister.frame);
        self.scrollView.contentSize = CGSizeMake(screenW, maxY + Ratio33);
       
    });
}

-(void)initYYLabel{
    [self.scrollView addSubview:self.yyLabel];
    NSString *string = @"我已阅读并同意《用户协议》与《隐私政策》";
    CGFloat width = [Tools widthForString:string fontSize:Ratio11 andHeight:Ratio15];
    self.yyLabel.sd_layout.topSpaceToView(self.itemViewCode, Ratio22).centerXIs(screenW/2+Ratio10).heightIs(Ratio15).widthIs(width);
    
    
    NSMutableAttributedString* atext=[[NSMutableAttributedString alloc]initWithString:string];
    [atext yy_setColor:MainNormal range:NSMakeRange(0, string.length)];
    NSRange range=[[atext string]rangeOfString:@"《用户协议》与《隐私政策》"];
    [atext yy_setTextHighlightRange:range color:MainColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        TTWebVC *ttWebView = [[TTWebVC alloc] init];
        ttWebView.webUrl = [NSString stringWithFormat:@"%@/protocol_privacy", hanhongServer];//[[NSBundle mainBundle] pathForResource:@"user_agreement" ofType:@"html"];
        ttWebView.webTitle = @"用户协议隐私政策";
        [self.navigationController pushViewController:ttWebView animated:YES];
    }];
    self.yyLabel.attributedText = atext;
   [self.scrollView addSubview:self.btnAgree];
    self.btnAgree.sd_layout.rightSpaceToView(self.yyLabel, 0).centerYEqualToView(self.yyLabel).heightIs(Ratio20).widthIs(Ratio20);
}

- (UIButton *)buttonRegister{
    if(!_buttonRegister){
        _buttonRegister = [[UIButton alloc] init];
        _buttonRegister.backgroundColor = MainColor;
        [_buttonRegister setTitle:@"申请注册" forState:UIControlStateNormal];
        [_buttonRegister setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonRegister.titleLabel.font = Font15;
        _buttonRegister.layer.cornerRadius = Ratio18;
        _buttonRegister.clipsToBounds = YES;
        [_buttonRegister addTarget:self action:@selector(actionRegister:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonRegister;
}

- (UIButton *)btnAgree{
    if (!_btnAgree) {
        _btnAgree = [[UIButton alloc] init];
        [_btnAgree addTarget:self action:@selector(actionToSelectAgree:) forControlEvents:UIControlEventTouchUpInside];
        [_btnAgree setImage:[UIImage imageNamed:@"check_false"] forState:UIControlStateNormal];
        [_btnAgree setImage:[UIImage imageNamed:@"check_true"] forState:UIControlStateSelected];
        _btnAgree.imageEdgeInsets = UIEdgeInsetsMake(Ratio3, Ratio3, Ratio3, Ratio3);
    }
    return _btnAgree;
}

- (YYLabel *)yyLabel{
    if (!_yyLabel) {
        _yyLabel = [[YYLabel alloc] init];
        _yyLabel.numberOfLines=0;
        _yyLabel.font = Font11;
        _yyLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _yyLabel;
}


- (void)actionToSelectAgree:(UIButton *)btn{
    btn.selected = !btn.selected;
}


- (LabelTextFieldItemView *)itemViewInvite{
    if(!_itemViewInvite) {
        _itemViewInvite = [[LabelTextFieldItemView alloc] initWithTitle:@"邀请码" bMust:YES placeholder:@"请输入邀请码"];
        _itemViewInvite.textFieldInfo.delegate = self;
        _itemViewInvite.textFieldInfo.returnKeyType = UIReturnKeyDone;
    }
    return _itemViewInvite;
}

- (LabelTextFieldItemView *)itemViewName{
    if(!_itemViewName) {
        _itemViewName = [[LabelTextFieldItemView alloc] initWithTitle:@"姓名" bMust:YES placeholder:@"请输入您的真实姓名"];
        _itemViewName.textFieldInfo.delegate = self;
        _itemViewName.textFieldInfo.tag = 999;
        _itemViewName.textFieldInfo.returnKeyType = UIReturnKeyDone;
    }
    return _itemViewName;
}

- (LabelTextFieldItemView *)itemViewBirthDay{
    if(!_itemViewBirthDay) {
        _itemViewBirthDay = [[LabelTextFieldItemView alloc] initWithTitle:@"生日" bMust:YES placeholder:@"请选择您的生日"];
        _itemViewBirthDay.textFieldInfo.delegate = self;
    }
    return _itemViewBirthDay;
}

- (LabelTextFieldItemView *)itemViewArea{
    if(!_itemViewArea) {
        _itemViewArea = [[LabelTextFieldItemView alloc] initWithTitle:@"地区" bMust:NO placeholder:@"请选择您的地区"];
        _itemViewArea.textFieldInfo.delegate = self;
    }
    return _itemViewArea;
}

- (LabelTextFieldItemView *)itemViewSchool{
    if(!_itemViewSchool) {
        _itemViewSchool = [[LabelTextFieldItemView alloc] initWithTitle:@"院校" bMust:YES placeholder:@"请输入您的院校"];
        _itemViewSchool.textFieldInfo.delegate = self;
        _itemViewSchool.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemViewSchool.textFieldInfo.tag = 512;
    }
    return _itemViewSchool;
}

- (LabelTextFieldItemView *)itemViewSex{
    if(!_itemViewSex) {
        _itemViewSex = [[LabelTextFieldItemView alloc] initWithTitle:@"性别" bMust:YES placeholder:@"请选择您的性别"];
        _itemViewSex.textFieldInfo.delegate = self;
    }
    return _itemViewSex;
}

- (LabelTextFieldItemView *)itemViewCompany{
    if(!_itemViewCompany) {
        _itemViewCompany = [[LabelTextFieldItemView alloc] initWithTitle:@"企业(医院)" bMust:NO placeholder:@"请输入您就职的企业(医院)"];
        _itemViewCompany.textFieldInfo.delegate = self;
        _itemViewCompany.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemViewCompany.textFieldInfo.tag = 510;
    }
    return _itemViewCompany;
}

- (LabelTextFieldItemView *)itemViewProfessional{
    if(!_itemViewProfessional) {
        _itemViewProfessional = [[LabelTextFieldItemView alloc] initWithTitle:@"专业" bMust:YES placeholder:@"请输入您的专业"];
        _itemViewProfessional.textFieldInfo.delegate = self;
        _itemViewProfessional.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemViewProfessional.textFieldInfo.tag = 514;
    }
    return _itemViewProfessional;
}

- (LabelTextFieldItemView *)itemViewClass{
    if(!_itemViewClass) {
        _itemViewClass = [[LabelTextFieldItemView alloc] initWithTitle:@"班级" bMust:YES placeholder:@"请输入您的班级"];
        _itemViewClass.textFieldInfo.delegate = self;
        _itemViewClass.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemViewClass.textFieldInfo.tag = 515;
    }
    return _itemViewClass;
}

- (LabelTextFieldItemView *)itemViewStudentNumber{
    if(!_itemViewStudentNumber) {
        _itemViewStudentNumber = [[LabelTextFieldItemView alloc] initWithTitle:@"学号" bMust:YES placeholder:@"请输入您的学号"];
        _itemViewStudentNumber.textFieldInfo.delegate = self;
        _itemViewStudentNumber.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemViewStudentNumber.textFieldInfo.tag = 516;
    }
    return _itemViewStudentNumber;
}

- (LabelTextFieldItemView *)itemViewDepartent{
    if(!_itemViewDepartent) {
        _itemViewDepartent = [[LabelTextFieldItemView alloc] initWithTitle:@"部门(科室)" bMust:NO placeholder:@"请选择您的部门(科室)"];
        _itemViewDepartent.textFieldInfo.delegate = self;
        _itemViewDepartent.textFieldInfo.tag = 511;
    }
    return _itemViewDepartent;
}

- (LabelTextFieldItemView *)itemViewTechnical{
    if(!_itemViewTechnical) {
        _itemViewTechnical = [[LabelTextFieldItemView alloc] initWithTitle:@"职称" bMust:NO placeholder:@"请输入您的职称"];
        _itemViewTechnical.textFieldInfo.delegate = self;
        _itemViewTechnical.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemViewTechnical.textFieldInfo.tag = 513;
    }
    return _itemViewTechnical;
}

- (LabelTextFieldItemView *)itemViewPhone{
    if(!_itemViewPhone) {
        _itemViewPhone = [[LabelTextFieldItemView alloc] initWithTitle:@"手机" bMust:YES placeholder:@"请输入您的手机号码"];
        _itemViewPhone.textFieldInfo.delegate = self;
        _itemViewPhone.textFieldInfo.keyboardType = UIKeyboardTypePhonePad;
        _itemViewPhone.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemViewPhone.textFieldInfo.tag = 1001;
    }
    return _itemViewPhone;
}

- (LabelTextFieldItemView *)itemViewEmail{
    if(!_itemViewEmail) {
        _itemViewEmail = [[LabelTextFieldItemView alloc] initWithTitle:@"邮箱" bMust:YES placeholder:@"请输入您的邮箱"];
        _itemViewEmail.textFieldInfo.delegate = self;
        _itemViewEmail.textFieldInfo.returnKeyType = UIReturnKeyDone;
    }
    return _itemViewEmail;
}

- (PasswordItemView *)itemViewPassword{
    if(!_itemViewPassword){
        _itemViewPassword = [[PasswordItemView alloc] initWithTitle:@"登录密码" bMust:YES placeholder:@"请设置您的登录密码"];
        _itemViewPassword.textFieldPass.delegate = self;
        _itemViewPassword.textFieldPass.returnKeyType = UIReturnKeyDone;
    }
    return _itemViewPassword;
}

- (CodeItemView *)itemViewCode{
    if(!_itemViewCode) {
        _itemViewCode = [[CodeItemView alloc] initWithTitle:@"验证码" bMust:YES placeholder:@"请输入验证码"];
        _itemViewCode.textFieldCode.delegate = self;
        _itemViewCode.delegate = self;
        _itemViewCode.textFieldCode.tag = 1000;
        self.currentTextField = _itemViewCode.textFieldCode;
        _itemViewCode.textFieldCode.returnKeyType = UIReturnKeyDone;
    }
    return _itemViewCode;
}

- (UIButton *)buttonBack{
    if(!_buttonBack){
        _buttonBack = [[UIButton alloc] init];
        [_buttonBack setImage:[UIImage imageNamed:@"back-white"] forState:UIControlStateNormal];
        _buttonBack.imageEdgeInsets = UIEdgeInsetsMake(Ratio5, Ratio5, Ratio5, Ratio5);
        [_buttonBack addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonBack;
}

- (void)actionBack:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImageView *)imageViewBg{
    if(!_imageViewBg){
        _imageViewBg = [[UIImageView alloc] init];
        _imageViewBg.image = [UIImage imageNamed:@"register_pic"];
    }
    return _imageViewBg;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)keyboardWillShow:(NSNotification *)notification{

    CGRect rect = [self.currentTextField.superview convertRect:self.currentTextField.frame toView:self.scrollView];//获取相对于self.view的位置
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];//获取弹出键盘的fame的value值
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];//获取键盘相对于self.view的frame ，传window和传nil是一样的
    CGFloat keyboardTop = keyboardRect.origin.y - Ratio18;
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];//获取键盘弹出动画时间值
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (keyboardTop < CGRectGetMaxY(rect)) {//如果键盘盖住了输入框
        CGFloat gap = keyboardTop - CGRectGetMaxY(rect) - 50;//计算需要网上移动的偏移量（输入框底部离键盘顶部为10的间距）
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, gap, screenW, screenH);
        }];
    } else {
        self.view.frame = CGRectMake(0, 0, screenW, screenH);
    }
}
- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];//获取键盘隐藏动画时间值
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (self.view.frame.origin.y < 0) {//如果有偏移，当影藏键盘的时候就复原
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, 0, screenW, screenH);
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _scrollView;
}

@end
