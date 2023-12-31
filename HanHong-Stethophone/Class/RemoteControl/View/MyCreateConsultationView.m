//
//  MyCreateConsultationView.m
//  HanHong-Stethophone
//  我创建的会诊
//  Created by Hanhong on 2023/6/20.
//

#import "MyCreateConsultationView.h"

@interface MyCreateConsultationView()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, TTActionSheetDelegate>

@property (retain, nonatomic) NSMutableArray    *arrayData;
@property (retain, nonatomic) UIButton          *buttonAdd;
@property (retain, nonatomic) NSIndexPath       *currentIndexPath;
@property (retain, nonatomic) NoDataView        *noDataView;
@property (assign, nonatomic) Boolean        bSelected;

@end

@implementation MyCreateConsultationView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self setupView];
    }
    return self;
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    if (index == 0) {
        if (self.createConsultationDelegate && [self.createConsultationDelegate respondsToSelector:@selector(actionModifyConsultationCallback:)]) {
            ConsultationModel *model = self.arrayData[self.currentIndexPath.row];
            [self.createConsultationDelegate actionModifyConsultationCallback:model];
        }
    } else if (index == 1) {
        [self actionDeleteMeetingRoom];
    }
}

- (void)actionDeleteMeetingRoom{
    ConsultationModel *model = self.arrayData[self.currentIndexPath.row];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"meetingroom_id"] = [@(model.meetingroom_id) stringValue];
    [Tools showWithStatus:@"正在删除会诊室"];
    __weak typeof(self) wself = self;
    [TTRequestManager meetingDeleteMeeting:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            if([NSThread isMainThread]) {
                [wself reloadDataTableView];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself reloadDataTableView];
                });
            }
        }
        [kAppWindow makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [Tools hiddenWithStatus];
    } failure:^(NSError * _Nonnull error) {
        [Tools hiddenWithStatus];
    }];
}

- (void)reloadDataTableView{
    [self.arrayData removeObjectAtIndex:self.currentIndexPath.row];
    [self deleteRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if(self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
    } else {
        self.noDataView.hidden = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ConsultationModel *model = self.arrayData[indexPath.row];
    NSDate *endTimeDate = [Tools stringToDateYMDHM:model.end_time];
    //NSString *endTime = [Tools convertTimestampToStringYMDHM:model.end_time];
    long currentNow = [Tools getTimestampSecond:[NSDate now]];
    long currentEnd = [Tools getTimestampSecond:endTimeDate] + 24 *3600;

    if (currentNow > currentEnd) {
        [kAppWindow makeToast:@"会诊时间已过期，修改时间后再进入" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    tableView.userInteractionEnabled = NO;
    [self performSelector:@selector(actionClickTableViewEnabled) withObject:self afterDelay:1.0f];
    if (self.createConsultationDelegate && [self.createConsultationDelegate respondsToSelector:@selector(actionTableViewCellClickCallback:)]) {
        [self.createConsultationDelegate actionTableViewCellClickCallback:model];
    }
}

- (void)actionClickTableViewEnabled{
    self.userInteractionEnabled = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConsultationModel *model = self.arrayData[indexPath.row];
    return [self cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[ConsultationCell class] contentViewWidth:screenW];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConsultationCell *cell = (ConsultationCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ConsultationCell class])];
    cell.model = self.arrayData[indexPath.row];
    return cell;
}

- (void)initData{
    self.arrayData = [NSMutableArray array];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    __weak typeof(self) wself = self;
    [TTRequestManager meetingListCreated:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSDictionary *data = responseObject[@"data"];
            NSArray *array = [NSArray yy_modelArrayWithClass:[ConsultationModel class] json:data];
            [wself.arrayData addObjectsFromArray:array];
            if(wself.arrayData.count == 0) {
                wself.noDataView.hidden = NO;
            } else {
                wself.noDataView.hidden = YES;
            }
            [wself reloadData];
        }
        [Tools hiddenWithStatus];
    } failure:^(NSError * _Nonnull error) {
        if(error.code == -1009 || error.code == -1008){
            [wself actionNoNetWork];
        }
        [Tools hiddenWithStatus];
    }];
    
}

- (void)actionNoNetWork{
    if (self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
        __weak typeof(self) wself = self;
        self.noDataView.tapBloack = ^{
            [wself initData];
        };
    }
}

- (void)setupView{
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[ConsultationCell class] forCellReuseIdentifier:NSStringFromClass([ConsultationCell class])];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.noDataView];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]  initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self addGestureRecognizer:lpgr];
}



-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self];

    NSIndexPath *indexPath = [self indexPathForRowAtPoint:p];
    
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        self.currentIndexPath = indexPath;
        TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[@"修改会诊", @"删除"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        actionSheet.delegate = self;
        [actionSheet showInView:kAppWindow];
        // do stuff with the cell
        
    }
}

- (NoDataView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight + Ratio35, screenW, screenH)];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

@end
