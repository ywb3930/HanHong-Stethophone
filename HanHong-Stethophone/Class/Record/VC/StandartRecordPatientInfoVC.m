//
//  StandartRecordPatientInfoVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/16.
//

#import "StandartRecordPatientInfoVC.h"
#import "RegisterItemView.h"
#import "RightDirectionView.h"
#import "ItemAgeView.h"
#import "BRPickerView.h"
#import "StandartRecordVC.h"

@interface StandartRecordPatientInfoVC ()<TTActionSheetDelegate>

@property (retain, nonatomic) RegisterItemView          *itemViewId;
@property (retain, nonatomic) RightDirectionView        *itemViewSex;
@property (retain, nonatomic) ItemAgeView               *itemAgeView;
@property (retain, nonatomic) RegisterItemView          *itemViewHeight;
@property (retain, nonatomic) RegisterItemView          *itemViewWeight;
@property (retain, nonatomic) RegisterItemView          *itemViewDisease;
@property (retain, nonatomic) RegisterItemView          *itemViewDiagnose;
@property (retain, nonatomic) RightDirectionView        *itemViewArea;

@property (retain, nonatomic) UIView                    *viewTop;
//@property (retain, nonatomic) UITableView               *tableView;
@property (retain, nonatomic) UIButton                  *buttonClearHistory;

@property (retain, nonatomic) UIButton                  *buttonNext;

@end

@implementation StandartRecordPatientInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    self.title = @"标准录音";
    [self initView];
    
}

- (void)actionToNextView:(UIButton *)button{
    StandartRecordVC *standartRecord = [[StandartRecordVC alloc] init];
    [self.navigationController pushViewController:standartRecord animated:YES];
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    self.itemViewSex.labelInfo.text = index == woman ? @"女" : @"男";
}

- (void)actionTap:(UITapGestureRecognizer *)tap{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];//[plistBundle pathForResource:@"BRCity" ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataSource = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //NSArray *dataSource = [NSArray arrayWithContentsOfFile:filePath];
    __weak typeof(self) wself = self;
    [BRAddressPickerView showAddressPickerWithShowType:BRAddressPickerModeArea dataSource:dataSource defaultSelected:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(BRProvinceModel *province, BRCityModel *city, BRAreaModel *area) {

        wself.itemViewArea.labelInfo.text = [NSString stringWithFormat:@"%@%@%@", province.name, city.name, area.name];

    } cancelBlock:^{
        DDLogInfo(@"点击了背景视图或取消按钮");
    }];
}

- (void)actionTapSex:(UITapGestureRecognizer *)tap{
    TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[@"女", @"男"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (void)initView{
    [self.view addSubview:self.itemViewId];
    self.itemViewId.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.view, kNavBarAndStatusBarHeight ).heightIs(Ratio44);
    [self.view addSubview:self.itemViewSex];
    self.itemViewSex.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewId, 0 ).heightIs(Ratio44);
    [self.view addSubview:self.itemAgeView];
    self.itemAgeView.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewSex, 0 ).heightIs(Ratio44);
    [self.view addSubview:self.itemViewHeight];
    [self.view addSubview:self.itemViewWeight];
    [self.view addSubview:self.itemViewDisease];
    [self.view addSubview:self.itemViewDiagnose];
    [self.view addSubview:self.itemViewArea];
    self.itemViewHeight.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemAgeView, 0 ).heightIs(Ratio44);
    self.itemViewWeight.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewHeight, 0 ).heightIs(Ratio44);
    self.itemViewDisease.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewWeight, 0 ).heightIs(Ratio44);
    self.itemViewDiagnose.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewDisease, 0 ).heightIs(Ratio44);
    self.itemViewArea.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.itemViewDiagnose, 0 ).heightIs(Ratio44);
    [self.view addSubview:self.viewTop];
//    [self.viewTop addSubview:self.tableView];
//    [self.viewTop addSubview:self.buttonClearHistory];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CGFloat y = CGRectGetMaxY(self.itemViewId.frame);
//        self.viewTop.frame = CGRectMake(Ratio11, y, screenW - Ratio22, screenH / 3);
//        self.tableView.sd_layout.leftSpaceToView(self.viewTop, 0).topSpaceToView(self.viewTop, 0).rightSpaceToView(self.viewTop, 0).bottomSpaceToView(self.viewTop, Ratio33);
//        self.buttonClearHistory.sd_layout.rightSpaceToView(self.viewTop, 0).bottomSpaceToView(self.viewTop, 0).heightIs(Ratio33).widthIs(Ratio55);
//    });
    
    [self.view addSubview:self.buttonNext];
    self.buttonNext.sd_layout.leftSpaceToView(self.view, Ratio22).rightSpaceToView(self.view, Ratio22).heightIs(Ratio44).topSpaceToView(self.itemViewArea, Ratio33);
}

- (UIView *)viewTop{
    if(!_viewTop) {
        _viewTop = [[UIView alloc] init];
        _viewTop.layer.cornerRadius = Ratio8;
        _viewTop.layer.borderColor = MainNormal.CGColor;
        _viewTop.layer.borderWidth = Ratio1;
        _viewTop.backgroundColor = WHITECOLOR;
        _viewTop.hidden = YES;
    }
    return _viewTop;
}

- (UIButton *)buttonClearHistory{
    if(!_buttonClearHistory) {
        _buttonClearHistory = [[UIButton alloc] init];
        [_buttonClearHistory setTitle:@"清空历史" forState:UIControlStateNormal];
        [_buttonClearHistory setTitleColor:MainBlack forState:UIControlStateNormal];
        _buttonClearHistory.titleLabel.font = Font11;
    }
    return _buttonClearHistory;
}


- (RegisterItemView *)itemViewId{
    if(!_itemViewId) {
        _itemViewId = [[RegisterItemView alloc] initWithTitle:@"患者ID" bMust:NO placeholder:@"请输入患者的ID"];
    }
    return _itemViewId;
}

- (RightDirectionView *)itemViewSex{
    if(!_itemViewSex) {
        _itemViewSex = [[RightDirectionView alloc] initWithTitle:@"性别"];
        _itemViewSex.labelInfo.text = @"请选择患者的性别";
        _itemViewSex.labelInfo.textColor = PlaceholderColor;
        _itemViewSex.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapSex = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapSex:)];
        [_itemViewSex addGestureRecognizer:tapSex];
    }
    return _itemViewSex;
}

- (ItemAgeView *)itemAgeView{
    if(!_itemAgeView) {
        _itemAgeView = [[ItemAgeView alloc] init];
    }
    return _itemAgeView;
}

- (RegisterItemView *)itemViewHeight{
    if(!_itemViewHeight) {
        _itemViewHeight = [[RegisterItemView alloc] initWithTitle:@"身高" bMust:NO placeholder:@"请输入患者的身高(cm)"];
    }
    return _itemViewHeight;
}

- (RegisterItemView *)itemViewWeight{
    if(!_itemViewWeight) {
        _itemViewWeight = [[RegisterItemView alloc] initWithTitle:@"体重" bMust:NO placeholder:@"请输入患者的体重(kg)"];
    }
    return _itemViewWeight;
}

- (RegisterItemView *)itemViewDisease{
    if(!_itemViewDisease) {
        _itemViewDisease = [[RegisterItemView alloc] initWithTitle:@"患者病症" bMust:NO placeholder:@"请输入患者的病症"];
    }
    return _itemViewDisease;
}

- (RegisterItemView *)itemViewDiagnose{
    if(!_itemViewDiagnose) {
        _itemViewDiagnose = [[RegisterItemView alloc] initWithTitle:@"诊断" bMust:NO placeholder:@"请输入诊断的结果"];
    }
    return _itemViewDiagnose;
}

- (RightDirectionView *)itemViewArea{
    if(!_itemViewArea) {
        _itemViewArea = [[RightDirectionView alloc] initWithTitle:@"地区"];
        _itemViewArea.labelInfo.text = @"请选择您的地区";
        _itemViewArea.labelInfo.textColor = PlaceholderColor;
        _itemViewArea.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapArea = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [_itemViewArea addGestureRecognizer:tapArea];
    }
    return _itemViewArea;
}

-(UIButton *)buttonNext{
    if(!_buttonNext) {
        _buttonNext = [[UIButton alloc] init];
        [_buttonNext setTitle:@"下一步" forState:UIControlStateNormal];
        [_buttonNext setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonNext.backgroundColor = MainColor;
        _buttonNext.layer.cornerRadius = Ratio8;
        _buttonNext.titleLabel.font = Font18;
        [_buttonNext addTarget:self action:@selector(actionToNextView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonNext;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    self.viewTop.hidden = YES;
}
//
//- (UITableView *)tableView{
//    if(!_tableView) {
//        _tableView = [[UITableView alloc] init];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//
//    }
//    return _tableView;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 3;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    cell.textLabel.text = @"123";
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return Ratio22;
//}


@end
