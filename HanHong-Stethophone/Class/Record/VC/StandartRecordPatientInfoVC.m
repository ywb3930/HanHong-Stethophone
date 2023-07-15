//
//  StandartRecordPatientInfoVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/16.
//

#import "StandartRecordPatientInfoVC.h"
#import "LabelTextFieldItemView.h"
#import "RightDirectionView.h"
#import "ItemAgeView.h"
#import "BRPickerView.h"
#import "StandartRecordVC.h"


@interface StandartRecordPatientInfoVC ()<TTActionSheetDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) LabelTextFieldItemView          *itemViewId;
@property (retain, nonatomic) LabelTextFieldItemView        *itemViewSex;
@property (retain, nonatomic) ItemAgeView               *itemAgeView;
@property (retain, nonatomic) LabelTextFieldItemView          *itemViewHeight;
@property (retain, nonatomic) LabelTextFieldItemView          *itemViewWeight;
@property (retain, nonatomic) LabelTextFieldItemView          *itemViewDisease;
@property (retain, nonatomic) LabelTextFieldItemView          *itemViewDiagnose;
@property (retain, nonatomic) LabelTextFieldItemView        *itemViewArea;

@property (retain, nonatomic) UIView                    *viewTop;
@property (retain, nonatomic) UITableView               *tableView;
@property (retain, nonatomic) UIButton                  *buttonClearHistory;

@property (retain, nonatomic) UIButton                  *buttonNext;
@property (retain, nonatomic) NSMutableArray            *arrayData;

@end

@implementation StandartRecordPatientInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    self.title = @"标准录音";
    [self initView];
    
}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    // 为当前控制器禁用👉右滑返回手势
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//}
//
//- (BOOL)currentViewControllerShouldPop
//{
//    return NO;
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 1) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>128){
            [self.view makeToast:@"你输入的内容过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    } else if (textField.tag == 2) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>32){
            [self.view makeToast:@"你输入的内容过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    } else if (textField.tag == 13) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>32){
            [self.view makeToast:@"你输入的内容过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    }
    return YES;
}

- (void)actionGetPatientList{
    self.arrayData = [[HHDBHelper shareInstance] selectAllPatientHistory];
    NSInteger count = self.arrayData.count;
    if (count > 0) {
        CGFloat height = Ratio33+self.arrayData.count * Ratio28;
        CGFloat showHeight = (height > screenH / 3) ? screenH / 3 : height;
        self.viewTop.hidden = NO;
        self.viewTop.frame = CGRectMake(screenW/2, kNavBarAndStatusBarHeight + Ratio44, screenW/2 - Ratio22, showHeight);
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSInteger tag = textField.tag;
    [self.view endEditing:YES];
    if (tag == 11) {
        [self actionSelectArea];
        return NO;
    } else if (tag == 12) {
        [self actionSelectSex];
        return NO;
    } else if (tag == 13) {
        [self actionGetPatientList];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.viewTop.hidden = YES;
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PatientModel *model = self.arrayData[indexPath.row];
    self.itemViewId.textFieldInfo.text = model.patient_id;
    self.itemViewSex.textFieldInfo.text = (model.patient_sex == man) ? @"女" : @"男";
    self.itemViewHeight.textFieldInfo.text = model.patient_height;
    self.itemViewWeight.textFieldInfo.text = model.patient_weight;
    self.itemViewDiagnose.textFieldInfo.text = model.patient_diagnosis;
    self.itemViewDisease.textFieldInfo.text = model.patient_symptom;
    self.itemViewArea.textFieldInfo.text = model.patient_area;
    if(![Tools isBlankString:model.patient_birthday]) {
        NSDictionary *data = [Tools getAgeFromBirthday:model.patient_birthday];
        self.itemAgeView.textFieldAge.text = data[@"age"];
        self.itemAgeView.textFieldMonth.text = data[@"month"];
    }
   
}

- (void)actionToNextView:(UIButton *)button{
    NSString *patientId = self.itemViewId.textFieldInfo.text;
    if ([Tools isBlankString:patientId]) {
        [self.view makeToast:@"请输入患者ID" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *sexString = self.itemViewSex.textFieldInfo.text;
    if ([Tools isBlankString:sexString]) {
        [self.view makeToast:@"选择患者性别" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    
    NSInteger sex = [sexString isEqualToString:@"男"] ? man : woman;
    NSString *age = self.itemAgeView.textFieldAge.text;
    NSString *mouth = self.itemAgeView.textFieldMonth.text;
    NSInteger mounthCout = [mouth integerValue] + [age integerValue] * 12;
    NSString *birthday = [Tools dateAddMinuteYMD:[NSDate now] mouth:-1 * mounthCout];
    NSLog(@"birthday = %@", birthday);
    //NSInteger year = [[currentDateString substringToIndex:4] integerValue] - age;
    RecordModel *model = [[RecordModel alloc] init];
    model.patient_id = patientId;
    model.patient_sex = sex;
    model.patient_birthday = birthday;
    model.patient_height = self.itemViewHeight.textFieldInfo.text;
    model.patient_weight = self.itemViewWeight.textFieldInfo.text;
    model.patient_symptom = self.itemViewDisease.textFieldInfo.text;
    model.patient_diagnosis = self.itemViewDiagnose.textFieldInfo.text;
    model.patient_area = self.itemViewArea.textFieldInfo.text;
    
    PatientModel *patientModel = [[PatientModel alloc] init];
    patientModel.patient_id = patientId;
    patientModel.patient_sex = sex;
    patientModel.patient_birthday = birthday;
    patientModel.patient_height = model.patient_height;
    patientModel.patient_weight = model.patient_weight;
    patientModel.patient_symptom = model.patient_symptom;
    patientModel.patient_diagnosis = model.patient_diagnosis;
    patientModel.patient_area = model.patient_area;
    
    
    Boolean success = [[HHDBHelper shareInstance] addPatientItemData:patientModel];
    if (success) {
        NSLog(@"保存成功");
    } else {
        NSLog(@"保存失败");
    }
    
    StandartRecordVC *standartRecord = [[StandartRecordVC alloc] init];
    standartRecord.recordModel = model;
    [self.navigationController pushViewController:standartRecord animated:YES];
    
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in marr) {
        if ([vc isKindOfClass:[self class]]) {
            [marr removeObject:vc];
            break;
        }
    }
    self.navigationController.viewControllers = marr;
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    self.itemViewSex.textFieldInfo.text = (index == man) ? @"女" : @"男";
}

- (void)actionSelectArea{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];//[plistBundle pathForResource:@"BRCity" ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataSource = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //NSArray *dataSource = [NSArray arrayWithContentsOfFile:filePath];
    __weak typeof(self) wself = self;
    [BRAddressPickerView showAddressPickerWithShowType:BRAddressPickerModeArea dataSource:dataSource defaultSelected:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(BRProvinceModel *province, BRCityModel *city, BRAreaModel *area) {
        wself.itemViewArea.textFieldInfo.text = [NSString stringWithFormat:@"%@%@%@", province.name, city.name, area.name];

    } cancelBlock:^{
        DDLogInfo(@"点击了背景视图或取消按钮");
    }];
}

- (void)actionSelectSex{
    TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[ @"男", @"女"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
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
    [self.viewTop addSubview:self.tableView];
    [self.viewTop addSubview:self.buttonClearHistory];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //CGFloat y = CGRectGetMaxY(self.itemViewId.frame);
        self.viewTop.frame = CGRectMake(screenW/2, kNavBarAndStatusBarHeight + Ratio44, screenW/2 - Ratio22, Ratio33);
        self.tableView.sd_layout.leftSpaceToView(self.viewTop, 0).topSpaceToView(self.viewTop, 0).rightSpaceToView(self.viewTop, 0).bottomSpaceToView(self.viewTop, Ratio33);
        self.buttonClearHistory.sd_layout.rightSpaceToView(self.viewTop, 0).bottomSpaceToView(self.viewTop, 0).heightIs(Ratio33).widthIs(Ratio55);
    });
    
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
        [_buttonClearHistory addTarget:self action:@selector(actionClearHistory:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonClearHistory;
}

- (void)actionClearHistory:(UIButton *)button{
     [[HHDBHelper shareInstance] deleteAllPatientData];
    [self.arrayData removeAllObjects];
    [self.tableView reloadData];
    self.viewTop.hidden = YES;
}


- (LabelTextFieldItemView *)itemViewId{
    if(!_itemViewId) {
        _itemViewId = [[LabelTextFieldItemView alloc] initWithTitle:@"患者ID" bMust:NO placeholder:@"请输入患者的ID"];
        _itemViewId.textFieldInfo.delegate = self;
        _itemViewId.textFieldInfo.tag = 13;
    }
    return _itemViewId;
}

- (LabelTextFieldItemView *)itemViewSex{
    if(!_itemViewSex) {
        _itemViewSex = [[LabelTextFieldItemView alloc] initWithTitle:@"性别" bMust:NO placeholder:@"请选择患者的性别"];
        _itemViewSex.textFieldInfo.tag = 12;
        _itemViewSex.textFieldInfo.delegate = self;
        _itemViewSex.bShowDirection = YES;
    }
    return _itemViewSex;
}

- (ItemAgeView *)itemAgeView{
    if(!_itemAgeView) {
        _itemAgeView = [[ItemAgeView alloc] init];
    }
    return _itemAgeView;
}

- (LabelTextFieldItemView *)itemViewHeight{
    if(!_itemViewHeight) {
        _itemViewHeight = [[LabelTextFieldItemView alloc] initWithTitle:@"身高" bMust:NO placeholder:@"请输入患者的身高(cm)"];
    }
    return _itemViewHeight;
}

- (LabelTextFieldItemView *)itemViewWeight{
    if(!_itemViewWeight) {
        _itemViewWeight = [[LabelTextFieldItemView alloc] initWithTitle:@"体重" bMust:NO placeholder:@"请输入患者的体重(kg)"];
    }
    return _itemViewWeight;
}

- (LabelTextFieldItemView *)itemViewDisease{
    if(!_itemViewDisease) {
        _itemViewDisease = [[LabelTextFieldItemView alloc] initWithTitle:@"患者病症" bMust:NO placeholder:@"请输入患者的病症"];
        _itemViewDisease.textFieldInfo.delegate = self;
        _itemViewDisease.textFieldInfo.tag = 1;
    }
    return _itemViewDisease;
}

- (LabelTextFieldItemView *)itemViewDiagnose{
    if(!_itemViewDiagnose) {
        _itemViewDiagnose = [[LabelTextFieldItemView alloc] initWithTitle:@"诊断" bMust:NO placeholder:@"请输入诊断的结果"];
        _itemViewDiagnose.textFieldInfo.delegate = self;
        _itemViewDiagnose.textFieldInfo.tag = 2;
    }
    return _itemViewDiagnose;
}

- (LabelTextFieldItemView *)itemViewArea{
    if(!_itemViewArea) {
        _itemViewArea = [[LabelTextFieldItemView alloc] initWithTitle:@"地区" bMust:NO placeholder:@"请选择您的地区"];
        _itemViewArea.textFieldInfo.tag = 11;
        _itemViewArea.textFieldInfo.delegate = self;
        _itemViewArea.bShowDirection = YES;
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

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    }
    return _tableView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    PatientModel *model = self.arrayData[indexPath.row];
    cell.textLabel.text = model.patient_id;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = Font13;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio28;
}



- (BOOL)shouldHoldBackButtonEvent {
    return YES;
}

- (BOOL)canPopViewController {
    // 这里不要做一些费时的操作，否则可能会卡顿。
    [Tools showAlertView:nil andMessage:@"确定退出吗？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
        [self.navigationController popViewControllerAnimated:YES];
    } cancel:^{
        
    }];
    return NO;
}



@end
