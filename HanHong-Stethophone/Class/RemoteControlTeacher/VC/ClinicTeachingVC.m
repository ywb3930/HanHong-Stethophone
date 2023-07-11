//
//  ClinicVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/25.
//

#import "ClinicTeachingVC.h"
#import "ClinicTeachingHeaderView.h"
#import "ClinicCell.h"
#import "UINavigationController+QMUI.h"
#import "UIViewController+HBD.h"
#import "ClassRoom.h"
#import "MemberItemModel.h"
#import "UIButton+WXD.h"

@interface ClinicTeachingVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerBackButtonHandlerProtocol, ClassRoomDelegate, ClinicTeachingHeaderDelegate>

@property (retain, nonatomic) TeachingHistoryModel          *historyModel;
@property (retain, nonatomic) UICollectionView              *collectionView;
@property (retain, nonatomic) NSMutableArray                *arrayData;
@property (retain, nonatomic) ClinicTeachingHeaderView      *headerView;
@property (assign, nonatomic) CGFloat                       itemWidth;
@property (assign, nonatomic) NSInteger                     classroomState;
@property (retain, nonatomic) ClassRoom                     *classRoom;
@property (assign, nonatomic) Boolean                       bClassroomEnter;
@property (assign, nonatomic) Boolean                       bDataServiceReady;
@property (assign, nonatomic) Boolean                       bRecordStartRetry;
@property (retain, nonatomic) ClassRoomInfo                 *classRoomInfo;

@end

@implementation ClinicTeachingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"临床教学";
    self.arrayData = [NSMutableArray array];
    self.recordType = RemoteRecord;
    self.bAutoSaveRecord = NO;
    self.itemWidth = (screenW-Ratio66)/5;
    [self initNavi:1];
    [self setupView];
    self.view.backgroundColor = WHITECOLOR;
    [self loadPlistData:YES];
    [self loadRecordTypeData];
    
    [self getTeachingClassroom];
    [self initClassRoom];
    if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_NOT_CONNECT) {
        [self actionDeviceHelperRecordReady];
    }
}


- (void)actionButtonClickCallback:(Boolean)start{
    if (start) {
        if (self.classroomState == 0) {
            [self.classRoom ClassBegin];
            if (self.historyListBlock) {
                self.historyListBlock();
            }
        }
    } else {
        if (self.classroomState == 1) {
            [Tools showAlertView:nil andMessage:@"是否确定结束本次临床教学？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
                [self.classRoom ClassEnd];
                if (self.historyListBlock) {
                    self.historyListBlock();
                }
            } cancel:^{
                
            }];
        }
    }
}

- (void)initClassRoom{
    self.classRoom = [[ClassRoom alloc] init];
    self.classRoom.delegate = self;
}

- (void)actionEnterRoom{
    [self.classRoom Enter:LoginData.token classroom_url:self.historyModel.server_url classroom_id:(int)self.historyModel.classroom_id];
}

- (void)actionClassExited{
    if (self.bClassroomEnter) {
        self.headerView.roomMessage = @"教室断开，正在连接";
        [self actionEnterRoom];
    } else {
        self.headerView.roomMessage = @"教室已断开";
    }
    [self.view makeToast:@"教室已断开" duration:showToastViewWarmingTime position:CSToastPositionCenter];
}

- (void)actionClassInfoUpdate:(NSObject *)args1{
    self.classRoomInfo = (ClassRoomInfo *)args1;
    NSLog(@"self.historyModel.class_state = %li, self.classroomState = %li", (long)self.historyModel.class_state, (long)self.classroomState);
    if (self.classroomState != self.classRoomInfo.class_state) {
        self.classroomState = self.classRoomInfo.class_state;
        if (self.classroomState == 1) {
            [self.classRoom StartAuscultation];
        } else if(self.historyModel.class_state == 2) {
            [self.classRoom StopAuscultation];
        }
    }
    self.historyModel.class_state = self.classroomState;
    self.headerView.classroomState = self.classroomState;
    
    if (self.classroomState == 1) {
        if ([[HHBlueToothManager shareManager] getConnectState] != DEVICE_CONNECTED) {
            self.headerView.recordMessage = @"请连接设备";
        } else if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
            self.headerView.recordMessage = @"当前连接的设备不是听诊器";
        }
    } else if (self.classroomState == 2) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionClassMemberUpdate:(NSObject *)args3{
    MemberList *memberList = (MemberList *)args3;
    NSLog(@"教室状态:当前教室在线人数：%i", memberList.count);
    for (Member *member in memberList.members) {
        int user_id = member.user_id;
        if (user_id == LoginData.id) {
            continue;//不能插入自己
        }
        Boolean isExist = NO;
        MemberItemModel *model = [[MemberItemModel alloc] init];
        
        for (MemberItemModel *itemModel in self.arrayData) {
            if (user_id == itemModel.member.user_id) {
                isExist = YES;
            }
        }
        if (!isExist) {
            model.member = member;
            [self.arrayData addObject:model];
        }
    }
    
    for (MemberItemModel *itemModel in self.arrayData) {
        Member *itemModelMember = itemModel.member;
        Boolean online = NO;
        for (Member *member in memberList.members) {
            if (itemModelMember.user_id == member.user_id) {
                online = YES;
                break;
            }
        }
        if (online) {
            itemModel.bOnline = YES;
        } else {
            itemModel.bOnline = NO;
            itemModel.bConnect = NO;
        }
    }
    
    [self.collectionView reloadData];
}

- (void)actionClassStartAuscultationControlResult:(NSObject *)args1{
    NSString *sarg1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sarg1 boolValue];
    NSLog(@"录音开始：%@", success ? @"成功" : @"失败");
    if (success) {
        self.headerView.roomMessage = @"开始临床教学操作成功";
    } else {
        self.headerView.roomMessage = @"开始临床教学操作失败";
    }
}

- (void)actionClassStopAuscultationControlResult:(NSObject *)args1{
    NSString *sarg1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sarg1 boolValue];
    NSLog(@"录音结束：%@", success ? @"成功" : @"失败");
    if (success) {
        self.headerView.roomMessage = @"暂停临床教学操作成功";
    } else {
        self.headerView.roomMessage = @"暂停临床教学操作失败";
    }
}

- (void)actionClassBeginControlResult:(NSObject *)args1{
    NSString *sarg1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sarg1 boolValue];
    NSLog(@"课堂开始：%@", success ? @"成功" : @"失败");
    if (!success) {
        [self.view makeToast:@"操作失败" duration:showToastViewWarmingTime position:CSToastPositionCenter];
    }
}

- (void)actionClassEndControlResult:(NSObject *)args1{
    NSString *sarg1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sarg1 boolValue];
    NSLog(@"课堂结束：%@", success ? @"成功" : @"失败");
    if (!success) {
        [self.view makeToast:@"操作失败" duration:showToastViewWarmingTime position:CSToastPositionCenter];
    }
}

- (void)actionClassDataServiceConnectSuccess{
    
    if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED == [[HHBlueToothManager shareManager] getDeviceType] == STETHOSCOPE) {
        [self.classRoom SendCommand:1 data:NULL];
        [self actionStartRecord];
        self.bDataServiceReady = YES;
    } else {
        self.bDataServiceReady = NO;
    }
    self.headerView.roomMessage = @"临床教学进行中";
    self.headerView.recordMessage = @"按听诊器录音键可开始录音";
    
}

- (void)actionClassDataServiceClientInfoReceived:(NSObject *)args3{
    Clients *clients = (Clients *)args3;
    NSLog(@"当前教室联通人数：%i", clients.count);
    for (MemberItemModel *itemModel in self.arrayData) {
        for (NSNumber *number in clients.members) {
            if (itemModel.member.user_id == [number intValue]) {
                itemModel.bConnect = YES;
                break;
            } else {
                itemModel.bConnect = NO;
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)actionDeviceHelperRecordEnd{
    self.headerView.recordMessage = @"录音完成,按听诊器键重新开始录音";
    [self.classRoom SendCommand:0 data:NULL];
}

- (void)actionDeviceHelperRecordingData:(NSObject *)args1{
    NSData *data = (NSData *)args1;
    [self.classRoom SendWavFrame:0 wav_frame:data];
}

- (void)actionClassRommEvent:(CLASSROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    if (event == ClassEntering) {
        NSLog(@"正在进入教室");
    } else if (event == ClassEnterSuccess) {
        self.headerView.roomMessage = @"进入教室成功";
        if (self.historyModel.class_state == 1) {
            [self.classRoom StartAuscultation];
        }
    } else if (event == ClassEnterFailed) {
        self.headerView.roomMessage = @"进入教室失败";
        self.bClassroomEnter = NO;
    } else if (event == ClassExited) {
        [self actionClassExited];
    } else if (event == ClassInfoUpdate) {
        [self actionClassInfoUpdate:args1];
        NSLog(@"教室状态:%i", self.classRoomInfo.class_state);
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
    }
    
    else if (event == ClassStartAuscultation) {
        NSLog(@"听诊开始");//学生收到这个信号
        self.headerView.roomMessage = @"临床教学开始";
    } else if (event == ClassStopAuscultation) {
        NSLog(@"听诊结束");//学生收到这个信号
        if (self.classroomState == 2) {
            self.headerView.roomMessage = @"临床教学已结束";
        } else {
            self.headerView.roomMessage = @"临床教学已暂停";
        }
    } else if (event == ClassDataServiceConnecting) {
        NSLog(@"远程听诊连接中");
        self.headerView.roomMessage = @"临床教学已服务器连接中";
    } else if (event == ClassDataServiceConnectSuccess) {
        NSLog(@"远程听诊连接成功");
        [self actionClassDataServiceConnectSuccess];
    } else if (event == ClassDataServiceClientInfoReceived) {
        [self actionClassDataServiceClientInfoReceived:args3];
    } else if (event == ClassDataServiceWavFrameReceived) {
        NSLog(@"远程听诊 ClassDataServiceWavFrameReceived--");
    } else if (event == ClassDataServiceCmdReceived) {
        NSLog(@"远程听诊 ClassDataServiceCmdReceived");
    }
//    else if (event == DeviceHelperRecordingData) {
//        [self actionClassDeviceHelperRecordingData:args1];
//    }
}

- (void)on_classroom_event:(CLASSROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    NSLog(@"event = %@, args1 = %@ , args2 = %@, args3 = %@", [@(event) stringValue], args1, args2, args3);
    if ([NSThread isMainThread]) {
        [self actionClassRommEvent:event args1:args1 args2:args2 args3:args3];
    } else {
        __weak typeof(self) wself = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [wself actionClassRommEvent:event args1:args1 args2:args2 args3:args3];
        });
    }
}

- (void)actionDeviceHelperRecordReady{
    self.headerView.recordMessage = @"按听诊器录音键可以开始录音";
}


- (void)actionDeviceHelperRecordingTime:(float)number{
    NSInteger second = self.recordDurationAll - number;
    NSString *secondLeft = [Tools getMMSSFromSS:second];
    self.headerView.recordMessage = [NSString stringWithFormat:@"正在录音%@,按录音键停止", secondLeft];

}

- (void)actionDeviceHelperRecordPause{
    self.headerView.recordMessage = @"录音暂停,按听诊器键重新开始录音";
}


- (void)getTeachingClassroom{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    //params[@"create_new"] = [@(false) stringValue];
    __weak typeof(self) wself = self;
    [TTRequestManager teachingGetClassroom:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            wself.historyModel = [TeachingHistoryModel yy_modelWithJSON:responseObject[@"data"]];
            wself.classroomState = wself.historyModel.class_state;
            [wself getTeachingStudents];
            [wself actionEnterRoom];
            [wself reloadClassroom];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)reloadClassroom{
    self.headerView.historyModel = self.historyModel;
}

- (void)getTeachingStudents{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"classroom_id"] = [@(self.historyModel.classroom_id) stringValue];
    __weak typeof(self) wself = self;
    [TTRequestManager teachingGetStudents:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSArray *data = responseObject[@"data"];
            NSLog(@"data = %li", data.count);
            //[self loadUserView:data];
            for (NSDictionary *dictionary in data) {
                Member *member = [[Member alloc] init];
                member.user_id = [dictionary[@"id"] intValue];
                member.user_name = dictionary[@"name"];
                member.user_avatar = dictionary[@"avatar"];
                MemberItemModel *itemModel = [[MemberItemModel alloc] init];
                itemModel.member = member;
                [wself.arrayData addObject:itemModel];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED == [[HHBlueToothManager shareManager] getDeviceType] == STETHOSCOPE) {
        [self.classRoom SendCommand:1 data:NULL];
        [self actionStartRecord];
    }
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


- (void)actionTapLavelSaveRecord:(UITapGestureRecognizer *)tap{
    
}

- (void)actionCilckSaveRecord:(UIButton *)button{
    
}


- (BOOL)shouldHoldBackButtonEvent {
    return YES;
}

- (BOOL)canPopViewController {
    // 这里不要做一些费时的操作，否则可能会卡顿。
    __weak typeof(self) wself = self;
    [Tools showAlertView:nil andMessage:@"确定退出吗？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
        [wself.navigationController popViewControllerAnimated:YES];
    } cancel:^{
        
    }];
    return NO;
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
    //NSInteger row = indexPath.row;
    //cell.model = self.arrayData[row];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, Ratio11, 0, Ratio11);
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        self.headerView = (ClinicTeachingHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([ClinicTeachingHeaderView class]) forIndexPath:indexPath];
        __weak typeof(self) wself = self;
        self.headerView.delegate = self;
        self.headerView.syncSaveBlock = ^(Boolean bSyncSave) {
            wself.bAutoSaveRecord = bSyncSave;
        };
//        self.headerView.consultationModel = self.consultationModel;
//        self.headerView.bCollector = self.bCollector;
//        self.headerView.userModel = self.collectorModel;
//        self.headerView.delegate = self;
        reusableview = self.headerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return  CGSizeMake(screenW, 300.f*screenRatio + screenW/3);
}



- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *fallsLayout = [[UICollectionViewFlowLayout alloc] init];
        fallsLayout.estimatedItemSize = CGSizeMake(self.itemWidth , self.itemWidth + Ratio15);
        fallsLayout.minimumInteritemSpacing = Ratio11;
        [fallsLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        fallsLayout.headerReferenceSize = CGSizeMake(screenW, 300.f*screenRatio + screenW/3);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fallsLayout];
        _collectionView.backgroundColor = WHITECOLOR;
        [_collectionView registerClass:[ClinicCell class] forCellWithReuseIdentifier:NSStringFromClass([ClinicCell class])];
        
        [_collectionView registerClass:[ClinicTeachingHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([ClinicTeachingHeaderView class])];
        
        //collectionView的item只剩下一个时自动左对齐
        SEL sel = NSSelectorFromString(@"_setRowAlignmentsOptions:");
        if ([_collectionView.collectionViewLayout respondsToSelector:sel]) {
            ((void(*)(id,SEL,NSDictionary*)) objc_msgSend)(_collectionView.collectionViewLayout, sel, @{@"UIFlowLayoutCommonRowHorizontalAlignmentKey":@(NSTextAlignmentLeft),@"UIFlowLayoutLastRowHorizontalAlignmentKey" : @(NSTextAlignmentLeft), @"UIFlowLayoutRowVerticalAlignmentKey" : @(NSTextAlignmentCenter)});
        }
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
//        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]  initWithTarget:self action:@selector(handleLongPress:)];
//        //lpgr.delegate = self;
//        lpgr.delaysTouchesBegan = YES;
//        [_collectionView addGestureRecognizer:lpgr];
    }
    return _collectionView;
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
