//
//  MeVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "MeVC.h"
#import "MeHeaderView.h"
#import "UserInfoVC.h"
#import "PasswordManagerVC.h"
#import "DeviceManagerVC.h"
#import "AboutUsVC.h"
#import "LogoffUserVC.h"
#import "RegisterInviteVC.h"
#import "ToolsCheckUpdate.h"
//#import "DeviceManagerSettingView.h"
//https://github.com/ywb3930/HanHong-Stethophone.git
@interface MeVC ()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UITableView               *tableView;
@property (retain, nonatomic) NSArray                   *arrayImage;
@property (retain, nonatomic) NSArray                   *arrayTitle;
@property (retain, nonatomic) MeHeaderView              *headerView;
@property (assign ,nonatomic) NSInteger                 loginType;
@property (assign, nonatomic) Boolean                   bShowInvite;

@end

@implementation MeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = WHITECOLOR;
    self.loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
    if(self.loginType == login_type_personal) {
        self.arrayImage = @[@"personal_information", @"password_manager", @"device_manager", @"check_update", @"about_us",  @"signout", @"logout"];
        self.arrayTitle = @[@"个人信息", @"密码管理", @"设备管理", @"检测更新",  @"关于我们", @"注销用户", @"退出登录"];
        
    } else {
        self.arrayImage = @[@"personal_information", @"password_manager", @"device_manager", @"check_update", @"tianxieyaoqingma", @"about_us", @"signout", @"logout"];
        self.arrayTitle = @[@"个人信息", @"密码管理", @"设备管理", @"检测更新",@"注册邀请", @"关于我们", @"注销用户", @"退出登录"];
    }
    [self initView];
}

- (void)initView{
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayTitle.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    self.headerView = (MeHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([MeHeaderView class])];
    [RACObserve(LoginData, name) subscribeNext:^(id  _Nullable x) {
        if ([Tools isBlankString:x]) {
            self.headerView.labelName.text = @"未登录";
        }else {
           self.headerView.labelName.text = x;
        }
        
    }];
    [RACObserve(LoginData, avatar) subscribeNext:^(id  _Nullable x) {
        [self.headerView.imageViewHeadView sd_setImageWithURL:[NSURL URLWithString:x] placeholderImage:[UIImage imageNamed:@"avatar"] options:SDWebImageQueryMemoryData];
        self.headerView.imageViewHeadView.sd_imageTransition = SDWebImageTransition.fadeTransition;
    }];
    [RACObserve(LoginData, phone) subscribeNext:^(id  _Nullable x) {
        if(![Tools isBlankString:x]) {
            self.headerView.labelUserId.text = [NSString stringWithFormat:@"账户：%@", x];
        } else {
            [RACObserve(LoginData, email) subscribeNext:^(id  _Nullable x) {
                if(![Tools isBlankString:x]) {
                    self.headerView.labelUserId.text = [NSString stringWithFormat:@"账户：%@", x];
                } else {
                    self.headerView.labelName.sd_layout.centerYEqualToView(self.headerView.imageViewHeadView);
                }
            }];
        }
        
    }];

    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kStatusBarHeight + 111.f*screenRatio;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MeTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:self.arrayImage[indexPath.row]];
    cell.textLabel.text = self.arrayTitle[indexPath.row];
    cell.textLabel.font = Font15;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if(row == 0) {
        UserInfoVC *userInfo = [[UserInfoVC alloc] init];
        userInfo.title = self.arrayTitle[indexPath.row];
        [self.navigationController pushViewController:userInfo animated:YES];
    }  else if (row == 1) {
        PasswordManagerVC *passwordManager = [[PasswordManagerVC alloc] init];
        [self.navigationController pushViewController:passwordManager animated:YES];
    } else if (row == 2) {
        DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
        [self.navigationController pushViewController:deviceManager animated:YES];
    } else if (row == 3) {
        [[ToolsCheckUpdate getInstance] actionToCheckUpdate:YES];
    } else if (row == 4) {
        if (self.loginType == login_type_personal) {
            [self actionToAboutUsVC];
        } else {
            [self actionToRegisterInvite];
        }
        
    } else if (row == 5) {
        if (self.loginType == login_type_personal) {
            [self actionToLogoff];
        } else {
            [self actionToAboutUsVC];
        }
        
    } else if(row == 6) {
        if (self.loginType == login_type_personal) {
            [self actionLogout];
        } else {
            [self actionToLogoff];
        }
    } else {
        [self actionLogout];
    }
    
}

- (void)actionToRegisterInvite{
    RegisterInviteVC *registerInvite = [[RegisterInviteVC alloc] init];
    [self.navigationController pushViewController:registerInvite animated:YES];
}

- (void)actionToLogoff{
    LogoffUserVC *logoffUser = [[LogoffUserVC alloc] init];
    [self.navigationController pushViewController:logoffUser animated:YES];
}

- (void)actionToAboutUsVC{
    AboutUsVC *aboutUs = [[AboutUsVC alloc] init];
    [self.navigationController pushViewController:aboutUs animated:YES];
}

- (void)actionLogout{
    [Tools showAlertView:nil andMessage:@"您确定要退出当前账号吗？" andTitles:@[@"取消", @"确定"] andColors:@[MainBlack, MainColor] sure:^{
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"token"] = LoginData.token;
        [Tools showWithStatus:@"正在退出登录"];
        __weak typeof(self) wself = self;
        [TTRequestManager userLogout:params success:^(id  _Nonnull responseObject) {
            [Tools hiddenWithStatus];
            [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                [Tools logout:@""];
            }];
            
        } failure:^(NSError * _Nonnull error) {
            [Tools hiddenWithStatus];
        }];
    } cancel:^{
        
    }];
    
}

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[MeHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([MeHeaderView class])];
        _tableView.backgroundColor = WHITECOLOR;
        
    }
    return _tableView;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


@end
