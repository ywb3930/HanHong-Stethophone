//
//  ClinicLearningVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/10.
//

#import "ClinicLearningVC.h"
#import "ClinicLearningHeaderView.h"
#import "ClinicCell.h"
#import "UINavigationController+QMUI.h"
#import "UIViewController+HBD.h"
#import "ClassRoom.h"

#define BtDevice_ununited_state 0
#define BtDevice_connected_state 1
#define BtDevice_connecting_state 2

@interface ClinicLearningVC ()<ClassRoomDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ClinicLearningHeaderViewDelegate>

@property (retain, nonatomic) UICollectionView              *collectionView;
@property (retain, nonatomic) NSMutableArray                *arrayData;
@property (retain, nonatomic) ClinicLearningHeaderView      *headerView;
@property (assign, nonatomic) CGFloat                       itemWidth;
@property (retain, nonatomic) ClassRoom                     *classRoom;

@property (assign, nonatomic) Boolean                       bClassroomEnter;
@property (assign, nonatomic) Boolean                       bDataServiceReady;
@property (assign, nonatomic) Boolean                       bDataServiceRecording;
@property (assign, nonatomic) int                           classroomState;
@property (retain, nonatomic) ClassRoomInfo                 *classRoomInfo;
@property (retain, nonatomic) NSOperationQueue              *mainQueue;

@end

@implementation ClinicLearningVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"临床学习";
    self.mainQueue = [NSOperationQueue mainQueue];
    self.view.backgroundColor = WHITECOLOR;
    self.recordmodel = RecordingWithRecordDurationMaximum;
    self.recordType = RemoteRecord;
    self.arrayData = [NSMutableArray array];
    self.itemWidth = (screenW-Ratio66)/5;
    [self initNavi:1];
    [self setupView];
    
    [self enterClassroom];
}

- (void)actionClassExited{
    if (self.bClassroomEnter) {
        [self actionShowRoomMessage:@"教室已断开，正在重连"];
        [self performSelector:@selector(actionEnterRoom) withObject:nil afterDelay:1.0f];
    } else {
        [self actionShowRoomMessage:@"教室已断开"];
    }
}

- (void)actionEnterRoom{
    int classroomIdInt = [self.classroomId intValue];
    [self.classRoom Enter:LoginData.token classroom_url:self.classroomUrl classroom_id:classroomIdInt];
}

- (void)actionClassInfoUpdate:(NSObject *)args1{
    //self.arrayData = [NSMutableArray array];
    self.classRoomInfo = (ClassRoomInfo *)args1;
    self.classroomState = self.classRoomInfo.class_state;
    NSLog(@"教室状态：%i", self.classroomState);
    NSString *stateStr = (self.classroomState == 1) ? @"进行中" : (self.classroomState == 2) ? @"已结束" : @"未开始";
    Boolean bStart = self.classroomState >= 1;
    NSString *teachingTimes = bStart ? [@(self.classRoomInfo.teaching_times) stringValue] : @"--";
    NSString *numbersOfStudents = bStart ? [@(self.classRoomInfo.number_of_learners) stringValue] : @"--";
    
    MemberList *memberList = (MemberList *)self.classRoomInfo.students_list;
    Boolean bChange = NO;
    for (Member *member in memberList.members) {
        Boolean bExist = NO;
        for (MemberItemModel *itemModel in self.arrayData) {
            if (member.user_id == itemModel.member.user_id) {
                bExist = YES;
            }
        }
        if (!bExist) {
            bChange = YES;
            MemberItemModel *itemModel = [[MemberItemModel alloc] init];
            itemModel.member = member;
            [self.arrayData addObject:itemModel];
        }
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.headerView.roomState = stateStr;
        wself.headerView.startTime = bStart ? wself.classRoomInfo.class_begin_time : @"--";
        wself.headerView.learnCount = teachingTimes;
        wself.headerView.learnMember = numbersOfStudents;
        NSLog(@"teacher_avatar = %@", wself.classRoomInfo.teacher_avatar);
        wself.headerView.teachAvatar = wself.classRoomInfo.teacher_avatar;
        wself.headerView.teachName = wself.classRoomInfo.teacher_name;
        if (bChange) {
            [wself.collectionView reloadData];
        }
        
    }];
    
    if(self.classroomState == 1 && [[HHBlueToothManager shareManager] getConnectState] != BtDevice_connected_state){
        [self actionShowRoomMessage:@"请先连接设备"];
    }
}

- (void)actionClassMemberUpdate:(NSObject *)args3{
    MemberList *memberList = (MemberList *)args3;
    Boolean bTeacherOnline = NO;
    for (Member *member in memberList.members) {
        if (member.user_id == self.classRoomInfo.teacher_id) {//判断是否是教师
            bTeacherOnline = YES;
            break;
        }
    }
    self.headerView.bOnline = bTeacherOnline;
    
    for (MemberItemModel *itemModel in self.arrayData) {
        Member *member1 = itemModel.member;
        Boolean bOnline = NO;
        for (Member *member2 in memberList.members) {
            if (member1.user_id == member2.user_id) {
                bOnline = YES;
                break;;
            }
        }
        itemModel.bOnline = bOnline;
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.collectionView reloadData];
    }];
    
}

- (void)actionClassStartAuscultationControlResult:(NSObject *)args1{
    NSString *sargs1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sargs1 boolValue];
    [self actionShowRoomMessage:success ? @"临床教学开始" : @"开始临床教学操作失败"];
}

- (void)actionClassStopAuscultationControlResult:(NSObject *)args1{
    NSString *sargs1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sargs1 boolValue];
    [self actionShowRoomMessage:success ? @"临床教学已暂停" : @"暂停临床教学操作失败"];
}

- (void)actionClassBeginControlResult:(NSObject *)args1{
    NSString *sargs1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sargs1 boolValue];
    NSLog(@"课堂开始:%@", success ? @"成功" : @"失败");
    if (!success) {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            [wself.view makeToast:@"操作失败" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }];
        
    }
}

- (void)actionClassEndControlResult:(NSObject *)args1{
    NSString *sargs1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sargs1 boolValue];
    NSLog(@"课堂结束:%@", success ? @"成功" : @"失败");
    if (!success) {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            [wself.view makeToast:@"操作失败" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }];
    }
}

- (void)actionClassDataServiceWavFrameReceived:(NSObject *)args1 args2:(NSObject *)args2{
    NSString *flag = [NSString stringWithFormat:@"%@", args1];
    NSData *wav_frame = (NSData *)args2;
    [[HHBlueToothManager shareManager] writePlayBuffer:wav_frame];
    if (!self.bDataServiceRecording) {
        self.bDataServiceRecording = YES;
        NSLog(@"播放中 ---");
        [[HHBlueToothManager shareManager] startPlay:PlayingWithRealtimeData];
    }
}


- (void)actionClassDataServiceCmdReceived:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    NSString *sargs1 = [NSString stringWithFormat:@"%@", args1];
    int cmd = [sargs1 intValue];
    if (cmd == 1) {
        if (!self.bDataServiceRecording) {
            self.bDataServiceRecording = YES;
            [[HHBlueToothManager shareManager] startPlay:PlayingWithRealtimeData];
        }
    } else {
        if (self.bDataServiceRecording) {
            self.bDataServiceRecording = NO;
            [[HHBlueToothManager shareManager] stop];
        }
    }
}

- (void)actionDeviceConnecting{
    [self actionShowRecordMessage:@"设备正在连接"];
}

- (void)actionDeviceConnected{
    if (self.bDataServiceRecording) {
        [self actionStartRecord];
    } else {
        [self actionShowRecordMessage:@""];
    }
}

- (void)actionDeviceDisconnected{
    [self actionShowRecordMessage:@"设备已断开"];
    [self actionStop];
}

- (void)actionDeviceConnectFailed{
    [self actionShowRecordMessage:@"设备连接失败"];
}

- (void)actionDeviceHelperPlayBegin {
    [self actionShowRecordMessage:@"正在听诊"];
}

- (void)actionDeviceHelperPlayEnd{
    [self actionShowRecordMessage:@""];
}

- (void)actionDeviceRecordPlayInstable{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.view makeToast:@"无线数据传输不稳定" duration:showToastViewWarmingTime position:CSToastPositionCenter];
    }];
}

- (void)actionClassDataServiceClientInfoReceived:(Clients *)clients{
    for (MemberItemModel *itemModel in self.arrayData) {
        Member *member1 = itemModel.member;
        for (NSNumber *number in clients.members) {
            
            if (member1.user_id == [number intValue]) {
                itemModel.bConnect = YES;
                break;
            } else {
                itemModel.bConnect = NO;
            }
        }
    }
    
    Boolean bTeachOnline = NO;
    for (NSNumber *number in clients.members) {
        if (self.classRoomInfo.teacher_id == [number intValue]) {
            bTeachOnline = YES;
            break;
        }
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.headerView.bOnline = bTeachOnline;
        [wself.collectionView reloadData];
    }];
    
}

- (void)actionShowRoomMessage:(NSString *)messaage{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.headerView.roomMessage = messaage;
    }];
}

- (void)actionShowRecordMessage:(NSString *)messaage{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.headerView.recordMessage = messaage;
    }];
}

- (void)on_classroom_event:(CLASSROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    NSLog(@"event = %@, args1 = %@ , args2 = %@, args3 = %@", [@(event) stringValue], args1, args2, args3);
    if (event == ClassEntering) {
        NSLog(@"正在进入教室");
    } else if (event == ClassEnterSuccess) {
        NSLog(@"进入教室成功");
        [self actionShowRoomMessage:@"进入教室成功"];
        self.bClassroomEnter = NO;
    } else if (event == ClassExited) {
        NSLog(@"退出教室");
        [self actionClassExited];
    } else if (event == ClassInfoUpdate) {
        [self actionClassInfoUpdate:args1];
    } else if (event == ClassMemberUpdate) {
        [self actionClassMemberUpdate:args3];
    } else if (event == ClassStartAuscultationControlResult) {
        [self actionClassStartAuscultationControlResult:args1];
    } else if (event == ClassStopAuscultationControlResult) {
        [self actionClassStopAuscultationControlResult:args1];
    } else if (event == ClassBeginControlResult) {
        [self actionClassBeginControlResult:args1];
    } else if (event == ClassEndControlResult) {
        [self actionClassEndControlResult:args1];
    } else if (event == ClassStartAuscultation) {
        [self actionShowRoomMessage:@"临床教学开始"];
    } else if (event == ClassStopAuscultation) {
        [self actionShowRoomMessage:(self.classroomState == 2) ? @"临床教学已结束" : @"临床教学已暂停"];
    } else if (event == ClassDataServiceConnecting) {
        [self actionShowRoomMessage:@"临床教学服务器连接中"];
    } else if (event == ClassDataServiceConnectSuccess) {
        [self actionShowRoomMessage:@"临床教学进行中"];
        self.bDataServiceReady = YES;
    } else if (event == ClassDataServiceConnectFailed) {
        NSString *message = [NSString stringWithFormat:@"临床教学服务器连接失败: %@", args1];
        [self actionShowRoomMessage:message];
    } else if (event == ClassDataServiceDisconnected) {
        self.bDataServiceReady = NO;
        self.bDataServiceRecording = NO;
        [self actionClearConnectState];
        [self actionShowRoomMessage:@"临床教学服务器连接断开"];
    } else if (event == ClassDataServiceWavFrameReceived) {
        [self actionClassDataServiceWavFrameReceived:args1 args2:args2];
    } else if (event == ClassDataServiceCmdReceived) {
        [self actionClassDataServiceCmdReceived:args1 args2:args2 args3:args3];
    } else if (event == ClassDataServiceClientInfoReceived) {
        Clients *clients = (Clients *)args3;
        [self actionClassDataServiceClientInfoReceived:clients];
    }
    
}

- (void)actionClearConnectState{
    for (MemberItemModel *itemModel in self.arrayData) {
        itemModel.bConnect = NO;
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.collectionView reloadData];
    }];
}

- (void)enterClassroom{
    self.classRoom = [[ClassRoom alloc] init];
    self.classRoom.delegate = self;
    if (![self.classRoom isEntered]) {
        [self.classRoom Enter:LoginData.token classroom_url:self.classroomUrl classroom_id:[self.classroomId intValue]];
    }
}


- (void)setupView{
    [self.view addSubview:self.collectionView];
    self.collectionView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, kBottomSafeHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ClinicCell *cell = (ClinicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ClinicCell class]) forIndexPath:indexPath];
    cell.itemModel = self.arrayData[indexPath.row];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, Ratio11, 0, Ratio11);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        self.headerView = (ClinicLearningHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([ClinicLearningHeaderView class]) forIndexPath:indexPath];
        self.headerView.delegate = self;
        reusableview = self.headerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return  CGSizeMake(screenW, 367.f*screenRatio);
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *fallsLayout = [[UICollectionViewFlowLayout alloc] init];
        fallsLayout.estimatedItemSize = CGSizeMake(self.itemWidth , self.itemWidth + Ratio15);
        fallsLayout.minimumInteritemSpacing = Ratio11;
        [fallsLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        fallsLayout.headerReferenceSize = CGSizeMake(screenW, 367.f*screenRatio);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fallsLayout];
        _collectionView.backgroundColor = WHITECOLOR;
        [_collectionView registerClass:[ClinicCell class] forCellWithReuseIdentifier:NSStringFromClass([ClinicCell class])];
        
        [_collectionView registerClass:[ClinicLearningHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([ClinicLearningHeaderView class])];
        
        //collectionView的item只剩下一个时自动左对齐
        SEL sel = NSSelectorFromString(@"_setRowAlignmentsOptions:");
        if ([_collectionView.collectionViewLayout respondsToSelector:sel]) {
            ((void(*)(id,SEL,NSDictionary*)) objc_msgSend)(_collectionView.collectionViewLayout, sel, @{@"UIFlowLayoutCommonRowHorizontalAlignmentKey":@(NSTextAlignmentLeft),@"UIFlowLayoutLastRowHorizontalAlignmentKey" : @(NSTextAlignmentLeft), @"UIFlowLayoutRowVerticalAlignmentKey" : @(NSTextAlignmentCenter)});
        }
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}



- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.recordingState == recordingState_prepare || self.recordingState == recordingState_ing) {
        [[HHBlueToothManager shareManager] stop];
    }
    self.recordingState = recordingState_stop;
    self.bClassroomEnter = NO;
    [self.classRoom Exit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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


- (Boolean)actionHeartLungButtonClickCallback:(NSInteger)idx {
    if (self.recordingState == recordingState_ing) {
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    
    if (idx == 1) {
        self.soundsType = heart_sounds;
    } else if (idx == 2) {
        self.soundsType = lung_sounds;
    }
    [self loadRecordTypeData];
    if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED == [[HHBlueToothManager shareManager] getDeviceType] == STETHOSCOPE) {
        [self.classRoom SendCommand:1 data:NULL];
        [self actionStartRecord];
        
    } else {
    }
    
    return YES;
}



@end
