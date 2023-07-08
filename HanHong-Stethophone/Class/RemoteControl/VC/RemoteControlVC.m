//
//  RemoteControlVC.m
//  HM-Stethophone
//  远程会诊
//  Created by Eason on 2023/6/12.
//

#import "RemoteControlVC.h"
#import "MyCreateConsultationView.h"
#import "BeInviteConsultationView.h"
#import "FriendVC.h"
#import "CreateConsultationVC.h"
#import "RemoteControlDetailVC.h"

@interface RemoteControlVC ()<CreateConsultationDelegate, MyCreateConsultationViewDelegate, BeInviteConsultationViewDelegate>

@property (retain, nonatomic) HHBluetoothButton             *bluetoothButton;
@property (retain, nonatomic) UIButton                      *buttonFast;
@property (retain, nonatomic) UIView                        *viewLineFast;
@property (retain, nonatomic) UIButton                      *buttonFriend;
@property (retain, nonatomic) UIButton                      *buttonMy;
@property (retain, nonatomic) UIButton                      *buttonInvite;
@property (retain, nonatomic) MyCreateConsultationView      *myCreateConsultationView;
@property (retain, nonatomic) BeInviteConsultationView      *beInviteConsultationView;
@property (retain, nonatomic) UIButton                      *buttonAdd;



@end

@implementation RemoteControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    [self initView];
}

- (void)actionTableViewCellClickCallback:(ConsultationModel *)model{
    RemoteControlDetailVC *detailVC = [[RemoteControlDetailVC alloc] init];
    detailVC.consultationModel = model;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)actionCreateConsultationSuccessCallback:(Boolean)bModify{
    [self.myCreateConsultationView initData];
}

- (void)actionModifyConsultationCallback:(ConsultationModel *)model{
    CreateConsultationVC *createConsultation = [[CreateConsultationVC alloc] init];
    createConsultation.delegate = self;
    createConsultation.bModify = YES;
    createConsultation.consultationModel = model;
    [self.navigationController pushViewController:createConsultation animated:YES];
}

- (void)actionClickAdd:(UIButton *)button{
    CreateConsultationVC *createConsultation = [[CreateConsultationVC alloc] init];
    createConsultation.delegate = self;
    [self.navigationController pushViewController:createConsultation animated:YES];
}

- (void)actionRemote:(UIButton *)button{
}

- (void)actionFriend:(UIButton *)button{
    FriendVC *friend = [[FriendVC alloc] init];
    [self.navigationController pushViewController:friend animated:YES];
}


- (void)actionMy:(UIButton *)button{
    self.buttonMy.backgroundColor = HEXCOLOR(0xDAECFD, 1);
    self.buttonInvite.backgroundColor = HEXCOLOR(0xF5F5F5, 1);
    self.buttonMy.selected = YES;
    self.buttonInvite.selected = NO;
    self.myCreateConsultationView.hidden = NO;
    self.beInviteConsultationView.hidden = YES;
    self.buttonAdd.hidden = NO;
}

- (void)actionInvite:(UIButton *)button{
    self.buttonInvite.backgroundColor = HEXCOLOR(0xDAECFD, 1);
    self.buttonMy.backgroundColor = HEXCOLOR(0xF5F5F5, 1);
    self.buttonMy.selected = NO;
    self.buttonInvite.selected = YES;
    self.myCreateConsultationView.hidden = YES;
    self.beInviteConsultationView.hidden = NO;
    self.buttonAdd.hidden = YES;
    if (!self.beInviteConsultationView.bLoadData) {
        [self.beInviteConsultationView initData];
    }
}

- (void)initView{
    [self.view addSubview:self.bluetoothButton];
    self.bluetoothButton.sd_layout.rightSpaceToView(self.view, Ratio16).widthIs(Ratio22).heightIs(Ratio22).topSpaceToView(self.view, kStatusBarHeight + Ratio5);
    
    [self.view addSubview:self.buttonFast];
    [self.view addSubview:self.buttonFriend];
    [self.view addSubview:self.viewLineFast];
    self.buttonFast.sd_layout.leftSpaceToView(self.view, Ratio33).centerYEqualToView(self.bluetoothButton).heightIs(Ratio28).widthIs(127.f*screenRatio);
    self.viewLineFast.sd_layout.centerXEqualToView(self.buttonFast).heightIs(Ratio2).widthIs(70.f*screenRatio).topSpaceToView(self.buttonFast, 0);
    self.buttonFriend.sd_layout.rightSpaceToView(self.view, Ratio33).centerYEqualToView(self.buttonFast).heightIs(Ratio28).widthIs(127.f*screenRatio);
    
    [self.view addSubview:self.buttonMy];
    [self.view addSubview:self.buttonInvite];
    self.buttonMy.sd_layout.leftSpaceToView(self.view, 0).widthIs(screenW/2).heightIs(Ratio35).topSpaceToView(self.buttonFast, Ratio5);
    self.buttonInvite.sd_layout.rightSpaceToView(self.view, 0).widthIs(screenW/2).heightIs(Ratio35).topEqualToView(self.buttonMy);
    
    [self.view addSubview:self.myCreateConsultationView];
    self.myCreateConsultationView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.buttonMy, 0).bottomSpaceToView(self.view, kBottomSafeHeight);
    
    [self.view addSubview:self.beInviteConsultationView];
    self.beInviteConsultationView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.buttonMy, 0).bottomSpaceToView(self.view, kBottomSafeHeight);
    
    [self.view addSubview:self.buttonAdd];
    self.buttonAdd.sd_layout.rightSpaceToView(self.view, Ratio22).bottomSpaceToView(self.view, Ratio22 + kBottomSafeHeight).widthIs(Ratio44).heightIs(Ratio44);
    
}

- (MyCreateConsultationView *)myCreateConsultationView{
    if (!_myCreateConsultationView) {
        _myCreateConsultationView = [[MyCreateConsultationView alloc] init];
        _myCreateConsultationView.createConsultationDelegate = self;
        
    }
    return _myCreateConsultationView;
}

- (BeInviteConsultationView *)beInviteConsultationView{
    if (!_beInviteConsultationView) {
        _beInviteConsultationView = [[BeInviteConsultationView alloc] init];
        _beInviteConsultationView.hidden = YES;
        _beInviteConsultationView.beInviteConsultationViewDelegate = self;
    }
    return _beInviteConsultationView;
}

- (HHBluetoothButton *)bluetoothButton{
    if(!_bluetoothButton) {
        _bluetoothButton = [[HHBluetoothButton alloc] init];
    }
    return _bluetoothButton;
}

- (UIButton *)buttonFast{
    if(!_buttonFast) {
        _buttonFast = [self setupButton1:@"远程会诊"];
        _buttonFast.selected = YES;
        [_buttonFast addTarget:self action:@selector(actionRemote:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonFast;
}

- (UIButton *)setupButton1:(NSString *)string{
    UIButton *button = [[UIButton alloc] init];
    [button setTitleColor:MainBlack forState:UIControlStateSelected];
    [button setTitle:string forState:UIControlStateSelected];
    [button setTitle:string forState:UIControlStateNormal];
    [button setTitleColor:MainNormal forState:UIControlStateNormal];
    button.titleLabel.font = Font18;
    return button;
}

- (UIButton *)buttonFriend{
    if(!_buttonFriend) {
        _buttonFriend = [self setupButton1:@"亦师亦友"];
        [_buttonFriend addTarget:self action:@selector(actionFriend:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonFriend;
}

- (UIView *)viewLineFast{
    if(!_viewLineFast){
        _viewLineFast = [[UIView alloc] init];
        _viewLineFast.backgroundColor = MainColor;
    }
    return _viewLineFast;
}

- (UIButton *)buttonMy{
    if(!_buttonMy) {
        _buttonMy = [self setupButton2:@"我创建的会诊"];
        _buttonMy.backgroundColor = HEXCOLOR(0xDAECFD, 1);
        [_buttonMy addTarget:self action:@selector(actionMy:) forControlEvents:UIControlEventTouchUpInside];
        _buttonMy.selected = YES;
    }
    return _buttonMy;
}

- (UIButton *)setupButton2:(NSString *)string{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:string forState:UIControlStateNormal];
    [button setTitleColor:MainNormal forState:UIControlStateNormal];
    [button setTitleColor:MainColor forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:Ratio15];
    return button;
}

- (UIButton *)buttonInvite{
    if(!_buttonInvite) {
        _buttonInvite = [self setupButton2:@"被邀请的会诊"];
        _buttonInvite.backgroundColor = HEXCOLOR(0xF5F5F5, 1);
        [_buttonInvite addTarget:self action:@selector(actionInvite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonInvite;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.bluetoothButton star];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.bluetoothButton stop];
}

- (UIButton *)buttonAdd{
    if (!_buttonAdd) {
        _buttonAdd = [[UIButton alloc] init];
        [_buttonAdd setImage:[UIImage imageNamed:@"add_meeting"] forState:UIControlStateNormal];
        [_buttonAdd addTarget:self action:@selector(actionClickAdd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonAdd;
}




@end
