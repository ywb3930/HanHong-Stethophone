//
//  NewFriendVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/21.
//

#import "NewFriendVC.h"
#import "FriendCell.h"

@interface NewFriendVC ()<UITableViewDelegate, UITableViewDataSource, FriendCellDelegate>

@property (retain, nonatomic) NSMutableArray               *arrayData;
@property (retain, nonatomic) UITableView                   *tableView;
@property (retain, nonatomic) NoDataView            *noDataView;

@end

@implementation NewFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    self.arrayData = [NSMutableArray array];
    if(self.data) {
        [self.arrayData addObjectsFromArray:self.data];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self actionShowNoDataView];
    } else {
        [self initData];
    }
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, Ratio1)];
    viewLine.backgroundColor = ViewBackGroundColor;
    [self.view addSubview:viewLine];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.noDataView];
    
}

- (void)actionShowNoDataView{
    if(self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
    } else {
        self.noDataView.hidden = YES;
    }
}

- (void)actionAddFriendCallback:(FriendModel *)model{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"friend_id"] = [@(model.id) stringValue];
    params[@"phone"] = model.phone;
    [Tools showWithStatus:@"正在发送添加请求"];
    __weak typeof(self) wself = self;
    [TTRequestManager friendRequest:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            model.state = 0;
            [wself reloadTableViewIndexPath:model];
            
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)reloadTableViewIndexPath:(FriendModel *)model{
    NSInteger row = [self.arrayData indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)actionFriendDeneyCallback:(FriendModel *)model{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"friend_id"] = [@(model.id) stringValue];
    [Tools showWithStatus:@"正在取消添加好友"];
    __weak typeof(self) wself = self;
    [TTRequestManager friendDeney:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            [wself deleteTableViewIndexPath:model];
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}


- (void)deleteTableViewIndexPath:(FriendModel *)model{
    NSInteger row = [self.arrayData indexOfObject:model];
    [self.arrayData removeObjectAtIndex:row];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self actionShowNoDataView];
}

- (void)actionFriendApproveCallback:(FriendModel *)model{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"friend_id"] = [@(model.id) stringValue];
    [Tools showWithStatus:@"正在添加好友"];
    __weak typeof(self) wself = self;
    [TTRequestManager friendApprove:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            [wself deleteTableViewIndexPath:model];
            [[NSNotificationCenter defaultCenter] postNotificationName:refresh_friendlist_broadcast object:nil];
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FriendCell class])];
    if (self.data) {
        cell.searchModel = self.arrayData[indexPath.row];
    } else {
        cell.friendNewModel = self.arrayData[indexPath.row];
    }
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 89.f*screenRatio;
}

- (void)initData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    __weak typeof(self) wself = self;
    [TTRequestManager friendGetRequests:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSArray *array = [NSArray yy_modelArrayWithClass:[FriendModel class] json:responseObject[@"data"]];
            [wself.arrayData addObjectsFromArray:array];
            [wself.tableView reloadData];
            [wself actionShowNoDataView];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Ratio1, screenW, screenH - kNavBarAndStatusBarHeight - 56.f*screenRatio)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FriendCell class] forCellReuseIdentifier:NSStringFromClass([FriendCell class])];
    }
    return _tableView;
}


- (NoDataView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight + Ratio35, screenW, screenH)];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}


@end
