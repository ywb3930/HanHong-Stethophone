//
//  UserInfoVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import "UserInfoVC.h"
#import "UserInfoOneCell.h"
#import "UserInfoTwoCell.h"
#import "KSImagePickerController.h"
#import "KSNavigationController.h"
#import "HMEditView.h"
#import "SettingDepartmentVC.h"
#import "BRPickerView.h"

@interface UserInfoVC ()<UITableViewDelegate, UITableViewDataSource, KSImagePickerControllerDelegate, HMEditViewDelegate, UITextFieldDelegate, TTActionSheetDelegate, SettingDepartmentViewDelegate>

@property (retain, nonatomic) UITableView                   *tableView;
@property (retain, nonatomic) NSArray                       *arrayTitle;
@property (retain, nonatomic) NSArray                       *arrayInfo;
@property (retain, nonatomic) NSString                      *infoModifiable;
@property (retain, nonatomic) HMEditView                    *editView;
@property (assign, nonatomic) NSInteger                     loginType;
@end

@implementation UserInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    self.loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
    self.infoModifiable = LoginData.info_modifiable;
    if (self.loginType == login_type_personal || self.loginType == login_type_union) {
        self.arrayTitle = @[@"头像", @"姓名", @"性别", @"生日", @"地区", @"企业(医院)",@"部门(科室)", @"职称", @"邮箱", @"手机"];
        
        self.arrayInfo = @[LoginData.avatar, LoginData.name, LoginData.sex == man  ? @"男" : @"女", LoginData.birthday, LoginData.area, LoginData.company, LoginData.department, LoginData.title, LoginData.email, LoginData.phone];
    } else if(self.loginType == login_type_teaching) {
        if (LoginData.role == Teacher_role) {
            self.arrayTitle = @[@"头像", @"姓名", @"性别", @"企业(医院)",@"部门(科室)", @"职称", @"院校", @"邮箱", @"手机"];
            
            self.arrayInfo = @[LoginData.avatar, LoginData.name, LoginData.sex == man ? @"男" : @"女", LoginData.company, LoginData.department, LoginData.title, LoginData.academy, LoginData.email, LoginData.phone];
        } else if (LoginData.role == Student_role) {
            self.arrayTitle = @[@"头像", @"姓名", @"性别", @"院校", @"专业",@"班级", @"学号",  @"邮箱", @"手机"];
            
            self.arrayInfo = @[LoginData.avatar, LoginData.name, LoginData.sex == man ?  @"男" : @"女", LoginData.academy, LoginData.major, LoginData.class_, LoginData.number, LoginData.email, LoginData.phone];
        }
    }
    [[HHBlueToothManager shareManager] disconnect];
    [self initView];
}

- (void)actionSettingDepartmentCallback:(NSString *)string{
    [self actionNetCommitName:string infoName:@"department"];
}

- (void)actionEditInfoCallback:(nonnull NSString *)string idx:(NSInteger)idx {
    if(idx == 0) {
        [self actionNetCommitName:string infoName:@"name"];
    } else if (idx == 1) {
        [self actionNetCommitName:string infoName:@"company"];
    } else if (idx == 2 ) {
        //[self actionNetCommitName:string infoName:@"department"];
    } else if (idx == 3 ) {
        [self actionNetCommitName:string infoName:@"title"];
    } else if (idx == 4 ) {
        [self actionNetCommitName:string infoName:@"academy"];
    }
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag {
    [self actionNetCommitName:[@(index) stringValue] infoName:@"sex"];
}




- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.editView.textField) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>24){
            [self.view makeToast:@"您的姓名过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    }
    return YES;
}

- (void)actionNetCommitName:(NSString *)name infoName:(NSString *)infoName{
    [self actionNetCommitInfo:infoName content:name];
}

- (void)actionNetCommitInfo:(NSString *)infoName content:(NSString *)content{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[infoName] = content;
    [Tools showWithStatus:@"正在修改"];
    __weak typeof(self) wself = self;
    [TTRequestManager userModifyInfo:params success:^(id  _Nonnull responseObject) {
        if([responseObject[@"errorCode"] integerValue] == 0) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            [wself refreshData:data];
            
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)actionChangeUserHead{
    KSImagePickerController *ctl = [KSImagePickerController.alloc initWithEditPictureStyle:KSImagePickerEditPictureStyleNormal];
    ctl.delegate = self;
    //self.pickView = YES;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if(row == 0) {
        [self actionChangeUserHead];
    }
    NSString *title = self.arrayTitle[row];
    if (![self bModifiable:title]) {
        [self.view makeToast:@"该项不可以修改" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if(row == 1) {
        [self actionChangeName];
    } else if(row == 2) {
        [self actionChangeSex];
    }
    if (self.loginType == login_type_personal || self.loginType == login_type_union) {
        if(row == 3) {
            [self actionToSelectBirthDay];
        } else if(row == 4) {
            [self actionToSelectArea];
        } else if(row == 5) {
            [self actionChangeCompany];
        } else if(row == 6) {
            [self actionChangeDepartent];
        } else if(row == 7) {
            [self actionChangeTitle];
        }
    } else if (self.loginType == login_type_teaching) {
        if (LoginData.role == Teacher_role) {
            if(row == 3) {
                [self actionChangeCompany];
            } else if(row == 4) {
                [self actionChangeDepartent];
            } else if(row == 5) {
                [self actionChangeTitle];
            } else if(row == 6) {
                [self actionChangeSchool];
            }
        }
    }
    
        
}

- (void)actionToSelectArea{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];//[plistBundle pathForResource:@"BRCity" ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataSource = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //NSArray *dataSource = [NSArray arrayWithContentsOfFile:filePath];
    __weak typeof(self) wself = self;
    [BRAddressPickerView showAddressPickerWithShowType:BRAddressPickerModeArea dataSource:dataSource defaultSelected:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(BRProvinceModel *province, BRCityModel *city, BRAreaModel *area) {

        NSString *info = [NSString stringWithFormat:@"%@%@%@", province.name, city.name, area.name];
        [wself actionNetCommitInfo:info content:@"area"];
    } cancelBlock:^{
        DDLogInfo(@"点击了背景视图或取消按钮");
    }];
}

- (void)actionToSelectBirthDay{
    NSDate *minDate = [Tools dateWithYearsBeforeNow:120];
    NSDate *maxDate = [Tools dateWithYearsBeforeNow:0];
    NSString *showDate = [Tools dateToStringYMD:maxDate];
    __weak typeof(self) wself = self;
    [BRDatePickerView showDatePickerWithTitle:@"请选择您的生日" dateType:BRDatePickerModeYMD defaultSelValue:showDate minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:MainColor resultBlock:^(NSString *selectValue) {
        //wself.itemViewBirthDay.textFieldInfo.text = selectValue;
        [wself actionNetCommitInfo:selectValue content:@"birthday"];
    } cancelBlock:^{
        
    }];
}

- (void)actionChangeSex{
    TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[@"男", @"女"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (void)actionChangeName{
    self.editView = [[HMEditView alloc] initWithTitle:@"修改姓名" info:LoginData.name placeholder:@"请输入您的姓名" idx:0];
    self.editView.delegate = self;
    self.editView.textField.delegate = self;
    [kAppWindow addSubview:self.editView];
}

- (void)actionChangeCompany{
    self.editView = [[HMEditView alloc] initWithTitle:@"修改企业(医院)" info:LoginData.company placeholder:@"请输入您的企业(医院)" idx:1];
    self.editView.delegate = self;
    self.editView.textField.delegate = self;
    [kAppWindow addSubview:self.editView];
}

- (void)actionChangeDepartent{
//    self.editView = [[HMEditView alloc] initWithTitle:@"修改部门(科室)" info:LoginData.department placeholder:@"请输入您的部门(科室)" idx:2];
//    self.editView.delegate = self;
//    self.editView.textField.delegate = self;
//    [kAppWindow addSubview:self.editView];
    
    SettingDepartmentVC *settingDepartment = [[SettingDepartmentVC alloc] init];
    settingDepartment.delegate = self;
    [self.navigationController pushViewController:settingDepartment animated:YES];
}

- (void)actionChangeTitle{
    self.editView = [[HMEditView alloc] initWithTitle:@"修改职称" info:LoginData.title placeholder:@"请输入您的职称" idx:3];
    self.editView.delegate = self;
    self.editView.textField.delegate = self;
    [kAppWindow addSubview:self.editView];
}

- (void)actionChangeSchool{
    self.editView = [[HMEditView alloc] initWithTitle:@"修改院校" info:LoginData.title placeholder:@"请输入您的院校" idx:4];
    self.editView.delegate = self;
    self.editView.textField.delegate = self;
    [kAppWindow addSubview:self.editView];
}

- (void)initView{
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayTitle.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
   
    
    if(row == 0) {
        UserInfoOneCell *cell = (UserInfoOneCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UserInfoOneCell class])];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
        cell.title = self.arrayTitle[row];
        cell.avatar = LoginData.avatar;
        return cell;
    } else {

        UserInfoTwoCell *cell = (UserInfoTwoCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UserInfoTwoCell class])];
        NSString *title = self.arrayTitle[row];
        if([self bModifiable:title]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.title = title;
        cell.info = self.arrayInfo[row];
        return cell;
    }
    
}

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UserInfoOneCell class] forCellReuseIdentifier:NSStringFromClass([UserInfoOneCell class])];
        [_tableView registerClass:[UserInfoTwoCell class] forCellReuseIdentifier:NSStringFromClass([UserInfoTwoCell class])];
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)imagePicker:(KSImagePickerController *)imagePicker didFinishSelectedAssetModelArray:(NSArray <KSImagePickerItemModel *> *)assetModelArray ofMediaType:(KSImagePickerMediaType)mediatype{
    DDLogInfo(@"didFinishSelectedAssetModelArray");
}

- (void)imagePicker:(KSImagePickerController *)imagePicker didFinishSelectedImageArray:(NSArray <UIImage *> *)imageArray{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:@"正在上传"];
    __weak typeof(self) wself = self;
    [TTRequestManager userModifyAvatar:params image:imageArray[0] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSDictionary *data = [responseObject objectForKey:@"data"];
                [wself refreshData:data];
            });
        }
        [kAppWindow makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
    
}

- (void)refreshData:(NSDictionary *)data{
    HHLoginData *loginData = [HHLoginData yy_modelWithDictionary:data];
    LoginData.userID = loginData.userID;
    LoginData.sex = loginData.sex;
    if(![Tools isBlankString:loginData.phone]){
        LoginData.phone = loginData.phone;
    }
    if(![Tools isBlankString:loginData.area]){
        LoginData.area = loginData.area;
    }
    if(![Tools isBlankString:loginData.avatar]){
        LoginData.avatar = loginData.avatar;
    }
    if(![Tools isBlankString:loginData.title]){
        LoginData.title = loginData.title;
    }
    if(![Tools isBlankString:loginData.birthday]){
        LoginData.birthday = loginData.birthday;
    }
    if(![Tools isBlankString:loginData.info_modifiable]){
        LoginData.info_modifiable = loginData.info_modifiable;
    }
    LoginData.role = loginData.role;
    if(![Tools isBlankString:loginData.department]){
        LoginData.department = loginData.department;
    }
    if(![Tools isBlankString:loginData.email]){
        LoginData.email = loginData.email;
    }
    if(![Tools isBlankString:loginData.company]){
        LoginData.company = loginData.company;
    }
    if(![Tools isBlankString:loginData.name]){
        LoginData.name = loginData.name;
    }
    
    if(![Tools isBlankString:loginData.academy]){
        LoginData.academy = loginData.academy;
    }
    if(![Tools isBlankString:loginData.major]){
        LoginData.major = loginData.major;
    }
    if(![Tools isBlankString:loginData.class_]){
        LoginData.class_ = loginData.class_;
    }
    if(![Tools isBlankString:loginData.number]){
        LoginData.number = loginData.number;
    }
    if(![Tools isBlankString:loginData.org]){
        LoginData.org = loginData.org;
    }
    if (self.loginType == login_type_personal || self.loginType == login_type_union) {

        
        self.arrayInfo = @[LoginData.avatar, LoginData.name, LoginData.sex == man  ? @"女" : @"男", LoginData.birthday, LoginData.area, LoginData.company, LoginData.department, LoginData.title, LoginData.email, LoginData.phone];
    } else if(self.loginType == login_type_teaching) {
        if (LoginData.role == Teacher_role) {
            self.arrayInfo = @[LoginData.avatar, LoginData.name, LoginData.sex == man ? @"男" : @"女", LoginData.company, LoginData.department, LoginData.title, LoginData.academy, LoginData.email, LoginData.phone];
        } else if (LoginData.role == Student_role) {
            
            self.arrayInfo = @[LoginData.avatar, LoginData.name, LoginData.sex == man ? @"男" : @"女", LoginData.academy, LoginData.major, LoginData.class_, LoginData.number, LoginData.email, LoginData.phone];
        }
    }
    [[HHLoginManager sharedManager] setCurrentHHLoginData:LoginData];
    
    [self.tableView reloadData];
}

- (Boolean)bModifiable:(NSString *)title{
    //@"头像", @"姓名", @"性别", @"生日", @"地区", @"企业(医院)",@"部门(科室)", @"职称", @"邮箱", @"手机"
    //@"头像", @"姓名", @"性别", @"企业(医院)",@"部门(科室)", @"职称", @"院校", @"邮箱", @"手机"
    //@"头像", @"姓名", @"性别", @"院校", @"专业",@"班级", @"学号",  @"邮箱", @"手机"
    if ([title containsString:@"姓名"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(0, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"性别"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(1, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"学号"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(2, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    }  else if ([title containsString:@"生日"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(3, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"地区"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(4, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"院校"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(5, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"专业"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(6, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"班级"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(7, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"企业"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(8, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"部门"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(9, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    } else if ([title containsString:@"职称"]) {
        NSString *s = [self.infoModifiable substringWithRange:NSMakeRange(10, 1)];
        if([s intValue] == 1) {
            return YES;
        }
    }
    
    return NO;
}
@end
