//
//  RemoteControlTeacherVC.m
//  HanHong-Stethophone
//  听诊教学
//  Created by Hanhong on 2023/6/25.
//

#import "RemoteControlTeacherVC.h"
#import "ClinicTeachingVC.h"
#import "TeachingProgramView.h"
#import "TeachingRecordView.h"
#import "ProgramPlanListCell.h"
#import "NewProgramVC.h"

@interface RemoteControlTeacherVC ()<UITableViewDelegate, UITableViewDataSource,NewProgramVCDelgate>

@property (retain, nonatomic) UIView                *viewNavi;
@property (retain, nonatomic) UIButton              *buttonTeachingProgram;
@property (retain, nonatomic) UIButton              *buttonClinic;
@property (retain, nonatomic) UIButton              *buttonTeachingRecord;
@property (retain, nonatomic) TeachingProgramView   *teachingProgramView;
@property (retain, nonatomic) TeachingRecordView    *teachingRecordView;
@property (assign, nonatomic) Boolean               bLoadRecordView;
@property (retain, nonatomic) UITableView           *tableView;
@property (retain, nonatomic) NSMutableArray        *arrayData;

@end

@implementation RemoteControlTeacherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
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

- (void)reloadCalender:(NSNotification *)noti{
    if ([NSThread isMainThread]) {
        [self.teachingProgramView initData:self.teachingProgramView.currentDate];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.teachingProgramView initData:self.teachingProgramView.currentDate];
        });
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewProgramVC *newProgram = [[NewProgramVC alloc] init];
    newProgram.programModel = self.arrayData[indexPath.row];
    newProgram.bCreate = NO;
    newProgram.delegate = self;
    [self.navigationController pushViewController:newProgram animated:YES];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio77;
}


- (TeachingProgramView *)teachingProgramView{
    if (!_teachingProgramView) {
        _teachingProgramView = [[TeachingProgramView alloc] init];
        __weak typeof(self) wself = self;
        _teachingProgramView.dataBlock = ^(NSMutableArray * _Nonnull arrayData, CGFloat maxY) {
            wself.arrayData = arrayData;
            [wself.tableView reloadData];
            wself.tableView.hidden = NO;
            wself.tableView.sd_layout.topSpaceToView(wself.view, kNavBarAndStatusBarHeight + maxY + Ratio11).leftSpaceToView(wself.view, 0).rightSpaceToView(wself.view, 0).bottomSpaceToView(wself.view, 0);
            [wself.tableView updateLayout];
            
        };
        _teachingProgramView.itemChangeBlock = ^(ProgramModel * _Nonnull model, NSInteger tag) {
            if (tag == 0) {
                [wself actionDeleteProgramCallback:model];
            } else {
                [wself actionEditProgramCallback:model];
            }
        };
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
