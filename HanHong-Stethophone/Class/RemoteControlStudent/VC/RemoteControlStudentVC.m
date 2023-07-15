//
//  RemoteControlStudentVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/25.
//

#import "RemoteControlStudentVC.h"
#import "StudentProgramView.h"
#import "ScanTeachCodeVC.h"
#import "ClinicLearningVC.h"
#import "ProgramPlanListCell.h"
#import "NewProgramVC.h"

@interface RemoteControlStudentVC ()<ScanTeachCodeVCDelegate, UITableViewDelegate, UITableViewDataSource, NewProgramVCDelgate>

@property (retain, nonatomic) UIView                *viewNavi;
@property (retain, nonatomic) UIButton              *buttonLearnProgram;
@property (retain, nonatomic) UIButton              *buttonClinic;
@property (retain, nonatomic) StudentProgramView    *studentProgramView;
@property (retain, nonatomic) UITableView           *tableView;
@property (retain, nonatomic) NSMutableArray        *arrayData;

@end

@implementation RemoteControlStudentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    //[ProgramDBHelp add];
    self.arrayData = [NSMutableArray array];
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalender:) name:add_program_broadcast object:nil];
}

- (void)actionEditProgramCallback:(ProgramModel *)model{
    NSInteger row = [self.arrayData indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)actionDeleteProgramCallback:(ProgramModel *)model{
    NSInteger row = [self.arrayData indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.arrayData removeObjectAtIndex:row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)actionScanCodeResultCallback:(NSString *)scanCodeResult{
    Boolean urlValid = NO;
    NSArray *urlArray;
    if ([scanCodeResult containsString:@"/api/teaching/classroom/"]) {
        urlArray = [scanCodeResult componentsSeparatedByString:@"/api/teaching/classroom/"];
        if (urlArray.count == 2) {
            urlValid = YES;
        }
    }
    if (urlValid) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ClinicLearningVC *clinicLearning = [[ClinicLearningVC alloc] init];
            clinicLearning.classroomUrl = [NSString stringWithFormat:@"%@/api/teaching/classroom", urlArray[0]];
            clinicLearning.classroomId = urlArray[1];
            [self.navigationController pushViewController:clinicLearning animated:YES];
        });
        
    } else {
        [self.view makeToast:@"无效的临床学习二维码" duration:showToastViewWarmingTime position:CSToastPositionCenter];
    }
    
    
}

- (void)reloadCalender:(NSNotification *)noti{
    if ([NSThread isMainThread]) {
        [self.studentProgramView initData:self.studentProgramView.currentDate];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.studentProgramView initData:self.studentProgramView.currentDate];
        });
    }
    
}

- (void)setupView{
    [self.view addSubview:self.viewNavi];
    [self.viewNavi addSubview:self.buttonLearnProgram];
    [self.viewNavi addSubview:self.buttonClinic];
    self.buttonClinic.sd_layout.rightSpaceToView(self.viewNavi, 0).widthIs(screenW/2).heightIs(Ratio33).bottomSpaceToView(self.viewNavi, 0);
    self.buttonLearnProgram.sd_layout.leftSpaceToView(self.viewNavi, 0).widthIs(screenW/2).heightIs(Ratio33).bottomSpaceToView(self.viewNavi, 0);
    
    [self.view addSubview:self.studentProgramView];
    self.studentProgramView.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.viewNavi, 0).rightSpaceToView(self.view, 0).bottomSpaceToView(self.view, 0);
    [self.view addSubview:self.tableView];
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = ViewBackGroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.hidden = YES;
        [_tableView registerClass:[ProgramPlanListCell class] forCellReuseIdentifier:NSStringFromClass([ProgramPlanListCell class])];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProgramPlanListCell *cell = (ProgramPlanListCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ProgramPlanListCell class])];
    ProgramModel *model = self.arrayData[indexPath.row];
    cell.model = model;
    cell.tag = model.tag;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewProgramVC *newProgram = [[NewProgramVC alloc] init];
    newProgram.programModel = self.arrayData[indexPath.row];
    newProgram.bCreate = NO;
    newProgram.delegate = self;
    [self.navigationController pushViewController:newProgram animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio77;
}


- (void)actionClickClinic:(UIButton *)button{
    ScanTeachCodeVC *scanTeachCode = [[ScanTeachCodeVC alloc] init];
    scanTeachCode.delegate = self;
    scanTeachCode.message = @"请扫码进入教室";
    [self.navigationController pushViewController:scanTeachCode animated:YES];
}

- (void)scanCodeResultCallback:(NSString *)scanCodeResult{
    NSLog(@"%@", scanCodeResult);
}

- (StudentProgramView *)studentProgramView{
    if (!_studentProgramView) {
        _studentProgramView = [[StudentProgramView alloc] init];
        __weak typeof(self) wself = self;
        _studentProgramView.dataBlock = ^(NSMutableArray * _Nonnull arrayData, CGFloat maxY) {
            wself.arrayData = arrayData;
            [wself.tableView reloadData];
            wself.tableView.hidden = NO;
            wself.tableView.sd_layout.topSpaceToView(wself.view, kNavBarAndStatusBarHeight + maxY + Ratio11).leftSpaceToView(wself.view, 0).rightSpaceToView(wself.view, 0).bottomSpaceToView(wself.view, 0);
            [wself.tableView updateLayout];
        };
        _studentProgramView.itemChangeBlock = ^(ProgramModel * _Nonnull model, NSInteger tag) {
            if (tag == 0) {
                [wself actionDeleteProgramCallback:model];
            } else {
                [wself actionEditProgramCallback:model];
            }
        };
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
