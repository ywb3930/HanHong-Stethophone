//
//  RemoteControlDetailVC.m
//  HanHong-Stethophone
//  
//  Created by 袁文斌 on 2023/6/24.
//

#import "RemoteControlDetailVC.h"
#import "RegisterItemView.h"
#import "HeartFilterLungView.h"
#import "ConsultationModel.h"

@interface RemoteControlDetailVC ()

@property (retain, nonatomic) UILabel               *labelTitle;
@property (retain, nonatomic) UIScrollView          *scrollView;
@property (retain, nonatomic) RegisterItemView      *itemTitle;
@property (retain, nonatomic) RegisterItemView      *itemStartTime;
@property (retain, nonatomic) RegisterItemView      *itemDuration;

@property (retain, nonatomic) UIView                *viewLine1;
@property (retain, nonatomic) UIView                *viewLine2;
@property (retain, nonatomic) UIView                *viewLine3;
@property (retain, nonatomic) UILabel               *labelPatient;
@property (retain, nonatomic) UIImageView           *imageViewPatient;
@property (retain, nonatomic) UILabel               *labelPatientName;
@property (retain, nonatomic) UIImageView           *imageViewTag;
@property (retain, nonatomic) UIImageView           *imageViewOnLine;
@property (retain, nonatomic) UIView                *viewRecord;
@property (retain, nonatomic) HeartFilterLungView   *heartFilterLungView;
@property (retain, nonatomic) UIButton              *buttonSaveRecord;
@property (retain, nonatomic) UILabel               *labelSaveRecord;
@property (retain, nonatomic) UILabel               *labelMembers;

@property (retain, nonatomic) NSMutableArray        *arrayData;
@property (assign, nonatomic) Boolean               bShowFilter;

@property (retain, nonatomic) ConsultationModel    *consultationModel;

@end

@implementation RemoteControlDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"远程会诊";
    self.view.backgroundColor = WHITECOLOR;
    [self initData];
    [self setupView];
}

- (void)reloadView{
    self.arrayData = [NSMutableArray array];
    for (FriendModel *model in self.consultationModel.members) {
        [self.arrayData addObject:model];
    }
    if(self.consultationModel.creator_id == LoginData.id){
        self.bShowFilter = YES;
    }
    
    NSInteger delTime = [Tools insertStarTimeo:self.consultationModel.begin_time andInsertEndTime:self.consultationModel.end_time];
    delTime = (delTime == 0) ? 1 : delTime;
    self.itemDuration.textFieldInfo.text = [NSString stringWithFormat:@"%li分钟", (long)delTime];
    self.labelPatientName.text = self.consultationModel.creator_name;
    [self.imageViewPatient sd_setImageWithURL:[NSURL URLWithString:self.consultationModel.creator_avatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
    self.itemStartTime.textFieldInfo.text = self.consultationModel.begin_time;
    self.itemTitle.textFieldInfo.text = self.consultationModel.title;
    
    CGFloat viewHeight1 = Ratio66;
    CGFloat viewHeight2 = Ratio11;
    if(!self.bShowFilter) {
        //_labelTitle.text = @"进入会诊成功";
        self.viewRecord.hidden = YES;
        self.viewRecord.sd_layout.heightIs(0);
        self.viewLine3.sd_layout.heightIs(0).topSpaceToView(self.viewRecord, 0);
        [self.viewRecord updateLayout];
        [self.viewLine3 updateLayout];
        self.viewLine3.height = YES;
        self.imageViewOnLine.hidden = YES;
        self.imageViewTag.hidden = YES;
        viewHeight1 = 0;
        viewHeight2 = 0;
    }
    CGFloat width = (screenW - Ratio66)/5;
    for (NSInteger i = 0; i < self.arrayData.count; i++) {
        NSInteger jj = ceil(i / 5);
        NSInteger ii = i % 5;
        UIView *viewMember = [[UIView alloc] init];
        [self.scrollView addSubview:viewMember];
        viewMember.sd_layout.leftSpaceToView(self.scrollView, Ratio11 + (width + Ratio11) * ii).widthIs(width).heightIs(width + Ratio28).topSpaceToView(self.labelMembers, Ratio22 + (width + Ratio33) * jj);
        
        FriendModel *model = [self.arrayData objectAtIndex:i];
        UIImageView *imageViewHead = [[UIImageView alloc] init];
        [imageViewHead sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
        imageViewHead.layer.cornerRadius = Ratio4;
        imageViewHead.contentMode = UIViewContentModeScaleAspectFit;
        [viewMember addSubview:imageViewHead];
        imageViewHead.sd_layout.centerXEqualToView(viewMember).widthIs(width - Ratio10).heightIs(width - Ratio10).topSpaceToView(viewMember, 0);


        UILabel *labelName = [[UILabel alloc] init];
        labelName.text = model.name;
        labelName.font = Font13;
        labelName.textAlignment = NSTextAlignmentCenter;
        [viewMember addSubview:labelName];
        labelName.sd_layout.centerXEqualToView(imageViewHead).widthIs(width).heightIs(Ratio15).topSpaceToView(imageViewHead, Ratio3);
        
        if (i == self.arrayData.count - 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CGFloat maxY = CGRectGetMaxY(viewMember.frame);
                if (maxY > screenH - kNavBarAndStatusBarHeight- 38.f*screenRatio) {
                    self.scrollView.contentSize = CGSizeMake(screenW, maxY + Ratio33);
                }
            });
        }
    }
    
    
}

- (void)initData{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"meetingroom_id"] = self.meetingroomd_id;
    [Tools showWithStatus:nil];
    [TTRequestManager meetingGetMeetingroom:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            self.consultationModel = [ConsultationModel yy_modelWithJSON:responseObject[@"data"]];
            [self reloadView];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)setupView{
    
    [self.view addSubview:self.labelTitle];
    self.labelTitle.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight + Ratio18).heightIs(Ratio20);
    
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.labelTitle, Ratio18).bottomSpaceToView(self.view, 0);
    
    [self.scrollView addSubview:self.itemTitle];
    self.itemTitle.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.scrollView, 0).heightIs(Ratio33);
    [self.scrollView addSubview:self.itemStartTime];
    self.itemStartTime.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemTitle, Ratio5).heightIs(Ratio33);
    [self.scrollView addSubview:self.itemDuration];
    self.itemDuration.sd_layout.leftSpaceToView(self.scrollView, Ratio11).rightSpaceToView(self.scrollView, Ratio11).topSpaceToView(self.itemStartTime, Ratio5).heightIs(Ratio33);
    
    [self.scrollView addSubview:self.viewLine1];
    self.viewLine1.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).topSpaceToView(self.itemDuration, Ratio22).heightIs(Ratio11);
    
    [self.scrollView addSubview:self.labelPatient];
    self.labelPatient.sd_layout.topSpaceToView(self.viewLine1, Ratio11).leftSpaceToView(self.scrollView, Ratio11).heightIs(Ratio16).widthIs(Ratio99);
    
    CGFloat width = (screenW - Ratio66)/5;
    
    [self.scrollView addSubview:self.imageViewPatient];
    self.imageViewPatient.sd_layout.centerXEqualToView(self.scrollView).widthIs(width - Ratio10).heightIs(width - Ratio10).topEqualToView(self.labelPatient);
    [self.scrollView addSubview:self.labelPatientName];
    self.labelPatientName.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).heightIs(Ratio14).topSpaceToView(self.imageViewPatient, Ratio4);
    [self.scrollView addSubview:self.imageViewTag];
    self.imageViewTag.sd_layout.rightEqualToView(self.imageViewPatient).bottomEqualToView(self.imageViewPatient).heightIs(Ratio12).widthIs(Ratio12);
    
    [self.scrollView addSubview:self.imageViewOnLine];
    self.imageViewOnLine.sd_layout.rightEqualToView(self.imageViewPatient).topEqualToView(self.imageViewPatient).heightIs(Ratio12).widthIs(Ratio12);
    
    [self.scrollView addSubview:self.viewLine2];
    self.viewLine2.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).heightIs(Ratio11).topSpaceToView(self.labelPatientName, Ratio22);
    
    [self.scrollView addSubview:self.viewRecord];
    self.viewRecord.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).topSpaceToView(self.viewLine2, 0).heightIs(Ratio66);
    [self.viewRecord addSubview:self.heartFilterLungView];
    self.heartFilterLungView.sd_layout.leftSpaceToView(self.viewRecord, 0).rightSpaceToView(self.viewRecord, 0).heightIs(Ratio44).topSpaceToView(self.viewRecord, Ratio22);
    CGFloat sWidth = [Tools widthForString:@"我想同步保存录音文件" fontSize:Ratio10 andHeight:Ratio20];
    [self.viewRecord addSubview:self.labelSaveRecord];
    self.labelSaveRecord.sd_layout.centerXIs(screenW/2+Ratio10).heightIs(Ratio20).widthIs(sWidth+Ratio1).topSpaceToView(self.heartFilterLungView, Ratio3);
    [self.viewRecord addSubview:self.buttonSaveRecord];
    self.buttonSaveRecord.sd_layout.rightSpaceToView(self.labelSaveRecord, 0).widthIs(Ratio20).heightIs(Ratio20).centerYEqualToView(self.labelSaveRecord);
    
    [self.scrollView addSubview:self.viewLine3];
    self.viewLine3.sd_layout.leftSpaceToView(self.scrollView, 0).rightSpaceToView(self.scrollView, 0).heightIs(Ratio11).topSpaceToView(self.viewRecord, Ratio22);
    
    [self.scrollView addSubview:self.labelMembers];
    self.labelMembers.sd_layout.leftSpaceToView(self.scrollView, Ratio11).heightIs(Ratio16).widthIs(Ratio135).topSpaceToView(self.viewLine3, Ratio11);
}

- (UILabel *)labelTitle{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textColor = MainColor;
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.font = Font18;
    }
    return _labelTitle;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (RegisterItemView *)itemTitle{
    if (!_itemTitle) {
        _itemTitle = [[RegisterItemView alloc] initWithTitle:@"会诊标题" bMust:NO placeholder:@""];
        _itemTitle.textFieldInfo.enabled = NO;
    }
    return _itemTitle;
}

- (UIView *)viewLine2{
    if (!_viewLine2) {
        _viewLine2 = [[UIView alloc] init];
        _viewLine2.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine2;
}

- (UIView *)viewLine3{
    if (!_viewLine3) {
        _viewLine3 = [[UIView alloc] init];
        _viewLine3.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine3;
}

- (UIView *)viewRecord{
    if(!_viewRecord) {
        _viewRecord = [[UIView alloc] init];
    }
    return _viewRecord;
}

- (RegisterItemView *)itemStartTime{
    if (!_itemStartTime) {
        _itemStartTime = [[RegisterItemView alloc] initWithTitle:@"开始时间" bMust:NO placeholder:@""];
        _itemStartTime.textFieldInfo.enabled = NO;
    }
    return _itemStartTime;
}

- (RegisterItemView *)itemDuration{
    if (!_itemDuration) {
        _itemDuration = [[RegisterItemView alloc] initWithTitle:@"会诊时长" bMust:NO placeholder:@""];
        _itemDuration.textFieldInfo.enabled = NO;
    }
    return _itemDuration;
}

- (UIView *)viewLine1{
    if (!_viewLine1) {
        _viewLine1 = [[UIView alloc] init];
        _viewLine1.backgroundColor = ViewBackGroundColor;
    }
    return _viewLine1;
}

- (UILabel *)labelPatient{
    if (!_labelPatient) {
        _labelPatient = [[UILabel alloc] init];
        _labelPatient.text = @"患者端：";
        _labelPatient.font = Font15;
        _labelPatient.textColor = MainBlack;
    }
    return _labelPatient;
}

- (UIImageView *)imageViewPatient{
    if (!_imageViewPatient) {
        _imageViewPatient = [[UIImageView alloc] init];
        _imageViewPatient.layer.cornerRadius = Ratio4;
        _imageViewPatient.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageViewPatient;
}

- (UILabel *)labelPatientName{
    if (!_labelPatientName) {
        _labelPatientName = [[UILabel alloc] init];
        
        _labelPatientName.font = Font13;
        _labelPatientName.textAlignment = NSTextAlignmentCenter;
    }
    return _labelPatientName;
}

- (UIImageView *)imageViewTag{
    if (!_imageViewTag) {
        _imageViewTag = [[UIImageView alloc] init];
        _imageViewTag.image = [UIImage imageNamed:@"collection_state"];
    }
    return _imageViewTag;
}

- (UIImageView *)imageViewOnLine{
    if (!_imageViewOnLine) {
        _imageViewOnLine = [[UIImageView alloc] init];
        _imageViewOnLine.image = [UIImage imageNamed:@"on_line"];
    }
    return _imageViewOnLine;
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

- (void)actionTapLavelSaveRecord:(UITapGestureRecognizer *)tap{
    self.buttonSaveRecord.selected = !self.buttonSaveRecord.selected;
}

- (void)actionCilckSaveRecord:(UIButton *)button{
    button.selected = !button.selected;
}

- (UILabel *)labelMembers{
    if (!_labelMembers) {
        _labelMembers = [[UILabel alloc] init];
        _labelMembers.text = @"专家组成员：";
        _labelMembers.font = Font15;
        _labelMembers.textColor = MainBlack;
    }
    return _labelMembers;
}


@end
