//
//  RemoteControlTeacherVC.m
//  HanHong-Stethophone
//  听诊教学
//  Created by 袁文斌 on 2023/6/25.
//

#import "RemoteControlTeacherVC.h"
#import "ClinicTeachingVC.h"
#import "TeachingProgramView.h"
#import "TeachingRecordView.h"

@interface RemoteControlTeacherVC ()

@property (retain, nonatomic) UIView                *viewNavi;
@property (retain, nonatomic) UIButton              *buttonTeachingProgram;
@property (retain, nonatomic) UIButton              *buttonClinic;
@property (retain, nonatomic) UIButton              *buttonTeachingRecord;
@property (retain, nonatomic) TeachingProgramView   *teachingProgramView;
@property (retain, nonatomic) TeachingRecordView    *teachingRecordView;
@property (assign, nonatomic) Boolean               bLoadRecordView;

@end

@implementation RemoteControlTeacherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalender:) name:add_program_broadcast object:nil];
}

- (void)reloadCalender:(NSNotification *)noti{
    [self.teachingProgramView initData:self.teachingProgramView.currentDate];
}

- (void)actionTeachingProgram:(UIButton *)button{
    if(button.selected)return;
    button.selected = !button.selected;
    self.buttonTeachingRecord.selected = NO;
    self.teachingProgramView.hidden = NO;
    self.teachingRecordView.hidden = YES;
}

- (void)actionTeachingRecord:(UIButton *)button{
    if(button.selected)return;
    button.selected = !button.selected;
    self.buttonTeachingProgram.selected = NO;
    self.teachingProgramView.hidden = YES;
    self.teachingRecordView.hidden = NO;
    if (!self.bLoadRecordView) {
        self.bLoadRecordView = YES;
        [self.teachingRecordView setupView];
    }
}

- (void)actionClickClinic:(UIButton *)button{
    ClinicTeachingVC *clinicVC = [[ClinicTeachingVC alloc] init];
    __weak typeof(self) wself = self;
    clinicVC.historyListBlock = ^{
        [wself.teachingRecordView initData];
    };
    [self.navigationController pushViewController:clinicVC animated:YES];
}
- (void)setupView{
    [self.view addSubview:self.viewNavi];
    [self.viewNavi addSubview:self.buttonTeachingProgram];
    [self.viewNavi addSubview:self.buttonClinic];
    [self.viewNavi addSubview:self.buttonTeachingRecord];
    self.buttonClinic.sd_layout.centerXEqualToView(self.viewNavi).widthIs(screenW/3).heightIs(Ratio33).bottomSpaceToView(self.viewNavi, 0);
    self.buttonTeachingProgram.sd_layout.leftSpaceToView(self.viewNavi, 0).widthIs(screenW/3).heightIs(Ratio33).bottomSpaceToView(self.viewNavi, 0);
    self.buttonTeachingRecord.sd_layout.rightSpaceToView(self.viewNavi, 0).widthIs(screenW/3).heightIs(Ratio33).bottomSpaceToView(self.viewNavi, 0);
    [self.view addSubview:self.teachingRecordView];
    [self.view addSubview:self.teachingProgramView];
    self.teachingProgramView.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.viewNavi, 0).rightSpaceToView(self.view, 0).bottomSpaceToView(self.view, 0);
    self.teachingRecordView.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.viewNavi, 0).rightSpaceToView(self.view, 0).bottomSpaceToView(self.view, 0);
}

- (TeachingProgramView *)teachingProgramView{
    if (!_teachingProgramView) {
        _teachingProgramView = [[TeachingProgramView alloc] init];
    }
    return _teachingProgramView;
}

- (TeachingRecordView *)teachingRecordView{
    if (!_teachingRecordView) {
        _teachingRecordView = [[TeachingRecordView alloc] init];
        _teachingRecordView.hidden = YES;
    }
    
    return _teachingRecordView;
}

- (UIView *)viewNavi{
    if (!_viewNavi) {
        _viewNavi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, kNavBarAndStatusBarHeight)];
        _viewNavi.backgroundColor = WHITECOLOR;
    }
    return _viewNavi;
}

- (UIButton *)buttonTeachingProgram{
    if (!_buttonTeachingProgram) {
        _buttonTeachingProgram = [self setButtonTitle:@"教学计划"];
        [_buttonTeachingProgram setTitleColor:MainBlack forState:UIControlStateSelected];
        _buttonTeachingProgram.selected = YES;
        [_buttonTeachingProgram addTarget:self action:@selector(actionTeachingProgram:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTeachingProgram;
}

- (UIButton *)buttonClinic{
    if (!_buttonClinic) {
        _buttonClinic = [self setButtonTitle:@"临床教学"];
        [_buttonClinic addTarget:self action:@selector(actionClickClinic:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonClinic;
}

- (UIButton *)buttonTeachingRecord{
    if (!_buttonTeachingRecord) {
        _buttonTeachingRecord = [self setButtonTitle:@"教学记录"];
        [_buttonTeachingRecord setTitleColor:MainBlack forState:UIControlStateSelected];
        [_buttonTeachingRecord addTarget:self action:@selector(actionTeachingRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTeachingRecord;
}

- (UIButton *)setButtonTitle:(NSString *)title{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitleColor:MainNormal forState:UIControlStateNormal];
    button.titleLabel.font = Font15;
    return button;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
