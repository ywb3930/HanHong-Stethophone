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
#import "UIView+ConvertRect.h"

@interface StandartRecordPatientInfoVC ()<TTActionSheetDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UIScrollView                  *scrollView;

@property (retain, nonatomic) LabelTextFieldItemView          *itemViewId;
@property (retain, nonatomic) LabelTextFieldItemView        *itemViewSex;
@property (retain, nonatomic) ItemAgeView               *itemAgeView;
@property (retain, nonatomic) LabelTextFieldItemView          *itemViewHeight;
@property (retain, nonatomic) LabelTextFieldItemView          *itemViewWeight;
@property (retain, nonatomic) LabelTextFieldItemView          *itemViewDisease;
@property (retain, nonatomic) LabelTextFieldItemView          *itemViewDiagnose;
@property (retain, nonatomic) LabelTextFieldItemView        *itemViewArea;

@property (retain, nonatomic) UITableView               *tableView;
@property (retain, nonatomic) UIButton                  *buttonClearHistory;
@property (retain, nonatomic) UILabel                   *labelTitle;
@property (retain, nonatomic) UIView                   *viewHeader;
@property (retain, nonatomic) UIView                   *viewBottom;

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

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

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
        CGFloat height = Ratio50+self.arrayData.count * Ratio33;
        CGFloat showHeight = (height > screenH / 3) ? screenH / 3 : height;
        self.tableView.hidden = NO;
       // CGRectMake(screenW/2, kNavBarAndStatusBarHeight + Ratio44, screenW/2 - Ratio22, Ratio33)
        
        self.tableView.frame = CGRectMake(screenW/2, kNavBarAndStatusBarHeight + Ratio44, screenW/2 - Ratio22, showHeight);
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSInteger tag = textField.tag;
    [self.view endEditing:YES];
    if(tag != 13) {
        self.tableView.hidden = YES;
    }
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
    self.tableView.hidden = YES;
    [self.view endEditing:YES];
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, 0);
    
    [self.scrollView addSubview:self.itemViewId];
    self.itemViewId.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.scrollView, 0 ).heightIs(Ratio44);
    [self.scrollView addSubview:self.itemViewSex];
    self.itemViewSex.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemViewId, 0 ).heightIs(Ratio44);
    [self.scrollView addSubview:self.itemAgeView];
    self.itemAgeView.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemViewSex, 0 ).heightIs(Ratio44);
    [self.scrollView addSubview:self.itemViewHeight];
    [self.scrollView addSubview:self.itemViewWeight];
    [self.scrollView addSubview:self.itemViewDisease];
    [self.scrollView addSubview:self.itemViewDiagnose];
    [self.scrollView addSubview:self.itemViewArea];
    self.itemViewHeight.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemAgeView, 0 ).heightIs(Ratio44);
    self.itemViewWeight.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemViewHeight, 0 ).heightIs(Ratio44);
    self.itemViewDisease.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemViewWeight, 0 ).heightIs(Ratio44);
    self.itemViewDiagnose.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemViewDisease, 0 ).heightIs(Ratio44);
    self.itemViewArea.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemViewDiagnose, 0 ).heightIs(Ratio44);
    [self.view addSubview:self.tableView];
    [self.scrollView addSubview:self.buttonNext];
    self.buttonNext.sd_layout.leftSpaceToView(self.scrollView, Ratio22).rightSpaceToView(self.scrollView, Ratio22).heightIs(Ratio44).topSpaceToView(self.itemViewArea, Ratio33);
    
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
    self.tableView.hidden = YES;
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
        _itemAgeView.textFieldAge.delegate = self;
        _itemAgeView.textFieldMonth.delegate = self;
        _itemAgeView.textFieldAge.placeholder = @"0";
        _itemAgeView.textFieldMonth.placeholder = @"0";
    }
    return _itemAgeView;
}

- (LabelTextFieldItemView *)itemViewHeight{
    if(!_itemViewHeight) {
        _itemViewHeight = [[LabelTextFieldItemView alloc] initWithTitle:@"身高" bMust:NO placeholder:@"请输入患者的身高(cm)"];
        _itemViewHeight.textFieldInfo.delegate = self;
    }
    return _itemViewHeight;
}

- (LabelTextFieldItemView *)itemViewWeight{
    if(!_itemViewWeight) {
        _itemViewWeight = [[LabelTextFieldItemView alloc] initWithTitle:@"体重" bMust:NO placeholder:@"请输入患者的体重(kg)"];
        _itemViewWeight.textFieldInfo.delegate = self;
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
    self.tableView.hidden = YES;
}

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionHeaderTopPadding = 0;
        _tableView.layer.cornerRadius = Ratio8;
        _tableView.layer.borderColor = HEXCOLOR(0x0081FF,0.5).CGColor;
        _tableView.layer.borderWidth = Ratio1;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return Ratio22;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    [self.viewBottom addSubview:self.buttonClearHistory];
    self.buttonClearHistory.sd_layout.rightSpaceToView(self.viewBottom, 0).bottomSpaceToView(self.viewBottom, 0).heightIs(Ratio22).widthIs(Ratio55);
    return self.viewBottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio33;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Ratio28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    [self.viewHeader addSubview:self.labelTitle];
    self.labelTitle.sd_layout.leftSpaceToView(self.viewHeader, 0).rightSpaceToView(self.viewHeader, 0).topSpaceToView(self.viewHeader, 0).bottomSpaceToView(self.viewHeader, 0);
    return self.viewHeader;
}


- (UIView *)viewBottom{
    if (!_viewBottom) {
        _viewBottom = [[UIView alloc] init];
        _viewBottom.backgroundColor = WHITECOLOR;
    }
    return _viewBottom;
}

- (UIView *)viewHeader{
    if (!_viewHeader) {
        _viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW/2 - Ratio22, Ratio28)];
        _viewHeader.backgroundColor = WHITECOLOR;
    }
    return _viewHeader;
}

- (UILabel *)labelTitle{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.font = Font13;
        _labelTitle.textColor = MainBlack;
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.text = @"历史记录";
    }
    return _labelTitle;
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


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(textField.tag != 13){
        self.tableView.hidden = YES;
    }
    CGPoint point = [textField.superview frameOriginFromView:self.scrollView];
    [UIView animateWithDuration:0.4f animations:^{
        self.scrollView.contentOffset = CGPointMake(0, point.y);
    }];
}
//
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self scrollViewScrollInInnerArea];
}

- (void)scrollViewScrollInInnerArea {
    if (self.scrollView.contentOffset.y + self.view.height > self.scrollView.contentSize.height) {
        [UIView animateWithDuration:0.4f animations:^{
            self.scrollView.contentOffset = CGPointMake(0, 0);
        }];
    }
}

@end
