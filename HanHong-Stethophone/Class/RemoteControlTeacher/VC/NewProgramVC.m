//
//  NewProgramVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/25.
//

#import "NewProgramVC.h"
#import "RightDirectionView.h"
#import "LabelTextFieldItemView.h"
#import "BRPickerView.h"

@interface NewProgramVC ()

@property (retain, nonatomic) RightDirectionView        *itemTimeView;
@property (retain, nonatomic) LabelTextFieldItemView          *itemTitleView;
@property (retain, nonatomic) LabelTextFieldItemView          *itemDurationView;
@property (retain, nonatomic) UILabel                   *labelMinute;

@property (retain, nonatomic) UIButton                  *buttonDelete;
@property (retain, nonatomic) UIView                    *viewLine;

@end

@implementation NewProgramVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.bCreate) {
        self.title = @"新建计划";
    } else {
        self.title = @"修改计划";
    }
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupView];
    
}

- (void)actionDeleteProgram:(UIButton *)button{
    Boolean result = [[HHDBHelper shareInstance] deleteProgramItem:self.programModel.program_id];
    if (result && self.delegate && [self.delegate respondsToSelector:@selector(actionDeleteProgramCallback:)]) {
        [self.delegate actionDeleteProgramCallback:self.programModel];
        [self.view makeToast:@"删除计划成功" duration:showToastViewSuccessTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:add_program_broadcast object:nil];
    }
}

- (void)actionToCommit:(UIBarButtonItem *)item{
    NSString *programTitle = self.itemTitleView.textFieldInfo.text;
    if ([Tools isBlankString:programTitle]) {
        [self.view makeToast:@"请输入计划标题" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *startDateString = self.itemTimeView.labelInfo.text;
    NSString *durationString = self.itemDurationView.textFieldInfo.text;
    if ([Tools isBlankString:durationString]) {
        [self.view makeToast:@"请输入计划时长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSDate *startDate = [Tools stringToDateYMDHM:startDateString];
    NSString *endDateString = [Tools dateAddMinuteYMDHM:startDate minute:[durationString integerValue]];
    NSDate *endDate = [Tools stringToDateYMDHM:endDateString];
    long startTime = [Tools getTimestampSecond:startDate];
    long endTime = [Tools getTimestampSecond:endDate];
    
    if (self.bCreate) {
        ProgramModel *model = [[ProgramModel alloc] init];
        model.program_title = programTitle;
        model.startTime = startTime;
        model.endTime = endTime;
        model.duration = [durationString integerValue];
        model.system_calender_reminder = @"";
        [[HHDBHelper shareInstance] addProgramItem:model];
        [self.view makeToast:@"新增计划成功" duration:showToastViewSuccessTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        self.programModel.program_title = programTitle;
        self.programModel.startTime = startTime;
        self.programModel.endTime = endTime;
        self.programModel.duration = [durationString integerValue];
        Boolean result = [[HHDBHelper shareInstance] updateProgramItem:self.programModel];
        if (result && self.delegate && [self.delegate respondsToSelector:@selector(actionEditProgramCallback:)]) {
            [self.delegate actionEditProgramCallback:self.programModel];
            [self.view makeToast:@"修改计划成功" duration:showToastViewSuccessTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:add_program_broadcast object:nil];
    
}

- (void)actionTapStartTimeItem:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    NSDate *minDate = [Tools dateWithYearsBeforeNow:0];
    NSDate *maxDate = [Tools dateWithYearsBeforeNow:-99];
    NSString *showDate = @"";
    NSDate *currentDate = [NSDate now];
    if (self.bCreate) {
        //dateAddMinute
       // NSDate *A = []
        NSString *stringMin = self.itemTimeView.labelInfo.text;
        NSDate *x = [Tools stringToDateYMDHM:stringMin];
        showDate = [Tools dateAddMinuteYMDHM:x minute:1];
    } else {
        showDate = self.itemTimeView.labelInfo.text;
        NSDate *fromDate = [Tools stringToDateYMDHM:showDate];//
        NSComparisonResult result = [fromDate compare:currentDate];
        if (result == NSOrderedAscending) {
            showDate = [Tools dateToTimeStringYMDHM:currentDate];
        }
    }
    
    
    
    [BRDatePickerView showDatePickerWithTitle:@"请选择会诊开始时间" dateType:BRDatePickerModeYMDHM defaultSelValue:showDate minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:MainColor resultBlock:^(NSString *selectValue) {
        //wself.itemViewBirthDay.textFieldInfo.text = selectValue;
        self.itemTimeView.labelInfo.textColor = MainBlack;
        self.itemTimeView.labelInfo.text = selectValue;
    } cancelBlock:^{
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


- (void)setupView{
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;

    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItems = @[item0,item2];
    item2.action = @selector(actionToCommit:);
    
    [self.view addSubview:self.itemTitleView];
    [self.view addSubview:self.itemTimeView];
    [self.view addSubview:self.itemDurationView];
    [self.view addSubview:self.labelMinute];
    
    self.itemTitleView.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.view, kNavBarAndStatusBarHeight + Ratio11).heightIs(Ratio33);
    self.itemTimeView.sd_layout.leftEqualToView(self.itemTitleView).rightEqualToView(self.itemTitleView).heightIs(Ratio33).topSpaceToView(self.itemTitleView, Ratio5);
    self.itemDurationView.sd_layout.leftEqualToView(self.itemTitleView).topSpaceToView(self.itemTimeView, Ratio10).widthIs(screenW - Ratio66).heightIs(Ratio33);
    self.labelMinute.sd_layout.rightEqualToView(self.itemTitleView).heightIs(Ratio33).centerYEqualToView(self.itemDurationView).leftSpaceToView(self.itemDurationView, 0);
     
    
    NSDate *currentDate = [NSDate now];
    if (self.bCreate) {
        NSString *newDateHm = [Tools dateToTimeStringHM:currentDate];
        NSString *showDate = [NSString stringWithFormat:@"%@ %@", self.selectTime, newDateHm];
        NSDate *fromDate = [Tools stringToDateYMDHM:showDate];//
//        NSString *x = [Tools dateAddMinuteYMDHMS:fromDate minute:8 * 60];
//        NSDate *xx = [Tools stringToDateYMDHMS:x];
        
        NSComparisonResult result = [fromDate compare:currentDate];
        if (result == NSOrderedAscending) {
            showDate = [Tools dateToTimeStringYMDHM:currentDate];
        }
        self.itemTimeView.labelInfo.text = showDate;
    } else {
        [self.view addSubview:self.buttonDelete];
        self.buttonDelete.sd_layout.bottomSpaceToView(self.view, kBottomSafeHeight + Ratio11).centerXEqualToView(self.view).widthIs(Ratio44).heightIs(Ratio44);
        [self.view addSubview:self.viewLine];
        self.viewLine.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).bottomSpaceToView(self.buttonDelete, Ratio8).heightIs(Ratio1);
        
        self.itemTitleView.textFieldInfo.text = self.programModel.program_title;
        self.itemTimeView.labelInfo.text = [Tools convertTimestampToStringYMDHM:self.programModel.startTime];
        self.itemDurationView.textFieldInfo.text = [@(self.programModel.duration) stringValue];
    }
}



- (LabelTextFieldItemView *)itemTitleView{
    if (!_itemTitleView) {
        _itemTitleView = [[LabelTextFieldItemView alloc] initWithTitle:@"计划标题" bMust:NO placeholder:@"请输入计划标题"];
    }
    return _itemTitleView;
}

- (RightDirectionView *)itemTimeView{
    if (!_itemTimeView) {
        _itemTimeView = [[RightDirectionView alloc] initWithTitle:@"开始时间"];
        
        _itemTimeView.labelInfo.textColor = MainBlack;//HEXCOLOR(0xBBBBBB, 1);
        
        _itemTimeView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapStartTimeItem:)];
        [_itemTimeView addGestureRecognizer:tapView];
    }
    return _itemTimeView;
}

- (LabelTextFieldItemView *)itemDurationView{
    if (!_itemDurationView) {
        _itemDurationView = [[LabelTextFieldItemView alloc] initWithTitle:@"计划时长" bMust:NO placeholder:@"请输入计划时长"];
        _itemDurationView.textFieldInfo.keyboardType = UIKeyboardTypeNumberPad;

        
    }
    return _itemDurationView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UILabel *)labelMinute{
    if (!_labelMinute) {
        _labelMinute = [[UILabel alloc] init];
        _labelMinute.text = @"分钟";
        _labelMinute.textColor = MainBlack;
        _labelMinute.textAlignment = NSTextAlignmentRight;
        _labelMinute.font = Font15;
    }
    return _labelMinute;
}

- (UIButton *)buttonDelete{
    if (!_buttonDelete) {
        _buttonDelete = [[UIButton alloc] init];
        _buttonDelete.cs_imagePositionMode = ImagePositionModeTop;
        _buttonDelete.cs_imageSize = CGSizeMake(Ratio22, Ratio22);
        _buttonDelete.cs_middleDistance = Ratio5;
        [_buttonDelete setImage:[UIImage imageNamed:@"trash_can"] forState:UIControlStateNormal];
        [_buttonDelete setTitle:@"删除" forState:UIControlStateNormal];
        [_buttonDelete setTitleColor:MainGray forState:UIControlStateNormal];
        _buttonDelete.titleLabel.font = Font13;
        [_buttonDelete addTarget:self action:@selector(actionDeleteProgram:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonDelete;
}

- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine;
}

@end
