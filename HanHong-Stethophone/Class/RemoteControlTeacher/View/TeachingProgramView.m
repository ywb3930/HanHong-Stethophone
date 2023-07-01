//
//  TeachingProgramView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import "TeachingProgramView.h"
#import "HHCalendarView.h"
#import "BRPickerView.h"
#import "NewProgramVC.h"
#import "ProgramPlanListVC.h"

@interface TeachingProgramView()<HHCalendarViewDelegate>

@property (retain, nonatomic) HHCalendarView        *calendarView;
@property (retain, nonatomic) UIButton              *buttonTime;
@property (retain, nonatomic) UILabel               *labelProgramCount;
@property (retain, nonatomic) UILabel               *labelProgramTime;
@property (retain, nonatomic) NSString              *currentTime;
@property (retain, nonatomic) HHCalendarManager     *calendarManager;
@property (retain, nonatomic) NSMutableArray        *programListData;

@end

@implementation TeachingProgramView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ViewBackGroundColor;
        
        self.calendarManager = [HHCalendarManager shareManage];
        [self setupView];
        [self initData:[NSDate now]];
        
    }
    return self;
}



- (void)actionToProgramListVC:(UITapGestureRecognizer *)tap{
    if (self.programListData.count == 0) {
        return;
    }
    UIViewController *currentVC = [Tools currentViewController];
    ProgramPlanListVC *programPlanList = [[ProgramPlanListVC alloc] init];
    programPlanList.programListData = self.programListData;
    [currentVC.navigationController pushViewController:programPlanList animated:YES];
}

- (void)initData:(NSDate *)date{
    self.currentDate = date;
    [self.calendarManager checkThisMonthRecordFromToday:date];
    long startTime = [Tools getTimestampSecond:self.calendarManager.startDate];
    long endTime = [Tools getTimestampSecond:self.calendarManager.endDate];
    self.programListData = [[HHDBHelper shareInstance] selectAllProgramData:startTime endTime:endTime];
    NSInteger programCount = self.programListData.count;
    NSInteger programTimeTotal = 0;
    for (int i = 0; i < self.programListData.count; i++) {
        ProgramModel *programModel = self.programListData[i];
        programTimeTotal += programModel.duration;
        NSString *dayString = [Tools convertTimestampToStringD:programModel.startTime];
        NSInteger dayIntValue = [dayString integerValue];
        for (HHCalendarDayModel  *calendarDayModel in self.calendarManager.calendarDate) {
            if (calendarDayModel.dayValue <= 0) {
                continue;
            }
            if (dayIntValue == calendarDayModel.dayValue) {
                [calendarDayModel.modelList addObject:programModel];
            }
        }
    }
    self.calendarView.calendarManager = self.calendarManager;
    self.labelProgramCount.text = [NSString stringWithFormat:@"该月计划次数:%li次", programCount];
    self.labelProgramTime.text = [NSString stringWithFormat:@"该月计划时长:%li分钟", programTimeTotal];
    CGFloat width1 = (screenW-Ratio44)/7;
    NSInteger count = ceil((self.calendarView.calendarManager.days + self.calendarView.calendarManager.dayInWeek)/7.0f) + 1;
    self.calendarView.frame = CGRectMake(0, Ratio66, screenW, width1 * count);
    

    [self.labelProgramCount updateLayout];
    [self.labelProgramTime updateLayout];
}

- (void)actionClickCalendarItemCallback:(HHCalendarDayModel *)model{
    NSString *day = [@(model.dayValue) stringValue];
    if (model.dayValue < 10) {
        day = [NSString stringWithFormat:@"0%ld",(long) (long)model.dayValue];
    }
    UIViewController *currentVC = [Tools currentViewController];
    NewProgramVC *newProgram = [[NewProgramVC alloc] init];
    newProgram.selectTime = [NSString stringWithFormat:@"%@-%@", self.currentTime, day];
    newProgram.bCreate = YES;
    [currentVC.navigationController pushViewController:newProgram animated:YES];
}


- (void)actionCilckSelectTime:(UIButton *)button{
    NSDate *minDate = [Tools dateWithYearsBeforeNow:99];
    NSDate *maxDate = [Tools dateWithYearsBeforeNow:-99];
    NSString *showDate = [Tools dateToStringYM:[NSDate now]];

    [BRDatePickerView showDatePickerWithTitle:@"请选时间" dateType:BRDatePickerModeYM defaultSelValue:showDate minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:MainColor resultBlock:^(NSString *selectValue) {
        self.currentTime = selectValue;
        //wself.itemViewBirthDay.textFieldInfo.text = selectValue;
        NSMutableString *string = [NSMutableString stringWithString:selectValue];
        [string replaceCharactersInRange:NSMakeRange(4, 1) withString:@"年"];
        [string appendString:@"月"];
        [self.buttonTime setTitle:string forState:UIControlStateNormal];
        
        NSDate *date = [Tools stringToDateHM:selectValue];
        [self initData:date];
        //[self.calendarView.calendarManager checkThisMonthRecordFromToday:date];
        //[self.calendarView reloadCollectView];
        
    } cancelBlock:^{
        
    }];
}

- (void)setupView{
    [self addSubview:self.buttonTime];
    NSString *time = [Tools dateTransformToTimeStringMonth];
    self.currentTime = [Tools dateTransformToTimeStringMonthLine];
    
    CGFloat width = [Tools widthForString:time fontSize:Ratio13 andHeight:Ratio22];
    self.buttonTime.sd_layout.leftSpaceToView(self, Ratio11).widthIs(width + Ratio44).heightIs(Ratio22).topSpaceToView(self, Ratio22);
    [self.buttonTime setTitle:time forState:UIControlStateNormal];
    
    [self addSubview:self.calendarView];

    
    [self addSubview:self.labelProgramCount];
    [self addSubview:self.labelProgramTime];
    self.labelProgramCount.sd_layout.leftSpaceToView(self, Ratio18).widthIs(screenW/2-Ratio18).topSpaceToView(self.calendarView, Ratio22).heightIs(Ratio22);
    self.labelProgramTime.sd_layout.rightSpaceToView(self, Ratio18).widthIs(screenW/2+Ratio18).topSpaceToView(self.calendarView, Ratio22).heightIs(Ratio22);
}



- (HHCalendarView *)calendarView{
    if (!_calendarView) {
        _calendarView = [[HHCalendarView alloc] init];
        _calendarView.delegate = self;
    }
    return _calendarView;
}

- (UIButton *)buttonTime{
    if (!_buttonTime) {
        _buttonTime = [[UIButton alloc] init];
        _buttonTime.cs_imagePositionMode = ImagePositionModeRight;
        _buttonTime.cs_middleDistance = Ratio1;
        //_selectButton.cs_imageSize = CGSizeMake(Ratio16, Ratio16);
        [_buttonTime setImage:[UIImage imageNamed:@"pull_down"] forState:UIControlStateNormal];
        //[_buttonTime setTitle:@"全部" forState:UIControlStateNormal];
        [_buttonTime setTitleColor:MainBlack forState:UIControlStateNormal];
        _buttonTime.titleLabel.font = Font15;
        [_buttonTime addTarget:self action:@selector(actionCilckSelectTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTime;
}

- (UILabel *)labelProgramTime{
    if (!_labelProgramTime) {
        _labelProgramTime = [[UILabel alloc] init];
        _labelProgramTime.font = Font13;
        _labelProgramTime.textColor = MainBlack;
        _labelProgramTime.textAlignment = NSTextAlignmentRight;
    }
    return _labelProgramTime;
}

- (UILabel *)labelProgramCount{
    if (!_labelProgramCount) {
        _labelProgramCount = [[UILabel alloc] init];
        _labelProgramCount.font = Font13;
        _labelProgramCount.textColor = MainColor;
        _labelProgramCount.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionToProgramListVC:)];
        [_labelProgramCount addGestureRecognizer:tapGesture];
        
    }
    return _labelProgramCount;
}

@end
