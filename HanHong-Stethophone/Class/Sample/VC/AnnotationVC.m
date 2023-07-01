//
//  AnnotationVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/27.
//

#import "AnnotationVC.h"
#import "RegisterItemView.h"
#import "RightDirectionView.h"
#import "Constant.h"
#import "ItemAgeView.h"

@interface AnnotationVC ()<UITextFieldDelegate>

@property (retain, nonatomic) UIScrollView                  *scrollView;

@property (assign, nonatomic) CGFloat                       itemHeight;

@property (retain, nonatomic) RegisterItemView              *itemPatientId;//患者ID
@property (retain, nonatomic) RightDirectionView            *itemHeartHungVoice;//音频类别
@property (retain, nonatomic) RightDirectionView            *itempPositionTag;//听诊位置
@property (retain, nonatomic) RegisterItemView              *itemPatientSymptom;//患者病症
@property (retain, nonatomic) RegisterItemView              *itemPatientDiagnosis;//诊断
@property (retain, nonatomic) RightDirectionView            *itemPatientSex;//性别
@property (retain, nonatomic) ItemAgeView                   *itemPatientAge;//年龄
@property (retain, nonatomic) RegisterItemView              *itemPatientHeight;//患者身高
@property (retain, nonatomic) RegisterItemView              *itemPatientWeight;//患者体重
@property (retain, nonatomic) RightDirectionView            *itemPatientArea;//患者地区
@property (retain, nonatomic) RegisterItemView              *itemPatientAnnotation;//标注

@end

@implementation AnnotationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"标注";
    self.itemHeight = Ratio40;
    [self setupView];
}

- (void)actionClickBlueTooth:(UIButton *)button{
    
}

- (void)setupView{
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, 0);
    
    [self.scrollView addSubview:self.itemPatientId];
    self.itemPatientId.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.scrollView, 0).heightIs(self.itemHeight);
    [self.scrollView addSubview:self.itemHeartHungVoice];
    self.itemHeartHungVoice.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientId, 0).heightIs(self.itemHeight);
    [self.scrollView addSubview:self.itempPositionTag];
    self.itempPositionTag.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemHeartHungVoice, 0).heightIs(self.itemHeight);
    
    
    [self.scrollView addSubview:self.itemPatientSymptom];
    [self.scrollView addSubview:self.itemPatientDiagnosis];
    [self.scrollView addSubview:self.itemPatientSex];
    [self.scrollView addSubview:self.itemPatientAge];
    [self.scrollView addSubview:self.itemPatientHeight];
    [self.scrollView addSubview:self.itemPatientWeight];
    [self.scrollView addSubview:self.itemPatientArea];
    [self.scrollView addSubview:self.itemPatientAnnotation];
    self.itemPatientSymptom.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itempPositionTag, 0).heightIs(self.itemHeight);
    self.itemPatientDiagnosis.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientSymptom, 0).heightIs(self.itemHeight);
    self.itemPatientSex.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientDiagnosis, 0).heightIs(self.itemHeight);
    self.itemPatientAge.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientSex, 0).heightIs(self.itemHeight);
    self.itemPatientHeight.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientAge, 0).heightIs(self.itemHeight);
    self.itemPatientWeight.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientHeight, 0).heightIs(self.itemHeight);
    self.itemPatientArea.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientWeight, 0).heightIs(self.itemHeight);
    self.itemPatientAnnotation.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemPatientArea, 0).heightIs(self.itemHeight);
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


- (RegisterItemView *)itemPatientId{
    if (!_itemPatientId) {
        _itemPatientId = [[RegisterItemView alloc] initWithTitle:@"患者ID" bMust:NO placeholder:@""];
        if(![Tools isBlankString:self.recordModel.patient_id]) {
            _itemPatientId.textFieldInfo.text = self.recordModel.patient_id;
            _itemPatientId.textFieldInfo.enabled = NO;
            
        }
        _itemPatientId.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientId.textFieldInfo.delegate = self;
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
        
        
    }
    return _itempPositionTag;
}

- (RegisterItemView *)itemPatientSymptom{
    if (!_itemPatientSymptom) {
        _itemPatientSymptom = [[RegisterItemView alloc] initWithTitle:@"患者病症" bMust:NO placeholder:@"请输入患者病症"];
        if (![Tools isBlankString:self.recordModel.patient_symptom]) {
            _itemPatientSymptom.textFieldInfo.text = self.recordModel.patient_symptom;
        }
        _itemPatientSymptom.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientSymptom.textFieldInfo.delegate = self;
    }
    return _itemPatientSymptom;
}

- (RegisterItemView *)itemPatientDiagnosis{
    if (!_itemPatientDiagnosis) {
        _itemPatientDiagnosis = [[RegisterItemView alloc] initWithTitle:@"诊断结果" bMust:NO placeholder:@"请输入诊断结果"];
        if (![Tools isBlankString:self.recordModel.patient_diagnosis]) {
            _itemPatientDiagnosis.textFieldInfo.text = self.recordModel.patient_diagnosis;
        }
        _itemPatientDiagnosis.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientDiagnosis.textFieldInfo.delegate = self;
    }
    return _itemPatientDiagnosis;
}

- (RightDirectionView *)itemPatientSex{
    if (!_itemPatientSex) {
        _itemPatientSex = [[RightDirectionView alloc] initWithTitle:@"性别"];
        _itemPatientSex.labelInfo.text = self.recordModel.patient_sex == woman ? @"女" : @"男";
    }
    return _itemPatientSex;
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
        
        _itemPatientAge.textFieldMonth.returnKeyType = UIReturnKeyDone;
        _itemPatientAge.textFieldMonth.delegate = self;
        
    }
    return _itemPatientAge;
}

- (RegisterItemView *)itemPatientHeight{
    if (!_itemPatientHeight) {
        _itemPatientHeight = [[RegisterItemView alloc] initWithTitle:@"身高" bMust:NO placeholder:@""];
        if (![Tools isBlankString:self.recordModel.patient_height]) {
            _itemPatientHeight.textFieldInfo.enabled = NO;
            _itemPatientHeight.textFieldInfo.text = self.recordModel.patient_height;
        } else {
            _itemPatientHeight.textFieldInfo.placeholder = @"请输入患者的身高(cm)";
        }
        _itemPatientHeight.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientHeight.textFieldInfo.delegate = self;
    }
    return _itemPatientHeight;
}

- (RegisterItemView *)itemPatientWeight{
    if (!_itemPatientWeight) {
        _itemPatientWeight = [[RegisterItemView alloc] initWithTitle:@"体重" bMust:NO placeholder:@""];
        if (![Tools isBlankString:self.recordModel.patient_weight]) {
            _itemPatientWeight.textFieldInfo.enabled = NO;
            _itemPatientWeight.textFieldInfo.text = self.recordModel.patient_weight;
        } else {
            _itemPatientWeight.textFieldInfo.placeholder = @"请输入患者的体重(kg)";
        }
        _itemPatientWeight.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientWeight.textFieldInfo.delegate = self;
    }
    return _itemPatientWeight;
}

- (RightDirectionView *)itemPatientArea{
    if (!_itemPatientArea) {
        _itemPatientArea = [[RightDirectionView alloc] initWithTitle:@"患者地区"];
        if (![Tools isBlankString:self.recordModel.patient_area]) {
            _itemPatientArea.labelInfo.text = self.recordModel.patient_area;
            _itemPatientArea.labelInfo.textColor = MainBlack;
        } else {
            _itemPatientArea.labelInfo.text = @"请选择患者的地区";
            _itemPatientArea.labelInfo.textColor = PlaceholderColor;
        }
    }
    return _itemPatientArea;
}

- (RegisterItemView *)itemPatientAnnotation{
    if (!_itemPatientAnnotation) {
        _itemPatientAnnotation = [[RegisterItemView alloc] initWithTitle:@"标注" bMust:NO placeholder:@""];
        _itemPatientAnnotation.textFieldInfo.enabled = NO;
        if ([Tools isBlankString:self.recordModel.characteristics]) {
            _itemPatientAnnotation.textFieldInfo.text = @"未标注";
        } else {
            NSArray *array = [Tools jsonData2Array:self.recordModel.characteristics];
            NSString *string = @"";
            for (NSDictionary *data in array) {
                //string = [NSString stringWithFormat:@"%@," [data ke]];
                string = [NSString stringWithFormat:@"%@%@,", string , data[@"characteristic"]];
            }
            if (string.length > 0) {
                string = [string substringToIndex:string.length - 1];
            }
            _itemPatientAnnotation.textFieldInfo.text = string;
        }
        _itemPatientAnnotation.textFieldInfo.returnKeyType = UIReturnKeyDone;
        _itemPatientAnnotation.textFieldInfo.delegate = self;
    }
    return _itemPatientAnnotation;
}

@end
