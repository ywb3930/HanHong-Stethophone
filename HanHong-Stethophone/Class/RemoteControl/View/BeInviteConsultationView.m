//
//  BeInviteConsultationView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/20.
//

#import "BeInviteConsultationView.h"

@interface BeInviteConsultationView()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSArray           *arrayData;
@property (retain, nonatomic) NoDataView        *noDataView;

@end

@implementation BeInviteConsultationView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //[self initData];
        [self setupView];
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.beInviteConsultationViewDelegate && [self.beInviteConsultationViewDelegate respondsToSelector:@selector(actionTableViewCellClickCallback:)]) {
        ConsultationModel *model = self.arrayData[indexPath.row];
        [self.beInviteConsultationViewDelegate actionTableViewCellClickCallback:model];
    }
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
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    __weak typeof(self) wself = self;
    [TTRequestManager meetingListParticipated:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            wself.bLoadData = YES;
            NSDictionary *data = responseObject[@"data"];
            wself.arrayData = [NSArray yy_modelArrayWithClass:[ConsultationModel class] json:data];
            if(wself.arrayData.count == 0) {
                wself.noDataView.hidden = NO;
            }
            [wself reloadData];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)setupView{
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[ConsultationCell class] forCellReuseIdentifier:NSStringFromClass([ConsultationCell class])];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.noDataView];
}

- (NoDataView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight + Ratio35, screenW, screenH)];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

@end
