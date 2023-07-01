//
//  RemoteControlStudentVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import "RemoteControlStudentVC.h"
#import "StudentProgramView.h"
#import "ScanTeachCodeVC.h"

@interface RemoteControlStudentVC ()<ScanTeachCodeVCDelegate>

@property (retain, nonatomic) UIView                *viewNavi;
@property (retain, nonatomic) UIButton              *buttonLearnProgram;
@property (retain, nonatomic) UIButton              *buttonClinic;
@property (retain, nonatomic) StudentProgramView    *studentProgramView;

@end

@implementation RemoteControlStudentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    //[ProgramDBHelp add];
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalender:) name:add_program_broadcast object:nil];
}

- (void)reloadCalender:(NSNotification *)noti{
    [self.studentProgramView initData:self.studentProgramView.currentDate];
}

- (void)setupView{
    [self.view addSubview:self.viewNavi];
    [self.viewNavi addSubview:self.buttonLearnProgram];
    [self.viewNavi addSubview:self.buttonClinic];
    self.buttonClinic.sd_layout.rightSpaceToView(self.viewNavi, 0).widthIs(screenW/2).heightIs(Ratio33).bottomSpaceToView(self.viewNavi, 0);
    self.buttonLearnProgram.sd_layout.leftSpaceToView(self.viewNavi, 0).widthIs(screenW/2).heightIs(Ratio33).bottomSpaceToView(self.viewNavi, 0);
    
    [self.view addSubview:self.studentProgramView];
    self.studentProgramView.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.viewNavi, 0).rightSpaceToView(self.view, 0).bottomSpaceToView(self.view, 0);
}

- (void)actionClickClinic:(UIButton *)button{
    ScanTeachCodeVC *scanTeachCode = [[ScanTeachCodeVC alloc] init];
    scanTeachCode.delegate = self;
    [self.navigationController pushViewController:scanTeachCode animated:YES];
}

- (void)scanCodeResultCallback:(NSString *)scanCodeResult{
    NSLog(@"%@", scanCodeResult);
}

- (StudentProgramView *)studentProgramView{
    if (!_studentProgramView) {
        _studentProgramView = [[StudentProgramView alloc] init];
    }
    return _studentProgramView;
}

- (UIView *)viewNavi{
    if (!_viewNavi) {
        _viewNavi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, kNavBarAndStatusBarHeight)];
        _viewNavi.backgroundColor = WHITECOLOR;
    }
    return _viewNavi;
}

- (UIButton *)buttonLearnProgram{
    if (!_buttonLearnProgram) {
        _buttonLearnProgram = [self setButtonTitle:@"学习计划"];
        [_buttonLearnProgram setTitleColor:MainBlack forState:UIControlStateSelected];
        _buttonLearnProgram.selected = YES;
    }
    return _buttonLearnProgram;
}

- (UIButton *)buttonClinic{
    if (!_buttonClinic) {
        _buttonClinic = [self setButtonTitle:@"临床学习"];
        [_buttonClinic addTarget:self action:@selector(actionClickClinic:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonClinic;
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
