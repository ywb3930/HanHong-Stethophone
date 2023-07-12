//
//  ProgramPlanListVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/26.
//

#import "ProgramPlanListVC.h"
#import "ProgramPlanListCell.h"
#import "NewProgramVC.h"

@interface ProgramPlanListVC ()<UITableViewDelegate, UITableViewDataSource, NewProgramVCDelgate>

@property (retain, nonatomic) UITableView           *tableView;

@end

@implementation ProgramPlanListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ViewBackGroundColor;
    self.title = @"本月计划课程";
    [self.view addSubview:self.tableView];
}



- (void)actionEditProgramCallback:(ProgramModel *)model{
    NSInteger row = [self.programListData indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)actionDeleteProgramCallback:(ProgramModel *)model{
    NSInteger row = [self.programListData indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.programListData removeObjectAtIndex:row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewProgramVC *newProgram = [[NewProgramVC alloc] init];
    newProgram.programModel = self.programListData[indexPath.row];
    newProgram.bCreate = NO;
    newProgram.delegate = self;
    [self.navigationController pushViewController:newProgram animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.programListData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProgramPlanListCell *cell = (ProgramPlanListCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ProgramPlanListCell class])];
    cell.model = self.programListData[indexPath.row];
    return cell;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight, screenW, screenH - kNavBarAndStatusBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ProgramPlanListCell class] forCellReuseIdentifier:NSStringFromClass([ProgramPlanListCell class])];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = ViewBackGroundColor;
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
