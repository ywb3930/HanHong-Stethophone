//
//  RecordListVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "RecordListVC.h"
#import "TTPopView.h"
#import "LRTextField.h"
#import "RecordListCell.h"
#import "AnnotationVC.h"

@interface RecordListVC ()<TTPopViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UIButton              *selectButton;
@property (retain, nonatomic) TTPopView             *popView;
@property (retain, nonatomic) NSArray               *listInfo;
@property (retain, nonatomic) LRTextField           *textField;
@property (retain, nonatomic) UITableView           *recordTableView;
@property (retain, nonatomic) NSMutableArray        *arrayData;
@property (assign, nonatomic) NSInteger             selectMode;

@end

@implementation RecordListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectMode = 0;
    self.arrayData = [NSMutableArray array];
    self.view.backgroundColor = HEXCOLOR(0xE2E8F0, 1);
    if (self.idx == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLocalData) name:@"add_record_success" object:nil];
    }
}

- (void)actionSelectedInfoCallBack:(NSString *)info row:(NSInteger)row tag:(NSInteger)tag{
    if(row != self.listInfo.count - 1) {
        [self.selectButton setTitle:self.listInfo[row] forState:UIControlStateNormal];
    }
    self.selectMode = row;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AnnotationVC *annotationVC = [[AnnotationVC alloc] init];
    annotationVC.recordModel = self.arrayData[indexPath.row];
    [self.navigationController pushViewController:annotationVC animated:YES];
    
}

- (void)initLocalData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部",@"便捷录音",@"标准录音",@"患者ID",@"日期",@"标注",@"心音",@"肺音",@"取消"];
    NSInteger localReordFilterType = 0;
    if (self.selectMode == 0) {
        localReordFilterType = All_filtrate_type;
    } else if (self.selectMode == 1) {
        localReordFilterType = Source_quick_filtrate_type;
    } else if (self.selectMode == 2) {
        localReordFilterType = Source_stand_filtrate_type;
    } else if (self.selectMode == 3) {
        localReordFilterType = Serial_number_filtrate_type;
    } else if (self.selectMode == 4) {
        localReordFilterType = Date_filtrate_type;
    } else if (self.selectMode == 5) {
        localReordFilterType = Annotation_filtrate_type;
    } else if (self.selectMode == 6) {
        localReordFilterType = heart_filtrate_type;
    } else if (self.selectMode == 7) {
        localReordFilterType = lung_filtrate_type;
    }
    Boolean mode_select = (localReordFilterType == Source_quick_filtrate_type) || (localReordFilterType == Source_stand_filtrate_type) || (localReordFilterType == Source_remote_filtrate_type);
    NSInteger mode = (localReordFilterType == Source_quick_filtrate_type) ? QuickRecord : ((localReordFilterType == Source_stand_filtrate_type) ? StanarRecord : RemoteRecord);
    Boolean type_select = (localReordFilterType == heart_filtrate_type) || (localReordFilterType == lung_filtrate_type);
    NSInteger type = (localReordFilterType == heart_filtrate_type) ? 1 : 2;
    NSArray *data = [[HHDBHelper shareInstance] selectRecord:mode_select mode:mode typeSelect:type_select type:type];
    [self.arrayData addObjectsFromArray:data];
    [self.recordTableView reloadData];
}

- (void)initCouldData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部", @"患者ID",@"日期",@"标注",@"心音",@"肺音", @"已分享",@"取消"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    [TTRequestManager recordList:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            NSArray *data = [NSArray yy_modelArrayWithClass:[RecordModel class] json:responseObject[@"data"]];
            [self.arrayData addObjectsFromArray:data];
            [self.recordTableView reloadData];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}



- (void)initCollectData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部", @"日期",@"标注",@"心音",@"肺音",@"取消"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordListCell *cell = (RecordListCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RecordListCell class])];
    cell.recordModel = self.arrayData[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 129.f*screenRatio;
}



- (void)initView{
    [self.view addSubview:self.selectButton];
    self.selectButton.sd_layout.leftSpaceToView(self.view, Ratio11).topSpaceToView(self.view, Ratio6).heightIs(Ratio25).widthIs(Ratio66);
    
    [self.view addSubview:self.textField];
    self.textField.sd_layout.leftSpaceToView(self.selectButton, Ratio4).centerYEqualToView(self.selectButton).heightIs(Ratio25).rightSpaceToView(self.view, Ratio11);
    
    [self.view addSubview:self.recordTableView];
    self.recordTableView.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.selectButton, Ratio6).bottomSpaceToView(self.view, kTabBarHeight);
    
}

- (void)actionCilckSelect:(UIButton *)button{
    self.popView.hidden = NO;
}

- (UIButton *)selectButton{
    if(!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        _selectButton.backgroundColor = WHITECOLOR;
        _selectButton.cs_imagePositionMode = ImagePositionModeRight;
        _selectButton.cs_middleDistance = Ratio1;
        //_selectButton.cs_imageSize = CGSizeMake(Ratio16, Ratio16);
        [_selectButton setImage:[UIImage imageNamed:@"pull_down"] forState:UIControlStateNormal];
        [_selectButton setTitle:@"全部" forState:UIControlStateNormal];
        [_selectButton setTitleColor:MainBlack forState:UIControlStateNormal];
        _selectButton.titleLabel.font = Font13;
        _selectButton.layer.cornerRadius = Ratio5;
        _selectButton.layer.borderWidth = Ratio1;
        _selectButton.layer.borderColor = ViewBackGroundColor.CGColor;
        [_selectButton addTarget:self action:@selector(actionCilckSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (TTPopView *)popView{
    if (!_popView) {
        _popView = [[TTPopView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        _popView.hidden = YES;
        _popView.delegate = self;
        [_popView setWidth:screenW listInfo:self.listInfo];
        [kAppWindow addSubview:_popView];
        
    }
    return _popView;
}

- (LRTextField *)textField{
    if(!_textField) {
        _textField = [[LRTextField alloc] init];
        [_textField setPlaceholder:@"请输入搜索内容"];
        _textField.font = [UIFont systemFontOfSize:Ratio10];
        _textField.layer.cornerRadius = Ratio5;
        _textField.layer.borderWidth = Ratio1;
        _textField.layer.borderColor = ViewBackGroundColor.CGColor;
        _textField.backgroundColor = WHITECOLOR;
    }
    return _textField;
}

- (UITableView *)recordTableView{
    if(!_recordTableView) {
        _recordTableView = [[UITableView alloc] init];
        [_recordTableView registerClass:[RecordListCell class] forCellReuseIdentifier:NSStringFromClass([RecordListCell class])];
        _recordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _recordTableView.showsVerticalScrollIndicator = NO;
        _recordTableView.backgroundColor = HEXCOLOR(0xE2E8F0, 1);
        _recordTableView.delegate = self;
        _recordTableView.dataSource = self;
    }
    return _recordTableView;
}

@end
