//
//  TeachingRecordView.m
//  HanHong-Stethophone
//  教学记录
//  Created by 袁文斌 on 2023/6/25.
//

#import "TeachingRecordView.h"
#import "TeachingRecordCell.h"
#import "TeachingHistoryModel.h"

@interface TeachingRecordView()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UIView                *viewTop;
@property (retain, nonatomic) UILabel               *labelNumber;
@property (retain, nonatomic) UILabel               *labelDate;
@property (retain, nonatomic) UILabel               *labelTeachStatus;
@property (retain, nonatomic) UILabel               *labelLearnCount;
@property (retain, nonatomic) UILabel               *labelLearnMember;

@property (retain, nonatomic) UITableView           *tableView;
@property (retain, nonatomic) NSArray               *arrayData;

@end

@implementation TeachingRecordView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor  = WHITECOLOR;
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TeachingRecordCell *cell = (TeachingRecordCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TeachingRecordCell class])];
    cell.teachingHistoryModel = self.arrayData[indexPath.row];
    cell.number = indexPath.row;
    return cell;
}

- (void)setupView{
    [self addSubview:self.viewTop];
    self.viewTop.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).topSpaceToView(self, 0).heightIs(Ratio40);
    
    [self.viewTop addSubview:self.labelNumber];
    [self.viewTop addSubview:self.labelDate];
    [self.viewTop addSubview:self.labelTeachStatus];
    [self.viewTop addSubview:self.labelLearnCount];
    [self.viewTop addSubview:self.labelLearnMember];
    self.labelNumber.sd_layout.centerYEqualToView(self.viewTop).leftSpaceToView(self.viewTop, 0).heightIs(Ratio22).widthIs(Ratio44);
    self.labelLearnMember.sd_layout.centerYEqualToView(self.viewTop).rightSpaceToView(self.viewTop, 0).heightIs(Ratio22).widthIs(Ratio60);
    self.labelLearnCount.sd_layout.centerYEqualToView(self.viewTop).rightSpaceToView(self.labelLearnMember, 0).heightIs(Ratio22).widthIs(Ratio60);
    self.labelTeachStatus.sd_layout.centerYEqualToView(self.viewTop).rightSpaceToView(self.labelLearnCount, 0).heightIs(Ratio22).widthIs(Ratio60);
    self.labelDate.sd_layout.leftSpaceToView(self.labelNumber, 0).rightSpaceToView(self.labelTeachStatus, 0).heightIs(Ratio22).centerYEqualToView(self.viewTop);
    
    [self addSubview:self.tableView];
    self.tableView.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self.viewTop, 0).rightSpaceToView(self, 0).bottomSpaceToView(self, 0);
    
    [self initData];
}

- (void)initData{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    [TTRequestManager teachingGetHistory:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            self.arrayData = [NSArray yy_modelArrayWithClass:[TeachingHistoryModel class] json:responseObject[@"data"]];
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[TeachingRecordCell class] forCellReuseIdentifier:NSStringFromClass([TeachingRecordCell class])];
    }
    return _tableView;
}

- (UIView *)viewTop{
    if (!_viewTop) {
        _viewTop = [[UIView alloc] init];
        _viewTop.backgroundColor = ColorDAECFD;
    }
    return _viewTop;
}

- (UILabel *)labelNumber{
    if (!_labelNumber) {
        _labelNumber = [self setLabel:@"编号"];
    }
    return _labelNumber;
}

- (UILabel *)labelDate{
    if (!_labelDate) {
        _labelDate = [self setLabel:@"日期"];
    }
    return _labelDate;
}

- (UILabel *)labelTeachStatus{
    if (!_labelTeachStatus) {
        _labelTeachStatus = [self setLabel:@"教学状态"];
    }
    return _labelTeachStatus;
}

- (UILabel *)labelLearnCount{
    if (!_labelLearnCount) {
        _labelLearnCount = [self setLabel:@"学习次数"];
    }
    return _labelLearnCount;
}

- (UILabel *)labelLearnMember{
    if (!_labelLearnMember) {
        _labelLearnMember = [self setLabel:@"学习人数"];
    }
    return _labelLearnMember;
}

- (UILabel *)setLabel:(NSString *)string{
    UILabel *label = [[UILabel alloc] init];
    label.text = string;
    label.textColor = MainColor;
    label.font = Font13;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

@end
