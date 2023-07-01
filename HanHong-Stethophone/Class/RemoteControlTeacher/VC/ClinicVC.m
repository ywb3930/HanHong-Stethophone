//
//  ClinicVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import "ClinicVC.h"
#import "HeartFilterLungView.h"
#import "TeachingHistoryModel.h"

@interface ClinicVC ()

@property (retain, nonatomic) UIScrollView          *scrollView;
@property (retain, nonatomic) UILabel               *labelRoomCode;
@property (retain, nonatomic) UIImageView           *imageViewRoomCode;
@property (retain, nonatomic) UIButton              *buttonStartTeach;
@property (retain, nonatomic) UIButton              *buttonStopTeach;
@property (retain, nonatomic) UILabel               *labelMessage;
@property (retain, nonatomic) UIView                *viewLine1;
@property (retain, nonatomic) UIView                *viewLine2;
@property (retain, nonatomic) UILabel               *labelMessage2;
@property (retain, nonatomic) HeartFilterLungView   *heartFilterLungView;

@property (retain, nonatomic) UIButton              *buttonSaveRecord;
@property (retain, nonatomic) UILabel               *labelSaveRecord;

@property (retain, nonatomic) UILabel               *labelAddStudent;

@property (retain, nonatomic) TeachingHistoryModel  *historyModel;

@end

@implementation ClinicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"临床教学";
    self.view.backgroundColor = WHITECOLOR;
    [self setupView];
    [self getTeachingClassroom];
}

- (void)getTeachingClassroom{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"create_new"] = [@(false) stringValue];
    __weak typeof(self) wself = self;
    [TTRequestManager teachingGetClassroom:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            wself.historyModel = [TeachingHistoryModel yy_modelWithJSON:responseObject[@"data"]];
            [wself getTeachingStudents];
            [wself reloadClassroom];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)reloadClassroom{
    if(self.historyModel.class_state == 0) {//未开始
        self.buttonStartTeach.backgroundColor = AlreadyColor;
        self.buttonStopTeach.backgroundColor = HEXCOLOR(0xBCBCBC, 1);
        self.buttonStopTeach.layer.borderWidth = Ratio1;
        self.buttonStopTeach.layer.borderColor = HEXCOLOR(0xF5F5F5, 1).CGColor;
    } else if(self.historyModel.class_state == 1) {//已开始
        self.buttonStartTeach.backgroundColor = HEXCOLOR(0xBCBCBC, 1);
        self.buttonStartTeach.layer.borderWidth = Ratio1;
        self.buttonStartTeach.layer.borderColor = HEXCOLOR(0xF5F5F5, 1).CGColor;
        self.buttonStopTeach.backgroundColor = AlreadyColor;
    } else if(self.historyModel.class_state == 2) {//已结束
        self.buttonStartTeach.backgroundColor = HEXCOLOR(0xBCBCBC, 1);
        self.buttonStartTeach.layer.borderWidth = Ratio1;
        self.buttonStartTeach.layer.borderColor = HEXCOLOR(0xF5F5F5, 1).CGColor;
        self.buttonStopTeach.backgroundColor = HEXCOLOR(0xBCBCBC, 1);
        self.buttonStopTeach.layer.borderWidth = Ratio1;
        self.buttonStopTeach.layer.borderColor = HEXCOLOR(0xF5F5F5, 1).CGColor;
    }
}

- (void)getTeachingStudents{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"classroom_id"] = [@(self.historyModel.classroom_id) stringValue];
    [TTRequestManager teachingGetStudents:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSArray *data = responseObject[@"data"];
            [self loadUserView:data];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)loadUserView:(NSArray *)data{
    CGFloat width = (screenW - Ratio66)/5;
    for (NSInteger i = 0; i < data.count; i++) {
        NSDictionary *dic = data[i];
        NSInteger jj = ceil(i / 5);
        NSInteger ii = i % 5;
        UIView *viewMember = [[UIView alloc] init];
        [self.scrollView addSubview:viewMember];
        viewMember.sd_layout.leftSpaceToView(self.scrollView, Ratio11 + (width + Ratio11) * ii).widthIs(width).heightIs(width + Ratio28).topSpaceToView(self.labelAddStudent, Ratio22 + (width + Ratio33) * jj);
        
        //FriendModel *model = [self.arrayData objectAtIndex:i];
        UIImageView *imageViewHead = [[UIImageView alloc] init];
        [imageViewHead sd_setImageWithURL:[NSURL URLWithString:dic[@"avatar"]] placeholderImage:nil options:SDWebImageProgressiveLoad];
        imageViewHead.layer.cornerRadius = Ratio4;
        imageViewHead.contentMode = UIViewContentModeScaleAspectFit;
        [viewMember addSubview:imageViewHead];
        imageViewHead.sd_layout.centerXEqualToView(viewMember).widthIs(width - Ratio10).heightIs(width - Ratio10).topSpaceToView(viewMember, 0);


        UILabel *labelName = [[UILabel alloc] init];
        labelName.text = dic[@"name"];
        labelName.font = Font13;
        labelName.textAlignment = NSTextAlignmentCenter;
        [viewMember addSubview:labelName];
        labelName.sd_layout.centerXEqualToView(imageViewHead).widthIs(width).heightIs(Ratio15).topSpaceToView(imageViewHead, Ratio3);
        
        if (i == data.count - 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CGFloat maxY = CGRectGetMaxY(viewMember.frame);
                if (maxY > screenH - kNavBarAndStatusBarHeight- 38.f*screenRatio) {
                    self.scrollView.contentSize = CGSizeMake(screenW, maxY + Ratio33);
                }
            });
        }
    }
}

- (void)actionTapLavelSaveRecord:(UITapGestureRecognizer *)tap{
    
}

- (void)actionCilckSaveRecord:(UIButton *)button{
    
}

- (void)setupView{
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, 0);
    
    [self.scrollView addSubview:self.labelRoomCode];
    self.labelRoomCode.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).topSpaceToView(self.scrollView, Ratio22).heightIs(Ratio20);
    
    [self.scrollView addSubview:self.imageViewRoomCode];
    self.imageViewRoomCode.sd_layout.centerXEqualToView(self.scrollView).widthIs(screenW/3).heightIs(screenW/3).topSpaceToView(self.labelRoomCode, Ratio22);
    self.imageViewRoomCode.image = [Tools generateQRCodeWithString:@"ji8dkd" Size:screenW/3];
    
    [self.scrollView addSubview:self.buttonStopTeach];
    [self.scrollView addSubview:self.buttonStartTeach];
    self.buttonStartTeach.sd_layout.centerYEqualToView(self.imageViewRoomCode).widthIs(screenW/3 - Ratio44).leftSpaceToView(self.scrollView, Ratio22).heightIs(screenW/3 - Ratio44);
    self.buttonStopTeach.sd_layout.centerYEqualToView(self.imageViewRoomCode).widthIs(screenW/3 - Ratio44).rightSpaceToView(self.scrollView, Ratio22).heightIs(screenW/3 - Ratio44);
    
    [self.scrollView addSubview:self.labelMessage];
    [self.scrollView addSubview:self.viewLine1];
    self.labelMessage.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).heightIs(Ratio20).topSpaceToView(self.imageViewRoomCode, Ratio22);
    self.viewLine1.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).heightIs(Ratio11).topSpaceToView(self.labelMessage, Ratio22);
    
    [self.scrollView addSubview:self.labelMessage2];
    [self.scrollView addSubview:self.heartFilterLungView];
    self.labelMessage2.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).heightIs(Ratio20).topSpaceToView(self.viewLine1, Ratio11);
    self.heartFilterLungView.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).topSpaceToView(self.labelMessage2, Ratio11).heightIs(Ratio33);
    
    CGFloat sWidth = [Tools widthForString:@"我想同步保存录音文件" fontSize:Ratio10 andHeight:Ratio20];
    [self.scrollView addSubview:self.labelSaveRecord];
    self.labelSaveRecord.sd_layout.centerXIs(screenW/2+Ratio10).heightIs(Ratio20).widthIs(sWidth+Ratio1).topSpaceToView(self.heartFilterLungView, Ratio3);
    [self.scrollView addSubview:self.buttonSaveRecord];
    self.buttonSaveRecord.sd_layout.rightSpaceToView(self.labelSaveRecord, 0).widthIs(Ratio20).heightIs(Ratio20).centerYEqualToView(self.labelSaveRecord);
    
    [self.scrollView addSubview:self.viewLine2];
    self.viewLine2.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).topSpaceToView(self.labelSaveRecord, Ratio11).heightIs(Ratio11);
    
    [self.scrollView addSubview:self.labelAddStudent];
    self.labelAddStudent.sd_layout.leftSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.viewLine2, Ratio11).heightIs(Ratio16).rightSpaceToView(self.scrollView, Ratio11);
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UILabel *)labelRoomCode{
    if (!_labelRoomCode) {
        _labelRoomCode = [[UILabel alloc] init];
        _labelRoomCode.text = @"教室码";
        _labelRoomCode.textAlignment = NSTextAlignmentCenter;
        _labelRoomCode.textColor = MainColor;
        _labelRoomCode.font = Font18;
    }
    return _labelRoomCode;
}

- (UIButton *)buttonStartTeach{
    if (!_buttonStartTeach) {
        _buttonStartTeach = [[UIButton alloc] init];
        [_buttonStartTeach setTitle:@"开始\r\n教学" forState:UIControlStateNormal];
        [_buttonStartTeach setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonStartTeach.layer.cornerRadius = Ratio5;
        _buttonStartTeach.titleLabel.font = Font15;
        _buttonStartTeach.titleLabel.numberOfLines = 0;
        _buttonStartTeach.backgroundColor = HEXCOLOR(0xBBBBBB, 1);
    }
    return _buttonStartTeach;
}

- (UIButton *)buttonStopTeach{
    if (!_buttonStopTeach) {
        _buttonStopTeach = [[UIButton alloc] init];
        [_buttonStopTeach setTitle:@"结束\r\n教学" forState:UIControlStateNormal];
        [_buttonStopTeach setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonStopTeach.layer.cornerRadius = Ratio5;
        _buttonStopTeach.titleLabel.font = Font15;
        _buttonStopTeach.titleLabel.numberOfLines = 0;
        _buttonStopTeach.backgroundColor = MainColor;
    }
    return _buttonStopTeach;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIImageView *)imageViewRoomCode{
    if (!_imageViewRoomCode) {
        _imageViewRoomCode = [[UIImageView alloc] init];
    }
    return _imageViewRoomCode;
}

- (UILabel *)labelMessage{
    if (!_labelMessage) {
        _labelMessage = [[UILabel alloc] init];
        _labelMessage.text = @"临床教学进行中";
        _labelMessage.textColor = MainColor;
        _labelMessage.textAlignment = NSTextAlignmentCenter;
        _labelMessage.font = Font18;
    }
    return _labelMessage;
}

- (UILabel *)labelMessage2{
    if (!_labelMessage2) {
        _labelMessage2 = [[UILabel alloc] init];
        _labelMessage2.text = @"请连接听诊器";
        _labelMessage2.textColor = UIColor.redColor;
        _labelMessage2.textAlignment = NSTextAlignmentCenter;
        _labelMessage2.font = Font18;
    }
    return _labelMessage2;
}

- (UIView *)viewLine1{
    if (!_viewLine1) {
        _viewLine1 = [[UIView alloc] init];
        _viewLine1.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine1;
}

- (UIView *)viewLine2{
    if (!_viewLine2) {
        _viewLine2 = [[UIView alloc] init];
        _viewLine2.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine2;
}

- (HeartFilterLungView *)heartFilterLungView{
    if (!_heartFilterLungView) {
        _heartFilterLungView = [[HeartFilterLungView alloc] init];
    }
    return _heartFilterLungView;
}


- (UIButton *)buttonSaveRecord{
    if(!_buttonSaveRecord) {
        _buttonSaveRecord = [[UIButton alloc] init];
        [_buttonSaveRecord setImage:[UIImage imageNamed:@"check_false"] forState:UIControlStateNormal];
        [_buttonSaveRecord setImage:[UIImage imageNamed:@"check_true"] forState:UIControlStateSelected];
        [_buttonSaveRecord addTarget:self action:@selector(actionCilckSaveRecord:) forControlEvents:UIControlEventTouchUpInside];
        _buttonSaveRecord.imageEdgeInsets = UIEdgeInsetsMake(Ratio3, Ratio3, Ratio3, Ratio3);
    }
    return _buttonSaveRecord;
}

- (UILabel *)labelSaveRecord{
    if (!_labelSaveRecord) {
        _labelSaveRecord = [[UILabel alloc] init];
        _labelSaveRecord.text = @"我想同步保存录音文件";
        _labelSaveRecord.font = [UIFont systemFontOfSize:Ratio10];
        _labelSaveRecord.textAlignment = NSTextAlignmentCenter;
        _labelSaveRecord.textColor = MainBlack;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapLavelSaveRecord:)];
        [_labelSaveRecord addGestureRecognizer:tapGesture];
    }
    return _labelSaveRecord;
}

- (UILabel *)labelAddStudent{
    if (!_labelAddStudent) {
        _labelAddStudent = [[UILabel alloc] init];
        _labelAddStudent.text = @"已加入学员：";
        _labelAddStudent.textColor = MainBlack;
        _labelAddStudent.font = Font15;
    }
    return _labelAddStudent;
}

@end
