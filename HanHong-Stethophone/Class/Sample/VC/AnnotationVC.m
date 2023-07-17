//
//  AnnotationVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/27.
//

#import "AnnotationVC.h"
#import "LabelTextFieldItemView.h"
#import "RightDirectionView.h"
#import "Constant.h"
#import "ItemAgeView.h"
//#import "KSYAudioPlotView.h"
//#import "KSYAudioFile.h"
#import "WaveSmallView.h"
#import "AnnotationFullVC.h"
#import "DeviceManagerVC.h"
#import "HHNavigationController.h"
#import "BaseRecordPlayVC.h"
#import "BRPickerView.h"
#import "UINavigationController+QMUI.h"
#import "UIViewController+HBD.h"
#import "AppDelegate.h"
#import "UIDevice+HanHong.h"


@interface AnnotationVC ()<UITextFieldDelegate, TTActionSheetDelegate, UINavigationControllerBackButtonHandlerProtocol>

@property (retain, nonatomic) UIScrollView                  *scrollView;

@property (assign, nonatomic) CGFloat                       itemHeight;

@property (retain, nonatomic) LabelTextFieldItemView              *itemPatientId;//患者ID
@property (retain, nonatomic) RightDirectionView            *itemHeartHungVoice;//音频类别
@property (retain, nonatomic) RightDirectionView            *itempPositionTag;//听诊位置
@property (retain, nonatomic) LabelTextFieldItemView              *itemPatientSymptom;//患者病症
@property (retain, nonatomic) LabelTextFieldItemView              *itemPatientDiagnosis;//诊断
@property (retain, nonatomic) RightDirectionView            *itemPatientSex;//性别
@property (retain, nonatomic) ItemAgeView                   *itemPatientAge;//年龄
@property (retain, nonatomic) LabelTextFieldItemView              *itemPatientHeight;//患者身高
@property (retain, nonatomic) LabelTextFieldItemView              *itemPatientWeight;//患者体重
@property (retain, nonatomic) LabelTextFieldItemView            *itemPatientArea;//患者地区
@property (retain, nonatomic) LabelTextFieldItemView              *itemPatientAnnotation;//标注

@property (retain, nonatomic) WaveSmallView                 *viewSmallWave;

@property (retain, nonatomic) UIButton                      *buttonPlay;
@property (retain, nonatomic) UIButton                      *buttonToAnnotation;
@property (retain, nonatomic) UIView                        *viewLine;
@property (assign, nonatomic) CGFloat                       startYLine;

@property (retain, nonatomic) UIButton                      *buttonSave;
@property (retain, nonatomic) NSMutableArray                *arrayCharacteristic;

@property (assign, nonatomic) Boolean                       bChangeData;


@end

@implementation AnnotationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标注";
    self.arrayCharacteristic = [NSMutableArray array];
    self.view.backgroundColor = WHITECOLOR;
    self.itemHeight = Ratio33;
    [self loadCharacteristicData];
    [self setupView];
    [self reloadAnnotation];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 111) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>24){
            [self.view makeToast:@"你输入的内容过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    } else  if (textField.tag == 1) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>128){
            [self.view makeToast:@"你输入的内容过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    }  else  if (textField.tag == 2) {
        NSString *s = [textField.text stringByAppendingString:string];
        if([Tools checkNameLength:s]>32){
            [self.view makeToast:@"你输入的内容过长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 7) {
        [self actionSelectArea];
        [self.view endEditing:YES];
        return NO;
    }
    //将光标自动移动到最后
    UITextPosition *posotion = [textField endOfDocument];
    textField.selectedTextRange = [textField textRangeFromPosition:posotion toPosition:posotion];
    return YES;
}

- (void)reloadAnnotation{
    NSString *string = @"";
    for (NSDictionary *data in self.arrayCharacteristic) {
        string = [NSString stringWithFormat:@"%@%@,", string , data[@"characteristic"]];
    }
    if (string.length > 0) {
        string = [string substringToIndex:string.length - 1];
        self.itemPatientAnnotation.textFieldInfo.text = string;
    } else {
        self.itemPatientAnnotation.textFieldInfo.text = @"未标注";
    }
    
}

- (void)actionClickSaveAnnotation:(UIButton *)button{
    NSString *characteristics = [Tools convertToJsonData:self.arrayCharacteristic];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"tag"] = self.recordModel.tag;

    params[@"patient_id"] = self.itemPatientId.textFieldInfo.text;
    params[@"patient_area"] = self.itemPatientArea.textFieldInfo.text;/////
    params[@"patient_tag"] = self.recordModel.position_tag;
    params[@"patient_symptom"] = self.itemPatientSymptom.textFieldInfo.text;
    params[@"patient_diagnosis"] = self.itemPatientDiagnosis.textFieldInfo.text;
    NSInteger sex = [self.itemPatientSex.labelInfo.text isEqualToString:@"男"] ? man : woman;
    params[@"patient_sex"] = [@(sex) stringValue];
    params[@"patient_birthday"] = [self getUserBirthday];
    params[@"patient_height"] = self.itemPatientHeight.textFieldInfo.text;
    params[@"patient_weight"] = self.itemPatientWeight.textFieldInfo.text;
    params[@"characteristics"] = characteristics;
    [Tools showWithStatus:@"正在保存"];
    __weak typeof(self) wself = self;
    [TTRequestManager recordModify:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            wself.recordModel.characteristics = characteristics;
            if (wself.resultBlock) {
                wself.resultBlock(wself.recordModel);
            }
            [wself.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                [wself.navigationController popViewControllerAnimated:YES];
            }];
            wself.bChangeData = NO;
        } else {
            [wself.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }
       
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)loadCharacteristicData{
    NSLog(@"self.recordModel.characteristics = %@", self.recordModel.characteristics);
    if (![Tools isBlankString:self.recordModel.characteristics]) {
        NSArray *array = [Tools jsonData2Array:self.recordModel.characteristics];
        [self.arrayCharacteristic addObjectsFromArray:array];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger tag = textField.tag;
    NSString *text = textField.text;
    Boolean changeValue = NO;
    if (tag == 1 && ![self.recordModel.patient_symptom isEqualToString:text]) {
        changeValue = YES;
        self.recordModel.patient_symptom = text;
    } else if (tag == 2  && ![self.recordModel.patient_diagnosis isEqualToString:text]) {
        changeValue = YES;
        self.recordModel.patient_diagnosis = text;
    } else if (tag == 3 || tag == 4) {
        NSString *age = self.itemPatientAge.textFieldAge.text;
        NSString *mouth = self.itemPatientAge.textFieldMonth.text;
        NSDictionary *data = [Tools getAgeFromBirthday:self.recordModel.patient_birthday];
        NSString *age1 = data[@"age"];
        NSString *mouth1 = data[@"month"];
        if(![age isEqualToString:age1] || ![mouth isEqualToString:mouth1]) {
            self.recordModel.patient_birthday = [self getUserBirthday];
            changeValue = YES;
        }
        
    } else if (tag == 5 && ![self.recordModel.patient_height isEqualToString:text]) {
        self.recordModel.patient_height = text;
        changeValue = YES;
    } else if (tag == 6 && ![self.recordModel.patient_weight isEqualToString:text]) {
        self.recordModel.patient_weight = text;
        changeValue = YES;
    } else if (tag == 111 && ![self.recordModel.patient_id isEqualToString:text]) {
        self.recordModel.patient_id = text;
        changeValue = YES;
    }
    
    if(self.saveLocation == 0 && changeValue) {
        
        [self modifyDataLocal];
    }
    if (changeValue) {
        self.bChangeData = YES;
    }
    

    
}

- (NSString *)getUserBirthday{
    NSString *age = self.itemPatientAge.textFieldAge.text;
    NSString *mouth = self.itemPatientAge.textFieldMonth.text;
    NSInteger mounthCout = [mouth integerValue] + [age integerValue] * 12;
    return [Tools dateAddMinuteYMD:[NSDate now] mouth:-1 * mounthCout];
}

- (void)actionClickPlay:(UIButton *)button{
    if(![[HHBlueToothManager shareManager] getConnectState]) {
        [self.view makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if (!self.bPlaying) {
        button.selected = YES;
        [self actionToStar:0 endTime:0];
    } else {
        button.selected = NO;
        [self stopPlayRecord];
    }
}

- (void)reloadAnnotationView{
    NSString *string = @"";
    
    for (NSDictionary *data in self.arrayCharacteristic) {
        //string = [NSString stringWithFormat:@"%@," [data ke]];
        NSLog(@"data= %@", data);
        string = [NSString stringWithFormat:@"%@%@,", string , data[@"characteristic"]];
        NSLog(@"string= %@", string);
    }
    if (string.length > 0) {
        string = [string substringToIndex:string.length - 1];
        self.itemPatientAnnotation.textFieldInfo.text = string;
    } else {
        self.itemPatientAnnotation.textFieldInfo.text = @"未标注";
    }
    
    if(self.saveLocation == 0 && self.arrayCharacteristic.count > 0) {
        self.recordModel.characteristics = [Tools convertToJsonData:self.arrayCharacteristic];
        [self modifyDataLocal];
    }
}

- (void)modifyDataLocal{
    Boolean result = [[HHDBHelper shareInstance] updateRecordItem:self.recordModel.tag record:self.recordModel];
    if (result) {
        NSLog(@"保存数据库成功");
        if (self.resultBlock) {
            self.resultBlock(self.recordModel);
        }
    } else {
        NSLog(@"保存数据库失败");
    }
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    [self.view endEditing:YES];
    self.itemPatientSex.labelInfo.text = index == man ? @"女" : @"男";
    self.itemPatientSex.labelInfo.textColor = MainBlack;
    
    if(self.saveLocation == 0) {
        self.recordModel.patient_sex = tag;
        [self modifyDataLocal];
    }
}

- (void)actionDeviceHelperPlayBegin{
    self.viewLine.hidden = NO;
}

- (void)actionDeviceHelperPlayingTime:(float)value{
    CGFloat width = value / self.recordModel.record_length * (screenW - Ratio22);
    self.viewLine.frame = CGRectMake(Ratio11+width, self.startYLine, Ratio1, Ratio135);
}

- (void)actionDeviceHelperPlayEnd{
    self.buttonPlay.selected = NO;
    self.viewLine.frame = CGRectMake(Ratio11, self.startYLine, Ratio0_5, Ratio135);
    self.viewLine.hidden = YES;
}

- (void)actionClickBlueTooth:(UIButton *)button{
    DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
    [self.navigationController pushViewController:deviceManager animated:YES];
}

- (void)setupView{
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, 0);
    
    [ self.scrollView addSubview:self.itemPatientId];
    self.itemPatientId.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.scrollView, 0).heightIs(self.itemHeight);
    [ self.scrollView addSubview:self.itemHeartHungVoice];
    self.itemHeartHungVoice.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientId, 0).heightIs(self.itemHeight);
    
    [ self.scrollView addSubview:self.itemPatientSymptom];
    [ self.scrollView addSubview:self.itemPatientDiagnosis];
    [ self.scrollView addSubview:self.itemPatientSex];
    [ self.scrollView addSubview:self.itemPatientAge];
    [ self.scrollView addSubview:self.itemPatientHeight];
    [ self.scrollView addSubview:self.itemPatientWeight];
    [ self.scrollView addSubview:self.itemPatientArea];
    [ self.scrollView addSubview:self.itemPatientAnnotation];
    
    if(![Tools isBlankString:self.recordModel.position_tag])  {
        [ self.scrollView addSubview:self.itempPositionTag];
        self.itempPositionTag.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemHeartHungVoice, 0).heightIs(self.itemHeight);
        self.itemPatientSymptom.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itempPositionTag, 0).heightIs(self.itemHeight);
    } else {
        self.itemPatientSymptom.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemHeartHungVoice, 0).heightIs(self.itemHeight);
    }
    
    
    
    self.itemPatientDiagnosis.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientSymptom, 0).heightIs(self.itemHeight);
    self.itemPatientSex.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientDiagnosis, 0).heightIs(self.itemHeight);
    self.itemPatientAge.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientSex, 0).heightIs(self.itemHeight);
    self.itemPatientHeight.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientAge, 0).heightIs(self.itemHeight);
    self.itemPatientWeight.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientHeight, 0).heightIs(self.itemHeight);
    self.itemPatientArea.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientWeight, 0).heightIs(self.itemHeight);
    self.itemPatientAnnotation.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientArea, 0).heightIs(self.itemHeight);
    
    [ self.scrollView addSubview:self.viewSmallWave];
    [ self.scrollView addSubview:self.audioPlotView];
    self.viewSmallWave.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientAnnotation, Ratio22).heightIs(135.f*screenRatio);
    self.audioPlotView.sd_layout.leftSpaceToView( self.scrollView, Ratio11).rightSpaceToView( self.scrollView, Ratio11).topSpaceToView(self.itemPatientAnnotation, Ratio22).heightIs(135.f*screenRatio);
    
    [ self.scrollView addSubview:self.buttonPlay];
    self.buttonPlay.sd_layout.centerXEqualToView( self.scrollView).widthIs(Ratio44).heightIs(Ratio44).topSpaceToView(self.viewSmallWave, Ratio5);
    [ self.scrollView addSubview:self.buttonToAnnotation];
    self.buttonToAnnotation.sd_layout.centerYEqualToView(self.buttonPlay).heightIs(Ratio20).rightSpaceToView( self.scrollView, Ratio8).widthIs(Ratio77);
    [ self.scrollView addSubview:self.viewLine];
    if (self.saveLocation == 1) {
        [ self.scrollView addSubview:self.buttonSave];
        self.buttonSave.sd_layout.leftSpaceToView( self.scrollView, Ratio22).rightSpaceToView( self.scrollView, Ratio22).topSpaceToView(self.buttonPlay, Ratio11).heightIs(Ratio36);
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat maxY = CGRectGetMaxY(self.buttonSave.frame);
        self.scrollView.contentSize = CGSizeMake(screenW, maxY + Ratio55);
        self.startYLine = CGRectGetMinY(self.viewSmallWave.frame);
        self.viewLine.frame = CGRectMake(Ratio11, self.startYLine, Ratio0_5, Ratio135);
    });
    [self openFileWithFilePathURL];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _scrollView;
}


- (LabelTextFieldItemView *)itemPatientId{
    if (!_itemPatientId) {
        _itemPatientId = [[LabelTextFieldItemView alloc] initWithTitle:@"患者ID" bMust:NO placeholder:@""];
        if(![Tools isBlankString:self.recordModel.patient_id]) {
            _itemPatientId.textFieldInfo.text = self.recordModel.patient_id;
//            _itemPatientId.textFieldInfo.enabled = NO;
            
        }
        _itemPatientId.textFieldInfo.placeholder = @"请输入患者ID";
        _itemPatientId.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientId.textFieldInfo.delegate = self;
        _itemPatientId.textFieldInfo.tag = 111;
    }
    return _itemPatientId;
}

- (RightDirectionView *)itemHeartHungVoice{
    if (!_itemHeartHungVoice) {
        _itemHeartHungVoice = [[RightDirectionView alloc] initWithTitle:@"音频类别"];
        if (self.recordModel.type_id == heart_sounds) {
            _itemHeartHungVoice.labelInfo.text = @"心音";
        } else if (self.recordModel.type_id == lung_sounds) {
            _itemHeartHungVoice.labelInfo.text = @"肺音";
        } else {
            _itemHeartHungVoice.labelInfo.text = @"";
        }
        __weak typeof(self) wself = self;
        _itemHeartHungVoice.tapBlock = ^{
            [wself.view makeToast:@"该项不允许修改" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        };
    }
    return _itemHeartHungVoice;
}

- (RightDirectionView *)itempPositionTag{
    if (!_itempPositionTag) {
        _itempPositionTag = [[RightDirectionView alloc] initWithTitle:@"听诊位置"];
        if (![Tools isBlankString:self.recordModel.position_tag]) {
            _itempPositionTag.labelInfo.text = [[Constant shareManager] positionTagPositionCn:self.recordModel.position_tag];
            _itempPositionTag.labelInfo.textColor = MainBlack;
        } else {
            _itempPositionTag.labelInfo.text = @"请选择听诊位置";
            _itempPositionTag.labelInfo.textColor = PlaceholderColor;
        }
        __weak typeof(self) wself = self;
        _itempPositionTag.tapBlock = ^{
            [wself.view makeToast:@"该项不允许修改" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        };
        
    }
    return _itempPositionTag;
}

- (LabelTextFieldItemView *)itemPatientSymptom{
    if (!_itemPatientSymptom) {
        _itemPatientSymptom = [[LabelTextFieldItemView alloc] initWithTitle:@"患者病症" bMust:NO placeholder:@"请输入患者病症"];
        if (![Tools isBlankString:self.recordModel.patient_symptom]) {
            _itemPatientSymptom.textFieldInfo.text = self.recordModel.patient_symptom;
        }
        _itemPatientSymptom.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientSymptom.textFieldInfo.delegate = self;
        _itemPatientSymptom.textFieldInfo.tag = 1;
    }
    return _itemPatientSymptom;
}

- (LabelTextFieldItemView *)itemPatientDiagnosis{
    if (!_itemPatientDiagnosis) {
        _itemPatientDiagnosis = [[LabelTextFieldItemView alloc] initWithTitle:@"诊断结果" bMust:NO placeholder:@"请输入诊断结果"];
        if (![Tools isBlankString:self.recordModel.patient_diagnosis]) {
            _itemPatientDiagnosis.textFieldInfo.text = self.recordModel.patient_diagnosis;
        }
        _itemPatientDiagnosis.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientDiagnosis.textFieldInfo.delegate = self;
        _itemPatientDiagnosis.textFieldInfo.tag = 2;
    }
    return _itemPatientDiagnosis;
}

- (RightDirectionView *)itemPatientSex{
    if (!_itemPatientSex) {
        _itemPatientSex = [[RightDirectionView alloc] initWithTitle:@"性别"];
        _itemPatientSex.labelInfo.text = self.recordModel.patient_sex == man ? @"男" : @"女";
        __weak typeof(self) wself = self;
        _itemPatientSex.tapBlock = ^{
            wself.bChangeData = YES;
            [wself actionSelectSex];
        };
    }
    return _itemPatientSex;
}

- (void)actionSelectSex{
    TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[@"男", @"女"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (ItemAgeView *)itemPatientAge{
    if (!_itemPatientAge) {
        _itemPatientAge = [[ItemAgeView alloc] init];
        if (![Tools isBlankString:self.recordModel.patient_birthday]) {
            NSDictionary *data = [Tools getAgeFromBirthday:self.recordModel.patient_birthday];
            _itemPatientAge.textFieldAge.text = data[@"age"];
            _itemPatientAge.textFieldMonth.text = data[@"month"];
        } else {
            _itemPatientAge.textFieldAge.text = @"0";
            _itemPatientAge.textFieldMonth.text = @"0";
        }
        _itemPatientAge.textFieldAge.returnKeyType = UIReturnKeyDone;
        _itemPatientAge.textFieldAge.delegate = self;
        _itemPatientAge.textFieldAge.tag = 3;
        _itemPatientAge.textFieldAge.keyboardType = UIKeyboardTypeNumberPad;
        
        _itemPatientAge.textFieldMonth.returnKeyType = UIReturnKeyDone;
        _itemPatientAge.textFieldMonth.delegate = self;
        _itemPatientAge.textFieldMonth.tag = 4;
        _itemPatientAge.textFieldMonth.keyboardType = UIKeyboardTypeNumberPad;
        
    }
    return _itemPatientAge;
}

- (LabelTextFieldItemView *)itemPatientHeight{
    if (!_itemPatientHeight) {
        _itemPatientHeight = [[LabelTextFieldItemView alloc] initWithTitle:@"身高" bMust:NO placeholder:@""];
        if (![Tools isBlankString:self.recordModel.patient_height]) {
            //_itemPatientHeight.textFieldInfo.enabled = NO;
            _itemPatientHeight.textFieldInfo.text = self.recordModel.patient_height;
        } else {
            _itemPatientHeight.textFieldInfo.text = @"";
        }
        _itemPatientHeight.textFieldInfo.placeholder = @"请输入患者的身高(cm)";
        _itemPatientHeight.textFieldInfo.keyboardType = UIKeyboardTypeNumberPad;
        _itemPatientHeight.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientHeight.textFieldInfo.delegate = self;
        _itemPatientHeight.textFieldInfo.tag = 5;
    }
    return _itemPatientHeight;
}

- (LabelTextFieldItemView *)itemPatientWeight{
    if (!_itemPatientWeight) {
        _itemPatientWeight = [[LabelTextFieldItemView alloc] initWithTitle:@"体重" bMust:NO placeholder:@""];
        if (![Tools isBlankString:self.recordModel.patient_weight]) {
           // _itemPatientWeight.textFieldInfo.enabled = NO;
            _itemPatientWeight.textFieldInfo.text = self.recordModel.patient_weight;
        } else {
            _itemPatientWeight.textFieldInfo.text = @"";
        }
        _itemPatientWeight.textFieldInfo.placeholder = @"请输入患者的体重(kg)";
        _itemPatientWeight.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientWeight.textFieldInfo.keyboardType = UIKeyboardTypeNumberPad;
        _itemPatientWeight.textFieldInfo.delegate = self;
        _itemPatientWeight.textFieldInfo.tag = 6;
    }
    return _itemPatientWeight;
}

- (LabelTextFieldItemView *)itemPatientArea{
    if (!_itemPatientArea) {
        _itemPatientArea = [[LabelTextFieldItemView alloc] initWithTitle:@"患者地区" bMust:NO placeholder:@"请选择患者的地区"];
        if (![Tools isBlankString:self.recordModel.patient_area]) {
            _itemPatientArea.textFieldInfo.text = self.recordModel.patient_area;
        }
        _itemPatientArea.textFieldInfo.delegate = self;
        _itemPatientArea.textFieldInfo.tag = 7;
        _itemPatientArea.bShowDirection = YES;
    }
    return _itemPatientArea;
}

- (void)actionSelectArea{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];//[plistBundle pathForResource:@"BRCity" ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataSource = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //NSArray *dataSource = [NSArray arrayWithContentsOfFile:filePath];
    __weak typeof(self) wself = self;
    [BRAddressPickerView showAddressPickerWithShowType:BRAddressPickerModeArea dataSource:dataSource defaultSelected:nil isAutoSelect:NO themeColor:MainColor resultBlock:^(BRProvinceModel *province, BRCityModel *city, BRAreaModel *area) {
       // wself.itemPatientArea.textFieldInfo.textColor = MainBlack;
        NSString *result = [NSString stringWithFormat:@"%@%@%@", province.name, city.name, area.name];
        wself.itemPatientArea.textFieldInfo.text = result;
        wself.bChangeData = YES;
        if(self.saveLocation == 0) {
            wself.recordModel.patient_area = result;
            [self modifyDataLocal];
           
        }
    } cancelBlock:^{
        DDLogInfo(@"点击了背景视图或取消按钮");
    }];
}

- (LabelTextFieldItemView *)itemPatientAnnotation{
    if (!_itemPatientAnnotation) {
        _itemPatientAnnotation = [[LabelTextFieldItemView alloc] initWithTitle:@"标注" bMust:NO placeholder:@""];
        _itemPatientAnnotation.textFieldInfo.enabled = NO;
        
        _itemPatientAnnotation.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientAnnotation.textFieldInfo.delegate = self;
    }
    return _itemPatientAnnotation;
}

- (WaveSmallView *)viewSmallWave{
    if (!_viewSmallWave) {
        _viewSmallWave = [[WaveSmallView alloc] initWithFrame:CGRectZero recordModel:self.recordModel];
        _viewSmallWave.backgroundColor = MainBlack;
        
    }
    return _viewSmallWave;
}


- (UIButton *)buttonPlay{
    if(!_buttonPlay) {
        _buttonPlay = [[UIButton alloc] init];
        [_buttonPlay setImage:[UIImage imageNamed:@"start_play"] forState:UIControlStateNormal];
        [_buttonPlay setImage:[UIImage imageNamed:@"pause_play"] forState:UIControlStateSelected];
        [_buttonPlay addTarget:self action:@selector(actionClickPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonPlay;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //self.bCurrentView = YES;
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // 关闭横屏仅允许竖屏
    appDelegate.allowRotation = NO;
    // 切换到竖屏
    [UIDevice deviceMandatoryLandscapeWithNewOrientation:UIInterfaceOrientationPortrait];
}

//切换页面时停止播放
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //self.bCurrentView = NO;
    //[self stopPlayRecord];
}

- (UIButton *)buttonToAnnotation{
    if (!_buttonToAnnotation) {
        _buttonToAnnotation = [[UIButton alloc] init];
        [_buttonToAnnotation setTitle:@"进入标注>>" forState:UIControlStateNormal];
        [_buttonToAnnotation setTitleColor:MainColor forState:UIControlStateNormal];
        _buttonToAnnotation.titleLabel.font = Font12;
        [_buttonToAnnotation addTarget:self action:@selector(actionToAnnotationFull:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonToAnnotation;
}

- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = WHITECOLOR;
        _viewLine.hidden = YES;
    }
    return _viewLine;
}


- (void)actionToAnnotationFull:(UIButton *)button{
    AnnotationFullVC *annotationFull = [[AnnotationFullVC alloc] init];
    NSArray *array = [Tools jsonData2Array:self.recordModel.characteristics];
    self.arrayCharacteristic = [NSMutableArray arrayWithArray:array];
    annotationFull.recordModel = self.recordModel;
    annotationFull.saveLocation = self.saveLocation;
    annotationFull.arrayCharacteristic = self.arrayCharacteristic;
    __weak typeof(self) wself = self;
    annotationFull.resultBlock = ^(Boolean bChangeValue) {
        wself.bChangeData = bChangeValue;
        [wself reloadAnnotationView];
    };
    [self.navigationController pushViewController:annotationFull animated:NO];
}
//https://www.hedelongcloud.com/api/record/share_brief/IX93fzFS3Ilo2Tey5aq3SQ==
//https://www.hedelongcloud.com/api/record/share_brief/oUcU3NzUdxipYKXOSlR6hg==
- (UIButton *)buttonSave{
    if (!_buttonSave) {
        _buttonSave = [[UIButton alloc] init];
        [_buttonSave setTitle:@"保存" forState:UIControlStateNormal];
        [_buttonSave setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonSave.titleLabel.font = Font15;
        _buttonSave.backgroundColor = MainColor;
        _buttonSave.layer.cornerRadius = Ratio18;
        [_buttonSave addTarget:self action:@selector(actionClickSaveAnnotation:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonSave;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//self.saveLocation


- (BOOL)shouldHoldBackButtonEvent {
    if(self.saveLocation == 1 && self.bChangeData) {
        return YES;
    } else {
        return NO;
    }
     
}

- (BOOL)canPopViewController {
    // 这里不要做一些费时的操作，否则可能会卡顿。
    [Tools showAlertView:nil andMessage:@"您修改的内容未保存，是否保存？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
        [self actionClickSaveAnnotation:self.buttonSave];
    } cancel:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    return NO;
}

@end
