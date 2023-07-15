//
//  AnnotationFullVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/4.
//

#import "AnnotationFullVC.h"
#import "HHBluetoothButton.h"
#import "WaveFullView.h"
#import "AnnotationInfoVC.h"
#import "AnnotationItemCell.h"
#import "AppDelegate.h"
#import "UIDevice+HanHong.h"

#define lineCount           9

@interface AnnotationFullVC ()<UITableViewDelegate, UITableViewDataSource, AnnotationItemCellDelegate, UIScrollViewDelegate>

@property (retain, nonatomic) UIView            *viewNavi;
@property (retain, nonatomic) UIButton          *buttonBack;
@property (retain, nonatomic) HHBluetoothButton *bluetoothButton;
@property (retain, nonatomic) UIView            *viewSelectAnnotation;
@property (retain, nonatomic) UIImageView       *imageViewDown;
@property (retain, nonatomic) UILabel           *labelAnnotation;

@property (retain, nonatomic) UILabel           *labelTop;
@property (retain, nonatomic) UILabel           *labelCenter;
@property (retain, nonatomic) UILabel           *labelBottom;

@property (retain, nonatomic) UIScrollView      *scrollView;
@property (retain, nonatomic) WaveFullView      *waveFullView;

@property (assign, nonatomic) CGFloat               rowWidth;
@property (assign, nonatomic) CGFloat               viewWidth;
@property (assign, nonatomic) CGFloat               viewHeight;

@property (retain, nonatomic) UIView                *viewLine;
@property (retain, nonatomic) UIButton              *buttonAdd;
@property (retain, nonatomic) UIButton              *buttonReduce;
@property (retain, nonatomic) UIButton              *buttonPlay;
@property (retain, nonatomic) UIButton              *buttonAnnotation;
@property (retain, nonatomic) UIView                *viewAnnotationArea;//显示标注区域
@property (retain, nonatomic) UIView                *viewTouchBg;//由于事件处理

@property (retain, nonatomic) UIView                *clipView;
@property (assign, nonatomic) CGPoint               startP;


@property (retain, nonatomic) NSDecimalNumber       *startTimeDecimalNumber;
@property (retain, nonatomic) NSDecimalNumber       *endTimeDecimalNumber;
@property (retain, nonatomic) UITableView           *tableView;
//@property (retain, nonatomic) UIView                *viewTableViewBg;
@property (retain, nonatomic) NSString              *allTime;

@property (retain, nonatomic) UILabel               *labelTableTitle;

@property (assign, nonatomic) CGFloat               startTime;
@property (assign, nonatomic) CGFloat               endTime;
@property (assign, nonatomic) CGFloat               statusBarHeight;

@property (retain, nonatomic) UIView                *viewLeftView;
@property (assign, nonatomic) NSInteger             secondCellCount;


@end

@implementation AnnotationFullVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.secondCellCount = 5;
    self.view.backgroundColor = MainBlack;
    self.statusBarHeight = kStatusBarHeight;
    NSLog(@"self.statusBarHeight = %@", self.recordModel.url);
    self.startTime = 0;
    self.endTime = 0;
    self.allTime = [NSString stringWithFormat:@"0:000-%li:000 全部", self.recordModel.record_length];
    self.viewHeight = screenW - 2 *  kNavBarHeight - Ratio22;
    
    [self initView];
    [self reloadAnnotationAreaView];
}

- (void)actionShowTableView:(UITapGestureRecognizer *)tap{
    self.tableView.hidden = NO;
    NSInteger count = self.arrayCharacteristic.count > 5 ? 5 : self.arrayCharacteristic.count;
    self.tableView.frame = CGRectMake(2*screenW/3.f-self.statusBarHeight - Ratio11, kNavBarHeight + Ratio3, screenW / 3.0f, Ratio30 * (count + 1));
    [self.tableView reloadData];
}

- (void)actionDeviceHelperPlayBegin{
    self.viewLine.frame = CGRectMake(self.statusBarHeight, kNavBarHeight, Ratio1, self.viewHeight);
    self.viewLine.hidden = NO;
}

- (void)actionDeviceHelperPlayingTime:(float)value{
    NSLog(@"self.statusBarHeight = %f", self.statusBarHeight);
    CGFloat width = value / self.recordModel.record_length * self.viewWidth;
    Boolean bFirstLoadA = YES;
    Boolean bBirstLoadB = YES;
    CGFloat x = self.statusBarHeight;
    
    if (width <= screenW/2 - x) {
        self.viewLine.frame = CGRectMake(x + width, kNavBarHeight, Ratio1, self.viewHeight);
    } else if (width >= self.viewWidth - screenW/2 + x) {
        if (bFirstLoadA) {
            CGPoint offset = CGPointMake(self.viewWidth-screenW+x, 0);
            [self.scrollView setContentOffset:offset animated:YES];
            bFirstLoadA = NO;
        }
        self.viewLine.frame = CGRectMake(screenW - x-(self.viewWidth - width), kNavBarHeight, Ratio1, self.viewHeight);
    } else {
        if (bBirstLoadB) {
            self.viewLine.frame = CGRectMake(screenW/2, kNavBarHeight, Ratio1, self.viewHeight);
            bBirstLoadB = NO;
        }
        CGPoint offset = CGPointMake(width - screenW/2 + x, 0);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    
}

- (void)actionClickDeleteCallback:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.arrayCharacteristic removeObjectAtIndex:indexPath.row];
    //[self.tableView reloadData];
    [self reloadAnnotationAreaView];
    self.tableView.hidden = YES;
}

- (void)reloadAnnotationAreaView{
    for (UIView *view in [self.viewAnnotationArea subviews]) {
        [view removeFromSuperview];
    }
    for (NSInteger i = 0; i < self.arrayCharacteristic.count; i++) {
        NSDictionary *info = self.arrayCharacteristic[i];
        [self addCharacteristicView:info tag:i+1 bAdd:NO];
    }
}

- (void)actionDeviceHelperPlayEnd{
    self.buttonPlay.selected = NO;
    //[self.viewSmallWave actionStop];
    self.viewLine.frame = CGRectMake(self.statusBarHeight, kNavBarHeight, Ratio1, self.viewHeight);
    self.viewLine.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    });
    
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.hidden = YES;
        _tableView.backgroundColor = MainBlack;
        _tableView.layer.cornerRadius = Ratio2;
        [_tableView registerClass:[AnnotationItemCell class] forCellReuseIdentifier:NSStringFromClass([AnnotationItemCell class])];
    }
    return _tableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSDictionary *info = self.arrayCharacteristic[row];
    NSArray *timeArray = [info[@"time"] componentsSeparatedByString:@"-"];
    self.startTime = [timeArray[0] floatValue];
    self.endTime = [timeArray[1] floatValue];
    CGFloat centerTime = self.startTime + (self.endTime - self.startTime) / 2;
    CGFloat startX = centerTime / self.recordModel.record_length * self.viewWidth;
    if (startX <= (screenW - 2*self.statusBarHeight)/2) {
        startX = 0;
    } else {
        startX = startX - (screenW - 2*self.statusBarHeight)/2;
    }
    CGPoint point = CGPointMake(startX, 0);
    [self.scrollView setContentOffset:point animated:YES];
    NSString *stringAnnotation = [NSString stringWithFormat:@"%@ %@", info[@"time"], info[@"characteristic"]];
    self.labelAnnotation.text = [stringAnnotation stringByReplacingOccurrencesOfString:@"." withString:@":"];
    
    [self reloadAnnotationAreaView];
    UIView *view = [self.viewAnnotationArea viewWithTag:row+1];
    view.backgroundColor = HEXCOLOR(0x7AE300, 0.5);
    self.tableView.hidden = YES;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Ratio30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW/3, Ratio30)];
    view.backgroundColor = MainBlack;
    [view addSubview:self.labelTableTitle];
    self.labelTableTitle.sd_layout.leftSpaceToView(view, Ratio11).centerYEqualToView(view).heightIs(Ratio17).rightSpaceToView(view, Ratio11);
    UITapGestureRecognizer *tapHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapHeader:)];
    [view addGestureRecognizer:tapHeader];
    return view;
}

- (void)actionTapHeader:(UITapGestureRecognizer *)tap{
    self.labelAnnotation.text = self.allTime;
    self.startTime = 0;
    self.endTime = 0;
    [self reloadAnnotationAreaView];
}

- (UILabel *)labelTableTitle{
    if (!_labelTableTitle) {
        _labelTableTitle = [[UILabel alloc] init];
        _labelTableTitle.textColor = WHITECOLOR;
        _labelTableTitle.text = self.allTime;
        _labelTableTitle.font = Font15;
    }
    return _labelTableTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayCharacteristic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AnnotationItemCell *cell = (AnnotationItemCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AnnotationItemCell class])];
    NSInteger row = indexPath.row;

    cell.info = self.arrayCharacteristic[row];
    cell.row = row;
    cell.delegate = self;
    return cell;
}

- (UIButton *)buttonReduce{
    if (!_buttonReduce) {
        _buttonReduce = [[UIButton alloc] init];
        [_buttonReduce setTitle:@"缩小" forState:UIControlStateNormal];
        _buttonReduce.titleLabel.textColor = WHITECOLOR;
        _buttonReduce.titleLabel.font = Font13;
        _buttonReduce.backgroundColor = HEXCOLOR(0x232323, 0.5);
        _buttonReduce.layer.cornerRadius = Ratio4;
        _buttonReduce.clipsToBounds = YES;
        [_buttonReduce addTarget:self action:@selector(actionToReduce:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonReduce;
}

- (UIButton *)buttonAdd{
    if (!_buttonAdd) {
        _buttonAdd = [[UIButton alloc] init];
        [_buttonAdd setTitle:@"放大" forState:UIControlStateNormal];
        _buttonAdd.titleLabel.textColor = WHITECOLOR;
        _buttonAdd.titleLabel.font = Font13;
        _buttonAdd.backgroundColor = HEXCOLOR(0x232323, 0.5);
        [_buttonAdd addTarget:self action:@selector(actionToAdd:) forControlEvents:UIControlEventTouchUpInside];
        _buttonAdd.layer.cornerRadius = Ratio4;
        _buttonAdd.clipsToBounds = YES;
        //_buttonAdd.hidden = YES;
    }
    return _buttonAdd;
}

- (void)actionToReduce:(UIButton *)button{
    if(self.secondCellCount == 1) {
        return;
    }
    if(self.secondCellCount<=5){
        self.secondCellCount --;
    } else {
        self.secondCellCount /= 2;
    }
    self.secondCellCount --;
    if(self.waveFullView) {
        [self.waveFullView removeFromSuperview];
        self.waveFullView = nil;
    }
    [self initWaveRowData];
    [self initWaveView];
    [self reloadAnnotationAreaView];
}

- (void)actionToAdd:(UIButton *)button{
    if(self.secondCellCount<5){
        self.secondCellCount ++;
    } else {
        self.secondCellCount *= 2;
    }
   
    if(self.waveFullView) {
        [self.waveFullView removeFromSuperview];
        self.waveFullView = nil;
    }
    [self initWaveRowData];
    [self initWaveView];
    [self reloadAnnotationAreaView];
}

- (UIButton *)buttonPlay{
    if (!_buttonPlay) {
        _buttonPlay = [[UIButton alloc] init];
        [_buttonPlay setTitle:@" 播放" forState:UIControlStateNormal];
        [_buttonPlay setTitle:@" 停止" forState:UIControlStateSelected];
        [_buttonPlay setImage:[UIImage imageNamed:@"full_screen_play"] forState:UIControlStateNormal];
        _buttonPlay.cs_imagePositionMode = ImagePositionModeDefault;
        _buttonPlay.cs_imageSize = CGSizeMake(Ratio15, Ratio15);
        _buttonPlay.cs_middleDistance = Ratio5;
        _buttonPlay.titleLabel.textColor = WHITECOLOR;
        _buttonPlay.titleLabel.font = Font13;
        _buttonPlay.layer.cornerRadius = Ratio4;
        _buttonPlay.backgroundColor = HEXCOLOR(0x232323, 0.5);
        [_buttonPlay addTarget:self action:@selector(actionClickPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonPlay;
}

- (void)actionClickPlay:(UIButton *)button{
    if(![[HHBlueToothManager shareManager] getConnectState]) {
        [self.view makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    if (!self.bPlaying) {
        button.selected = YES;
        [self actionToStar:self.startTime endTime:self.endTime];
        
    } else {
        button.selected = NO;
        [self stopPlayRecord];
    }
}

- (UIButton *)buttonAnnotation{
    if (!_buttonAnnotation) {
        _buttonAnnotation = [[UIButton alloc] init];
        [_buttonAnnotation setTitle:@" 标注" forState:UIControlStateNormal];
        _buttonAnnotation.titleLabel.textColor = WHITECOLOR;
        _buttonAnnotation.titleLabel.font = Font13;
        _buttonAnnotation.layer.cornerRadius = Ratio4;
        _buttonAnnotation.backgroundColor = HEXCOLOR(0x232323, 1);
        [_buttonAnnotation setImage:[UIImage imageNamed:@"annotation"] forState:UIControlStateNormal];
        [_buttonAnnotation addTarget:self action:@selector(actionToSelctAnnotaion:) forControlEvents:UIControlEventTouchUpInside];
        _buttonAnnotation.cs_imagePositionMode = ImagePositionModeDefault;
        _buttonAnnotation.cs_imageSize = CGSizeMake(Ratio15, Ratio15);
        _buttonAnnotation.cs_middleDistance = Ratio3;
        _buttonAnnotation.hidden = YES;
    }
    return _buttonAnnotation;
}


- (UILabel *)labelTop{
    if (!_labelTop) {
        _labelTop = [self getLabelVertical:@" 1"];
    }
    return _labelTop;
}

- (UIView *)viewLine{
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = WHITECOLOR;
        _viewLine.hidden = YES;
    }
    return _viewLine;
}

- (UILabel *)labelCenter{
    if (!_labelCenter) {
        _labelCenter = [self getLabelVertical:@" 0"];
    }
    return _labelCenter;
}

- (UILabel *)labelBottom{
    if (!_labelBottom) {
        _labelBottom = [self getLabelVertical:@" -1"];
    }
    return _labelBottom;
}

- (UILabel *)getLabelVertical:(NSString *)name{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = Font15;
    label.textColor = WHITECOLOR;
    label.text = name;
    return label;
}


- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.tableView.hidden = YES;
}

- (UIView *)viewNavi{
    if (!_viewNavi) {
        _viewNavi = [[UIView alloc] init];
        _viewNavi.backgroundColor = HEXCOLOR(0x232323, 0.2);
    }
    return _viewNavi;
}

- (UIButton *)buttonBack{
    if (!_buttonBack) {
        _buttonBack = [[UIButton alloc] init];
        [_buttonBack setImage:[UIImage imageNamed:@"back_grey"] forState:UIControlStateNormal];
        _buttonBack.imageEdgeInsets = UIEdgeInsetsMake(Ratio3, Ratio10, Ratio3, Ratio10);
        [_buttonBack addTarget:self action:@selector(actionViewBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonBack;
}

- (HHBluetoothButton *)bluetoothButton{
    if (!_bluetoothButton) {
        _bluetoothButton = [[HHBluetoothButton alloc] init];
    }
    return _bluetoothButton;
}

- (UIImageView *)imageViewDown{
    if (!_imageViewDown) {
        _imageViewDown = [[UIImageView alloc] init];
        _imageViewDown.image = [UIImage imageNamed:@"pull_down_white"];
    }
    return _imageViewDown;
}

- (UILabel *)labelAnnotation{
    if (!_labelAnnotation) {
        _labelAnnotation = [[UILabel alloc] init];
        _labelAnnotation.text = self.allTime;
        _labelAnnotation.textColor = WHITECOLOR;
        _labelAnnotation.font = Font15;
    }
    return _labelAnnotation;
}

- (void)actionViewBack:(UIButton *)button{
    [Tools showAlertView:nil andMessage:@"是否退出" andTitles:@[@"取消",@"确定"] andColors:@[MainGray, MainColor] sure:^{
        if (self.resultBlock) {
            self.resultBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    } cancel:^{
        
    }];
}

- (UIView *)viewSelectAnnotation{
    if (!_viewSelectAnnotation) {
        _viewSelectAnnotation = [[UIView alloc] init];
        _viewSelectAnnotation.backgroundColor = HEXCOLOR(0x232323, 1);
        _viewSelectAnnotation.layer.cornerRadius = Ratio5;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShowTableView:)];
        [_viewSelectAnnotation addGestureRecognizer:tapGesture];
        _viewSelectAnnotation.userInteractionEnabled = YES;
    }
    return _viewSelectAnnotation;
}

- (WaveFullView *)waveFullView{
    if (!_waveFullView) {
        _waveFullView = [[WaveFullView alloc] initWithFrame:CGRectZero recordModel:self.recordModel cellCount:self.secondCellCount viewHeight:self.viewHeight];
    }
    return _waveFullView;
}

- (UIView *)viewAnnotationArea{
    if (!_viewAnnotationArea) {
        _viewAnnotationArea = [[UIView alloc] init];
    }
    return _viewAnnotationArea;
}

- (UIView *)viewTouchBg{
    if (!_viewTouchBg) {
        _viewTouchBg = [[UIView alloc] init];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPanGesture:)];
        [_viewTouchBg addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGestuer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
        [_viewTouchBg addGestureRecognizer:tapGestuer];
    }
    return _viewTouchBg;
}

- (void)actionTapGesture:(UITapGestureRecognizer *)gesture{
    self.clipView.hidden = YES;
    self.buttonAnnotation.hidden = YES;
    self.labelAnnotation.text = self.allTime;
    self.tableView.hidden = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.tableView.hidden = YES;
}

- (void)actionPanGesture:(UIPanGestureRecognizer *)gesture{
    self.tableView.hidden = YES;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.clipView removeFromSuperview];
        self.startP = [gesture locationInView:self.scrollView];
        self.labelAnnotation.text = @"新选区";
        self.startTime = 0;
        self.endTime = 0;
        NSLog(@"startTime x = %f , %f", self.startP.x, self.startP.x/self.viewWidth*self.recordModel.record_length);
        UIView *clipView = [[UIView alloc] init];
        clipView.backgroundColor = HEXCOLOR(0x7AE300, 0.5);//FFFF33
        clipView.alpha = 0.5;
        [self.viewAnnotationArea addSubview:clipView];
        self.clipView = clipView;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint curP = [gesture locationInView:self.scrollView];
        self.clipView.frame = CGRectMake(self.startP.x, 0, curP.x - self.startP.x, self.viewHeight);
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.buttonAnnotation.hidden = NO;
        CGPoint endP = [gesture locationInView:self.scrollView];
        CGFloat startX = MIN(self.startP.x, endP.x);
        CGFloat endX = MAX(self.startP.x, endP.x);
        self.startTimeDecimalNumber = [self changeNumber3Point:startX / self.viewWidth * self.recordModel.record_length];
        self.endTimeDecimalNumber = [self changeNumber3Point:endX / self.viewWidth * self.recordModel.record_length];
        self.startTime= [self.startTimeDecimalNumber floatValue];
        self.endTime = [self.endTimeDecimalNumber floatValue];
    }
}
//标注时间
- (void)actionToSelctAnnotaion:(UIButton *)button{
    AnnotationInfoVC *annotationInfoVC = [[AnnotationInfoVC alloc] init];
    annotationInfoVC.soundType = self.recordModel.type_id;
    annotationInfoVC.resultBlock = ^(NSString * _Nonnull selectValue) {
        NSString *start = [NSString stringWithFormat:@"%@", self.startTimeDecimalNumber];
        NSString *end = [NSString stringWithFormat:@"%@",self.endTimeDecimalNumber];
        NSRange startRange = [start rangeOfString:@"."];
        NSString *startMinute = [start substringToIndex:startRange.location];
        start = [startMinute integerValue] < 10 ? [NSString stringWithFormat:@"0%@", start] : start;
        NSRange endRange = [end rangeOfString:@"."];
        NSString *endMinute = [end substringToIndex:endRange.location];
        end = [endMinute integerValue] < 10 ? [NSString stringWithFormat:@"0%@", end] : end;
        
        NSString *timeStr = [NSString stringWithFormat:@"%@-%@", start, end];
        NSString *showString = [NSString stringWithFormat:@"%@ %@", [timeStr stringByReplacingOccurrencesOfString:@"." withString:@":"], selectValue];
        self.labelAnnotation.text = showString;
        
        self.buttonAnnotation.hidden = YES;
        [self.clipView removeFromSuperview];
        
        NSDictionary *data = @{@"time": timeStr, @"characteristic": selectValue};
        [self.arrayCharacteristic addObject:data];
        [self addCharacteristicView:data tag:self.arrayCharacteristic.count bAdd:YES];
        
    };
    [self.navigationController pushViewController:annotationInfoVC animated:NO];
}


- (void)addCharacteristicView:(NSDictionary *)dic tag:(NSInteger)tag bAdd:(Boolean)bAdd{
    NSString *timeStr = dic[@"time"];
    timeStr = [timeStr stringByReplacingOccurrencesOfString:@":" withString:@"."];
    NSArray *timeArray = [timeStr componentsSeparatedByString:@"-"];
    CGFloat startTime = [timeArray[0] floatValue];
    CGFloat endTime = [timeArray[1] floatValue];
    CGFloat startX = startTime / self.recordModel.record_length * self.viewWidth;
    CGFloat endX = endTime / self.recordModel.record_length * self.viewWidth;
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(startX, 0, endX-startX, self.viewHeight);
    view.tag = tag;
    if(bAdd) {
        view.backgroundColor = HEXCOLOR(0x7AE300, 0.5);
    } else {
        view.backgroundColor = HEXCOLOR(0xFFFF33, 0.4);
    }
    
    [self.viewAnnotationArea addSubview:view];
}

- (NSDecimalNumber *)changeNumber3Point:(CGFloat)value{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", value]];
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    return [number decimalNumberByRoundingAccordingToBehavior:roundUp];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //self.bCurrentView = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //进入旋转
    //[self changeRotate:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // 打开横屏开关
    appDelegate.allowRotation = YES;
    // 调用转屏代码
    [UIDevice deviceMandatoryLandscapeWithNewOrientation:UIInterfaceOrientationLandscapeRight];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initWaveRowData{
    self.viewWidth = self.recordModel.record_length * self.secondCellCount * self.rowWidth;
}

- (void)initWaveView{
    [self.scrollView addSubview:self.waveFullView];//背景网格
    self.waveFullView.sd_layout.leftSpaceToView(self.scrollView, 0).widthIs(self.viewWidth).topSpaceToView(self.scrollView, 0).bottomSpaceToView(self.scrollView, 0);
    [self.scrollView addSubview:self.audioPlotView];//音频图
   
    self.audioPlotView.sd_layout.leftSpaceToView(self.scrollView, 0).widthIs(self.viewWidth).topSpaceToView(self.scrollView, 0).bottomSpaceToView(self.scrollView, 0);
    self.scrollView.contentSize = CGSizeMake(self.viewWidth, self.viewHeight);
    [self.scrollView addSubview:self.viewAnnotationArea];
    self.viewAnnotationArea.sd_layout.leftSpaceToView(self.scrollView, 0).widthIs(self.viewWidth).topSpaceToView(self.scrollView, 0).bottomSpaceToView(self.scrollView, 0);
   [self.scrollView addSubview:self.viewTouchBg];
    self.viewTouchBg.frame = CGRectMake(0, self.viewHeight/3, self.viewWidth, self.viewHeight/3);
}

- (void)initView{
    
    self.rowWidth = self.viewHeight / (lineCount - 1);
    [self initWaveRowData];
    
    [self.view addSubview:self.viewNavi];
    self.viewNavi.sd_layout.leftSpaceToView(self.view, 0).topSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).heightIs(kNavBarHeight);
    [self.viewNavi addSubview:self.buttonBack];
    self.buttonBack.sd_layout.leftSpaceToView(self.viewNavi, self.statusBarHeight + Ratio11).heightIs(Ratio22).widthIs(Ratio30).centerYEqualToView(self.viewNavi);
    [self.viewNavi addSubview:self.bluetoothButton];
    self.bluetoothButton.sd_layout.leftSpaceToView(self.buttonBack, Ratio33).heightIs(Ratio22).widthIs(Ratio22).centerYEqualToView(self.viewNavi);
    
    [self.viewNavi addSubview:self.buttonReduce];
    [self.viewNavi addSubview:self.buttonAdd];
    self.buttonReduce.sd_layout.centerYEqualToView(self.viewNavi).leftSpaceToView(self.bluetoothButton, Ratio33).widthIs(Ratio66).heightIs(Ratio30);
    self.buttonAdd.sd_layout.centerYEqualToView(self.buttonReduce).leftSpaceToView(self.buttonReduce, Ratio11).widthIs(Ratio66).heightIs(Ratio30);
    
    [self.viewNavi addSubview:self.viewSelectAnnotation];
    self.viewSelectAnnotation.sd_layout.centerYEqualToView(self.viewNavi).rightSpaceToView(self.viewNavi, kBottomSafeHeight + Ratio22).heightIs(Ratio28).widthIs(screenH/3);
    [self.viewSelectAnnotation addSubview:self.imageViewDown];
    self.imageViewDown.sd_layout.rightSpaceToView(self.viewSelectAnnotation, Ratio6).heightIs(Ratio8).widthIs(Ratio12).centerYEqualToView(self.viewSelectAnnotation);
    [self.viewSelectAnnotation addSubview:self.labelAnnotation];
    self.labelAnnotation.sd_layout.leftSpaceToView(self.viewSelectAnnotation, Ratio6).heightIs(Ratio17).rightSpaceToView(self.viewSelectAnnotation, Ratio8).centerYEqualToView(self.viewSelectAnnotation);
    
    
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, self.statusBarHeight).rightSpaceToView(self.view, self.statusBarHeight).topSpaceToView(self.viewNavi, 0).heightIs(self.viewHeight);
    [self initWaveView];
    
    [self.view addSubview:self.viewLeftView];
    self.viewLeftView.sd_layout.widthIs(Ratio1).heightIs(self.viewHeight).leftEqualToView(self.scrollView).topEqualToView(self.scrollView);
    //self.viewLeftView.backgroundColor = UIColor.redColor;
    
    [self.view addSubview:self.labelTop];
    [self.view addSubview:self.labelCenter];
    [self.view addSubview:self.labelBottom];
    [self.view addSubview:self.buttonPlay];
    
    [self.view addSubview:self.buttonAnnotation];
    [self.view addSubview:self.viewLine];
    self.labelTop.sd_layout.topSpaceToView(self.viewNavi, Ratio5).leftSpaceToView(self.view, self.statusBarHeight + Ratio2).widthIs(Ratio33).heightIs(Ratio16);
    self.labelCenter.sd_layout.centerYIs(kNavBarHeight + 4*self.rowWidth).leftEqualToView(self.labelTop).widthIs(Ratio33).heightIs(Ratio16);
    self.labelBottom.sd_layout.leftEqualToView(self.labelTop).topSpaceToView(self.scrollView, -Ratio22).widthIs(Ratio33).heightIs(Ratio16);
    
    self.buttonPlay.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.scrollView, Ratio11).widthIs(Ratio66).heightIs(Ratio28);
    self.buttonAnnotation.sd_layout.centerYEqualToView(self.buttonPlay).rightSpaceToView(self.view, Ratio22).heightIs(Ratio28).widthIs(Ratio66);
    
    self.viewLine.frame = CGRectMake(self.statusBarHeight, kNavBarHeight, Ratio1, self.viewHeight);
    
    [self.view addSubview:self.tableView];
    
    [self openFileWithFilePathURL];
    
}

- (UIView *)viewLeftView{
    if (!_viewLeftView) {
        _viewLeftView = [[UIView alloc] init];
        _viewLeftView.backgroundColor = WHITECOLOR;
    }
    return _viewLeftView;
}


@end
