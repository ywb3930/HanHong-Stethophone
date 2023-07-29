//
//  RemoteControlDetailVC.m
//  HanHong-Stethophone
//  
//  Created by Hanhong on 2023/6/24.
//

#import "RemoteControlDetailVC.h"
#import "MeetingRoom.h"
#import "RemoteControlDetailHeaderView.h"
#import "CreateConsultationCell.h"
#import "UINavigationController+QMUI.h"
#import "UIViewController+HBD.h"
#import "DeviceManagerVC.h"

@interface RemoteControlDetailVC ()<MeetingRoomDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, RemoteControlDetailHeaderViewDelegate, TTActionSheetDelegate, UINavigationControllerBackButtonHandlerProtocol, HHBluetoothButtonDelegate>


@property (retain, nonatomic) NSMutableArray        *arrayData;
//@property (assign, nonatomic) Boolean               bShowFilter;
@property (retain, nonatomic) UICollectionView       *collectionView;
@property (retain, nonatomic) NSIndexPath            *currentIndexPath;

@property (retain, nonatomic) MeetingRoom           *meetingRoom;
@property (assign, nonatomic) Boolean               bMeetingRoomEnter;//是否已进入会议室
@property (assign, nonatomic) Boolean               bDataServiceRecording;//采集者
@property (assign, nonatomic) Boolean               bDataServiceReady;//听诊
@property (assign, nonatomic) NSInteger             collector_id;//采集者ID
@property (retain, nonatomic) RemoteControlDetailHeaderView  *headerView;

@property (assign, nonatomic) CGFloat               itemWidth;

//@property (retain, nonatomic) ConsultationModel    *consultationModel;
@property (assign, nonatomic) Boolean               bCollector;//是否是采集者 用于显示采集界面
@property (assign, nonatomic) Boolean                bPlaying;
@property (retain, nonatomic) FriendModel           *collectorModel;//用于在头部显示采集者信息
@property (assign, nonatomic) Boolean                bLoadedView;
@property (assign ,nonatomic) MEETINGROOM_EVENT     currentEvent;

@property (retain, nonatomic) NSOperationQueue      *mainQueue;

@property (assign, nonatomic) NSInteger             recordDuration;//记录录音时长
@property (assign, nonatomic) NSInteger             recordingState;//录音状态
@property (assign, nonatomic) NSInteger             soundsType;//快速录音类型
@property (assign, nonatomic) NSInteger             recordDurationAll;// 录音总时长
@property (assign, nonatomic) NSInteger             isFiltrationRecord;//滤波状态
@property (retain, nonatomic) HHBluetoothButton     *buttonBluetooth;
@property (assign, nonatomic) NSInteger             RECORD_TYPE;//判断滤波状态
@property (assign, nonatomic) NSInteger             successCount;
@property (retain, nonatomic) NSString              *recordCode;//录音编号
@property (assign, nonatomic) Boolean               bAutoSaveRecord;//是否自动保存录音
@property (retain, nonatomic) RecordModel            *recordDataModel;
@property (retain, nonatomic) NSString              *relativePath;
@property (retain, nonatomic) NSString              *currentPositon;

@end

@implementation RemoteControlDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mainQueue = [NSOperationQueue mainQueue];
    self.title = @"远程会诊";
    self.view.backgroundColor = WHITECOLOR;
    //self.recordmodel = RecordingWithRecordDurationMaximum;
    self.collector_id = self.consultationModel.collector_id;
    [self loadPlistData:YES];
    self.bAutoSaveRecord = NO;
    //self.recordType = RemoteRecord;
    self.successCount = 0;
    self.itemWidth = (screenW-Ratio66)/5;
    [self initNavi];
    [self initData];
    [self reloadUserView];
    [self setupView];
    [self loadRecordTypeData];
    [self initMeetingRoom];
    [[HHBlueToothManager shareManager] getConnectState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
    
}

//接收蓝牙广播通知
- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    NSObject *args2 = userInfo[@"args2"];
    if (event!=12) {
        DLog(@"DEVICE_HELPER_EVENT = %li", event);
    }
    if (event == DeviceConnecting) {
        [self actionDeviceConnecting];
    } else if (event == DeviceConnected) {
        [self actionDeviceConnected];
    } else if (event == DeviceConnectFailed) {
        [self actionDeviceConnectFailed];
    } else if (event == DeviceDisconnected) {
        [self actionDeviceDisconnected];
    }
    
    
    if (event == DeviceHelperRecordReady) {
        self.recordingState = recordingState_prepare;
        DLog(@"录音就绪");
        [self actionDeviceHelperRecordReady];
    } else if (event == DeviceHelperRecordBegin) {
        self.recordingState = recordingState_ing;
        self.recordCode = [NSString stringWithFormat:@"%@%@",[Tools getCurrentTimes], [Tools getRamdomString]];
        DLog(@"录音开始: %@", self.recordCode);
        [self actionDeviceHelperRecordBegin];
    } else if (event == DeviceHelperRecordingTime) {
        //显示录音进度
        self.recordingState = recordingState_ing;
        NSNumber *result = (NSNumber *)args1;
        float number = [result floatValue];
        self.recordDuration = (int)number;
        [self actionDeviceHelperRecordingTime:number];
        DLog(@"录音进度: %f",number);

    } else if (event == DeviceHelperRecordingData) {
        [self actionDeviceHelperRecordingData:(NSData *)args1];
    } else if (event == DeviceHelperRecordPause) {
        self.recordingState = recordingState_pause;
        DLog(@"录音暂停");
        [self actionDeviceHelperRecordPause];
    }
//    else if (event == DeviceHelperRecordResume) {
//        DLog(@"录音恢复");
//        self.recordingState = recordingState_ing;
//        [self actionDeviceHelperRecordResume];
//    }
    else if (event == DeviceHelperRecordEnd) {
        DLog(@"录音结束");
        self.recordingState = recordingState_stop;
        [self actionEndRecord];
    } else if (event == DeviceHelperPlayBegin) {
        DLog(@"播放开始");
        [self actionDeviceHelperPlayBegin];
    } else if (event == DeviceHelperPlayingTime) {
//        NSNumber *number = (NSNumber *)args1;
//        float value = [number floatValue];
       // [wself actionDeviceHelperPlayingTime:value];
        //DLog(@"startTime 播放进度：%f", value);
        
    } else if (event == DeviceHelperPlayEnd) {
        DLog(@"播放结束");
        [self actionDeviceHelperPlayEnd];
        
    } else if (event == DeviceRecordPlayInstable) {
        [self actionDeviceRecordPlayInstable];
    } else if (event == DeviceRecordLostEvent) {
        [self actionDeviceRecordLostEvent];
    }
}

- (void)actionDeviceRecordLostEvent{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.view makeToast:@"无线信号弱，音频数据丢失" duration:showToastViewWarmingTime position:CSToastPositionCenter];
    }];
}

//录音结束事件处理
- (void)actionEndRecord{
    //获取录音二进制文件
    NSArray *array = [[HHBlueToothManager shareManager] getRecordFile];
   
    if (array) {
        NSInteger recordTimeLength = [array[0] integerValue];
        DLog(@"recordTimeLength = %li", recordTimeLength);
        if(!self.bAutoSaveRecord || recordTimeLength < record_time_minimum || recordTimeLength > record_time_maximum) {
           // [self actionStartRecord];
            [self actionDeviceHelperRecordEnd];
            return;
        }
        
        //获取录音文件保存路径
        NSData *data = (NSData *)array[1];
        NSString *path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
        self.relativePath = [NSString stringWithFormat:@"audio/%@.wav", self.recordCode];
        NSString *filePath = [NSString stringWithFormat:@"%@%@", path, self.relativePath];
        //DLog(@"filepath = %@", filePath);
        //将二进制文件写入目录
        Boolean success = [data writeToFile:filePath atomically:YES];
        if (success) {
            __weak typeof(self) wself = self;
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                [wself.view makeToast:@"保存成功" duration:showToastViewWarmingTime position:CSToastPositionBottom];
            }];
            
            //保存成功回调
            [self saveSuccess:recordTimeLength];
        } else {
            DLog(@"保存失败");
        }
    }
    
    
}

//保存成功后写入数据库
- (void)saveSuccess:(NSInteger)recordTimeLength{
    [[HHBlueToothManager shareManager] stop];
   // RecordModel *recordModel = [[RecordModel alloc] init];
    if(!self.recordDataModel) {
        self.recordDataModel = [[RecordModel alloc] init];
    }
    self.recordDataModel.user_id = [@(LoginData.userID) stringValue];
    self.recordDataModel.record_mode = RemoteRecord;
    self.recordDataModel.type_id = self.soundsType;
    self.recordDataModel.record_filter = self.isFiltrationRecord;
    self.recordDataModel.record_time = [Tools dateToTimeStringYMDHMS:[NSDate now]];
    self.recordDataModel.record_length = recordTimeLength;
    
    self.recordDataModel.file_path = self.relativePath;

    DLog(@"self.currentPositon = %@", self.currentPositon);
    //self.recordDataModel.position_tag =  self.currentPositon;

    self.recordDataModel.tag = [NSString stringWithFormat:@"%@.wav", self.recordCode];
    self.recordDataModel.modify_time = self.recordDataModel.record_time;
    Boolean result = [[HHDBHelper shareInstance] addRecordItem:self.recordDataModel];
    if (result) {
        DLog(@"保存数据库成功");
    } else {
        DLog(@"保存数据库失败");
    }
   
    [self actionDeviceHelperRecordEnd];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AddLocalRecordSuccess object:nil];
    self.successCount ++;
}


- (void)loadRecordTypeData{
    if (self.isFiltrationRecord == open_filtration) {
        //判断音类型
        if (self.soundsType == heart_sounds) {//---------
            self.RECORD_TYPE = RECORD_HEART_WITH_BUTTON;
        } else {
            self.RECORD_TYPE = RECORD_LUNG_WITH_BUTTON;
        }
    } else if (self.isFiltrationRecord == close_filtration) {
        self.RECORD_TYPE = RECORD_FULL_WITH_BUTTON;
    }
}
//点击蓝牙按钮到蓝牙配置界面
- (void)actionClickBlueToothCallBack:(UIButton *)button{
    if(self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
        __weak typeof(self) wself = self;
        [Tools showAlertView:nil andMessage:@"正在录音，确认要进入蓝牙设置吗？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
            [wself actionToDeviceManagerVC];
        } cancel:^{
            
        }];
    } else {
        [self actionToDeviceManagerVC];
    }
}

- (void)actionToDeviceManagerVC{
    DeviceManagerVC *deviceManager = [[DeviceManagerVC alloc] init];
    deviceManager.recordingState = self.recordingState;
    deviceManager.bStandart = NO;
    [self.navigationController pushViewController:deviceManager animated:YES];
}


- (void)initNavi{
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.buttonBluetooth];
    item1.width = Ratio22;
    self.navigationItem.rightBarButtonItems = @[item1];
}


//读取本地配置文件
- (void)loadPlistData:(Boolean)firstLoadData{
    NSString *path = [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    self.recordDurationAll = [data[@"remote_record_duration"] integerValue];// 录音总时长
    
    if (firstLoadData) {
        self.soundsType = [data[@"quick_record_default_type"] integerValue];//快速录音类型
        self.isFiltrationRecord = [data[@"is_filtration_record"] integerValue];//滤波状态
    }
}

- (void)realodFilerView{
    if (self.isFiltrationRecord == open_filtration) {
        [self.headerView.heartFilterLungView filterGrayString:@"关闭滤波" blueString:@"打开滤波/"];
    } else if (self.isFiltrationRecord == close_filtration) {
        [self.headerView.heartFilterLungView filterGrayString:@"打开滤波" blueString:@"/关闭滤波"];
    }
}

- (void)actionDeviceConnecting{
    [self showHeaderViewRecordMessage:@"设备正在连接"];
}

- (void)actionDeviceConnected{
    if (LoginData.userID == self.collector_id) {
        if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
            [self showHeaderViewRecordMessage:@"当前连接的设备不是听诊器"];
        } else {
            if (self.bDataServiceReady){
                [self actionStartRecord];
            } else {
                [self showHeaderViewRecordMessage:@""];
            }
        }
    } else {
        if (self.bDataServiceRecording) {
            [self actionStartPlay];
        } else {
            [self showHeaderViewRecordMessage:@""];
        }
    }
}

//开始录音
- (void)actionStartRecord{
    if (self.recordingState != recordingState_ing) {
        [[HHBlueToothManager shareManager] startRecord:self.RECORD_TYPE record_mode:RecordingWithRecordDurationMaximum];
    }
}

- (void)actionDeviceDisconnected{
    [self showHeaderViewRecordMessage:@"设备已断开"];
    [self actionStop];
}

- (void)actionStop {
    [[HHBlueToothManager shareManager] stop];
}

- (void)actionDeviceConnectFailed {
    [self showHeaderViewRecordMessage:@"设备连接失败"];
}

- (void)actionDeviceHelperRecordReady{
    [self showHeaderViewRecordMessage:@"按听诊器录音键可开始录音"];
}

- (void)actionDeviceHelperRecordBegin{
    //self.headerView.recordMessage = @"";
    [self.meetingRoom SendCommand:1 data:nil];
}

- (void)actionDeviceHelperRecordingData:(NSData *)data{
    [self.meetingRoom SendWavFrame:0 wav_frame:data];
}

- (void)actionDeviceHelperRecordPause{
    //self.headerView.recordMessage = @"录音暂停,按听诊器键重新开始录音";
}

- (void)actionDeviceHelperRecordEnd{
    if(self.bDataServiceReady) {
        [self.meetingRoom SendCommand:0 data:NULL];
        [self actionStartRecord];
    }
    
    [self showHeaderViewRecordMessage:@""];
}

- (void)actionDeviceHelperPlayBegin{
    [self showHeaderViewRecordMessage:@"正在听诊"];
}

- (void)actionDeviceHelperPlayEnd{
    [self showHeaderViewRecordMessage:@""];
}

- (void)actionDeviceRecordPlayInstable{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.view makeToast:@"无线数据传输不稳定" duration:showToastViewWarmingTime position:CSToastPositionCenter];
    }];
    
}

- (void)actionDeviceHelperRecordingTime:(float)number{
    NSInteger second = self.recordDurationAll - number;
    NSString *secondLeft = [Tools getMMSSFromSS:second];
    NSString *message = [NSString stringWithFormat:@"正在录音%@,按录音键停止", secondLeft];
    [self showHeaderViewRecordMessage:message];
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    
    if (self.consultationModel.creator_id == LoginData.userID) {
        //[self.meetingRoom SendCommand:0 data:nil];
       // [[HHBlueToothManager shareManager] stop];
        [Tools showWithStatus:@"正在更换采集人"];
        [self actionStop];
        FriendModel *model = self.arrayData[self.currentIndexPath.row];
        if (model.userId != self.collector_id) {
            [self.meetingRoom SetCollector:(int)model.userId];
        }
        
    }
}


- (void)actionConsultationButtonClick:(Boolean)start{
    
    if (self.bDataServiceReady) {
        [Tools showWithStatus:@"正在暂停"];
        self.bDataServiceReady = NO;
        [self actionStop];
        [self showHeaderViewButtonSelected:NO];
        [self.meetingRoom StopAuscultation];
    } else {
        [self actionStop];
        if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTING) {
            [self.view makeToast:@"设备连接中，请稍后" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        } else if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_NOT_CONNECT) {
            [self.view makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        } else if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
            [self.view makeToast:@"您连接的设备不是听诊器" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        } else if ([[Constant shareManager] getNetwordStatus] == NotReachable) {
            [self.view makeToast:@"连接服务器失败，请检测你的手机网络是否已打开！" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        } else {
            [self.meetingRoom StartAuscultation];
        }
    }
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
    if (self.collector_id == LoginData.userID && self.bDataServiceReady) {
        [self actionStartRecord];
    }
    
    return YES;
}




- (void)initMeetingRoom{
    self.meetingRoom = [[MeetingRoom alloc] init];
    self.meetingRoom.delegate = self;
}

- (void)actionEnterRoom{
    [self.meetingRoom Enter:LoginData.token meetingroom_url:self.consultationModel.server_url meetingroom_id:(int)self.consultationModel.meetingroom_id];
    [self showHeaderViewTitleMessage:@"正在进入会诊"];
}


- (void)reloadUserView{
    [self.collectionView reloadData];
}


- (void)actionMeetingInfoUpdate:(MeetingRoomInfo *)roomInfo{
    if (self.collector_id != 0) {
        
        if (self.collector_id == LoginData.userID) {//自己是采集者 显示采集界面
            NSInteger newCollectId = roomInfo.collector_id;
            if (newCollectId != LoginData.userID) {
                [self actionStop];
            }
        }
    }
    
    self.collector_id = roomInfo.collector_id;
    if (self.collector_id == LoginData.userID) {//自己是采集者 显示采集界面
        self.bCollector = YES;
    } else {
        [self showHeaderViewRecordMessage:@""];
        self.bCollector = NO;
        self.bDataServiceRecording = NO;
       
    }
    [self showHeaderViewButtonSelected:NO];
    self.bDataServiceReady = NO;
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself refreshArrayData];
        [wself.collectionView reloadData];
        wself.headerView.titleMessage = @"进入会诊成功";
    }];
}

- (void)actionMeetingMemberUpdate:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    MemberList *memberList = (MemberList *)args3;
    for (Member *member in memberList.members) {
        if (member.user_id == self.collectorModel.userId) {
            self.collectorModel.bOnLine = YES;
        }
        for (FriendModel *friendModel in self.arrayData) {
            if (member.user_id == friendModel.userId) {
                friendModel.bOnLine = YES;
            }
        }
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself reloadCollectViewAfterMeetingMemberUpdate:args1 args2:args2];
    }];
    
}

- (void)reloadCollectViewAfterMeetingMemberUpdate:(NSObject *)args1 args2:(NSObject *)args2{
    NSString *sargs1 = [NSString stringWithFormat:@"%@", args1];
    NSInteger onlineState = [sargs1 integerValue];
    if (args2) {
        Member *member = (Member *)args2;
        
        if (member.user_id == self.collectorModel.userId) {
            self.collectorModel.bOnLine = (onlineState == -1) ? NO : YES;
            
        }
        for (FriendModel *friendModel in self.arrayData) {
            if (member.user_id == friendModel.userId) {
                friendModel.bOnLine = (onlineState == -1) ? NO : YES;
                break;;
            }
        }
    }
    
    [self.collectionView reloadData];
}

- (void)actionMeetingStartAuscultationControlResult:(int)args{
    if (args == 1) {
        [self showHeaderViewTitleMessage:@"会诊开始"];
    } else {
        [self showHeaderViewTitleMessage:@"开始会诊操作失败"];
    }
}



- (void)actionMeetingStopAuscultationControlResult:(int)args{
    if (args == 1) {
        [self showHeaderViewTitleMessage:@"会诊已暂停"];
    } else {
        [self showHeaderViewTitleMessage:@"暂停会诊操作失败"];
    }
}

- (void)actionMeetingDataServiceWavFrameReceived:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    NSString *sargs1 = [NSString stringWithFormat:@"%@", args1];
    int flag = [sargs1 intValue];
    self.soundsType = flag;
    [self loadRecordTypeData];
    NSData *data = (NSData *)args2;
    if ([[HHBlueToothManager shareManager] isPlaying]) {
        [[HHBlueToothManager shareManager] writePlayBuffer:data];
    }
    if(self.collector_id != LoginData.userID) {
        if (!self.bDataServiceRecording) {
            self.bDataServiceRecording = YES;
            [self actionStartPlay];
        }
    }
    
}

- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel{
    if (self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    self.isFiltrationRecord = filterModel;
    [self loadRecordTypeData];
    if(self.collector_id == LoginData.userID && self.bDataServiceReady) {
        [self actionStartRecord];
    }
    //
    return YES;
}

- (void)actionStartPlay {
    [[HHBlueToothManager shareManager] startPlay:PlayingWithRealtimeData];
}



- (void)actionMeetingDataServiceCmdReceived:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    if (self.collector_id != LoginData.userID) {//自己不是采集者
        NSString *sargs1 = [NSString stringWithFormat:@"%@", args1];
        int cmd = [sargs1 intValue];
        if (cmd == 1) {
            if (!self.bDataServiceRecording) {
                self.bDataServiceRecording = YES;
                [self actionStartPlay];
            }
        } else {
            if (self.bDataServiceRecording) {
                self.bDataServiceRecording = NO;
                [self actionStop];
            }
        }
    }
}

- (void)showHeaderViewRecordMessage:(NSString *)message{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.headerView.recordMessage = message;
    }];
}

- (void)actionMeetingDataServiceClientInfoReceived:(Clients *)clients{
    for (FriendModel *friendModel in self.arrayData) {
        for (NSNumber *number in clients.members) {
            if ([number intValue] == friendModel.userId) {
                friendModel.bCollect = YES;
                break;
            } else {
                friendModel.bCollect = NO;
            }
        }
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.collectionView reloadData];
    }];
    
}


- (void)showHeaderViewTitleMessage:(NSString *)message{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.headerView.titleMessage = message;
    }];
    
}

- (void)showHeaderViewButtonSelected:(Boolean)bSelected{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.headerView.bButtonSelected = bSelected;
    }];
}


- (void)on_meetingroom_event:(MEETINGROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    //self.currentEvent = event;
    if(event != 16) {
        DLog(@"MEETINGROOM_EVENT = %li", event);
    }
    
    
    if (event == MeetingEntering) {
        DLog(@"正在进入会诊");
    } else if (event == MeetingEnterSuccess) {
        DLog(@"进入会议会诊");
        [self showHeaderViewTitleMessage:@"进入会诊成功"];
    } else if (event == MeetingEnterFailed) {
        DLog(@"进入会诊失败");
        [self showHeaderViewTitleMessage:@"进入会诊失败"];
        self.bMeetingRoomEnter = NO;
    } else if (event == MeetingExited) {
        DLog(@"连接断开");
        
        if (self.bMeetingRoomEnter) {
            [self showHeaderViewTitleMessage:@"会诊已断开，正在重连"];
            __weak typeof(self) wself = self;
            [self.mainQueue addOperationWithBlock:^{
                [wself performSelector:@selector(delayedMethod) withObject:nil afterDelay:1.0];
            }];
            
            
        } else {
            [self showHeaderViewTitleMessage:@"会诊已断开"];
        }
    } else if (event == MeetingInfoUpdate) {
        MeetingRoomInfo *roomInfo = (MeetingRoomInfo *)args1;
        DLog(@"会议主题:%@, 采集人ID：%i", roomInfo.title, roomInfo.collector_id);
        [self actionMeetingInfoUpdate:roomInfo];
    } else if (event == MeetingMemberUpdate) {
        [self actionMeetingMemberUpdate:args1 args2:args2 args3:args3];
    } else if (event == MeetingStartAuscultationControlResult) {
        NSString *sargs1 = (NSString *)args1;
        int result = [sargs1 intValue];
        DLog(@"录音开始：%@", result == 1 ? @"成功" : @"失败");
        [self actionMeetingStartAuscultationControlResult:result];
    } else if (event == MeetingStopAuscultationControlResult) {
        NSString *sargs1 = (NSString *)args1;
        int result = [sargs1 intValue];
        DLog(@"录音结束：%@", result == 1 ? @"成功" : @"失败");
        [self actionMeetingStopAuscultationControlResult:result];
    } else if (event == MeetingSetCollectorControlResult) {
        NSString *sargs1 = (NSString *)args1;
        int result = [sargs1 intValue];
        DLog(@"设置采集人：%@", result == 1 ? @"成功" : @"失败");
        if (result == 0) {
            __weak typeof(self) wself = self;
            [self.mainQueue addOperationWithBlock:^{
                [wself.view makeToast:@"操作失败" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            }];
        }
    } else if (event == MeetingModifyMeetingControlResult) {
        NSString *sargs1 = (NSString *)args1;
        int result = [sargs1 intValue];
        DLog(@"修改参会人：%@", result == 1 ? @"成功" : @"失败");
        if (result == 0) {
            __weak typeof(self) wself = self;
            [self.mainQueue addOperationWithBlock:^{
                [wself.view makeToast:@"操作失败" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            }];
            
        }
    } else if (event == MeetingStartAuscultation) {
        DLog(@"听诊开始");
        [self showHeaderViewTitleMessage:@"会诊开始"];
    } else if (event == MeetingStopAuscultation) {//学生收到这个信号
        DLog(@"听诊结束");
        [self showHeaderViewTitleMessage:@"会诊已暂停"];
    } else if (event == MeetingDataServiceConnecting) {
        [self showHeaderViewTitleMessage:@"远程听诊服务器连接中"];
    } else if (event == MeetingDataServiceConnectSuccess) {
        [self showHeaderViewTitleMessage:@"远程会诊进行中"];
        [self showHeaderViewButtonSelected:YES];//
        self.bDataServiceReady = YES;
        if (self.collector_id == LoginData.userID) {
            //[self.meetingRoom SendCommand:1 data:NULL];
            [self actionStartRecord];
            //self.bDataServiceRecording = YES;
            
        }
    } else if (event == MeetingDataServiceConnectFailed) {
        self.bDataServiceReady = NO;
        //self.bDataServiceRecording = NO;
        [self showHeaderViewButtonSelected:NO];
        //self.headerView.bStartRecord = NO;
       
        [self showHeaderViewTitleMessage:@"远程会诊服务器连接失败"];
    } else if (event == MeetingDataServiceDisconnected) {
//        DLog(@"远程听诊服务器连接断开");
        
        self.bDataServiceReady = NO;
        [self showHeaderViewButtonSelected:NO];
        self.bDataServiceRecording = NO;
        [self showHeaderViewTitleMessage:@"远程会诊服务器连接断开"];
        [self showHeaderViewRecordMessage:@""];
        [self actionStop];
    } else if (event == MeetingDataServiceWavFrameReceived) {
        [self actionMeetingDataServiceWavFrameReceived:args1 args2:args2 args3:args3];
    } else if (event == MeetingDataServiceCmdReceived) {
        [self actionMeetingDataServiceCmdReceived:args1 args2:args2 args3:args3];
        
    } else if (event == MeetingDataServiceClientInfoReceived) {
        Clients *clients = (Clients *)args3;
        [self actionMeetingDataServiceClientInfoReceived:clients];
    }
    [self.mainQueue addOperationWithBlock:^{
        [Tools hiddenWithStatus];
    }];
}

- (void)delayedMethod{
    if (self.bMeetingRoomEnter) {
        [self actionEnterRoom];//重新连接
    }
    
}

- (void)refreshArrayData{
    NSInteger i =0 ;
    for (FriendModel *model in self.arrayData) {
        if(model.userId == self.collector_id) {
            // FriendModel *cModel = [self.collectorModel copy];
            
            [self.arrayData replaceObjectAtIndex:i withObject:self.collectorModel];
            self.collectorModel = model;
            [self.collectionView reloadData];
            return;
        }
        i++;
    }
}


- (void)initData{
    self.arrayData = [NSMutableArray array];
    for (FriendModel *model in self.consultationModel.members) {
        if(model.userId != self.collector_id) {
            [self.arrayData addObject:model];
        } else {
            self.collectorModel = model;
        }
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"meetingroom_id"] = [@(self.consultationModel.meetingroom_id) stringValue];
    __weak typeof(self) wself = self;
    [TTRequestManager meetingGetMeetingroom:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            wself.consultationModel = [ConsultationModel yy_modelWithJSON:responseObject[@"data"]];
            wself.headerView.consultationModel = wself.consultationModel;
            
            [wself actionEnterRoom];
        }
    } failure:^(NSError * _Nonnull error) {
    }];
}



- (void)setupView{
    [self.view addSubview:self.collectionView];
    self.collectionView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, kBottomSafeHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CreateConsultationCell *cell = (CreateConsultationCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CreateConsultationCell class]) forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    cell.model = self.arrayData[row];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, Ratio11, 0, Ratio11);
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        self.headerView = (RemoteControlDetailHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([RemoteControlDetailHeaderView class]) forIndexPath:indexPath];
        __weak typeof(self) wself = self;
        self.headerView.syncSaveBlock = ^(Boolean bSyncSave) {
            wself.bAutoSaveRecord = bSyncSave;
        };
        self.headerView.consultationModel = self.consultationModel;
        self.headerView.bCollector = self.bCollector;
        self.headerView.userModel = self.collectorModel;
        self.headerView.delegate = self;
        reusableview = self.headerView;
        [self realodFilerView];
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (self.bCollector) {
        return  CGSizeMake(screenW, 455.f*screenRatio);
    } else {
        return  CGSizeMake(screenW, 355.f*screenRatio);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if(self.bLoadedView) {
       
        //[self realodFilerView];
    }
    if(self.recordingState == recordingState_ing || self.recordingState == recordingState_prepare) {
        [self actionStartRecord];
    }
    [self loadPlistData:NO];
    [self loadRecordTypeData];
    self.bLoadedView = YES;
    
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *fallsLayout = [[UICollectionViewFlowLayout alloc] init];
        fallsLayout.estimatedItemSize = CGSizeMake(self.itemWidth , self.itemWidth + Ratio15);
        fallsLayout.minimumInteritemSpacing = Ratio11;
        [fallsLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        fallsLayout.headerReferenceSize = CGSizeMake(screenW, 355.f*screenRatio);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fallsLayout];
        _collectionView.backgroundColor = WHITECOLOR;
        [_collectionView registerClass:[CreateConsultationCell class] forCellWithReuseIdentifier:NSStringFromClass([CreateConsultationCell class])];
        
        [_collectionView registerClass:[RemoteControlDetailHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([RemoteControlDetailHeaderView class])];
        
        //collectionView的item只剩下一个时自动左对齐
        SEL sel = NSSelectorFromString(@"_setRowAlignmentsOptions:");
        if ([_collectionView.collectionViewLayout respondsToSelector:sel]) {
            ((void(*)(id,SEL,NSDictionary*)) objc_msgSend)(_collectionView.collectionViewLayout, sel, @{@"UIFlowLayoutCommonRowHorizontalAlignmentKey":@(NSTextAlignmentLeft),@"UIFlowLayoutLastRowHorizontalAlignmentKey" : @(NSTextAlignmentLeft), @"UIFlowLayoutRowVerticalAlignmentKey" : @(NSTextAlignmentCenter)});
        }
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]  initWithTarget:self action:@selector(handleLongPress:)];
        //lpgr.delegate = self;
        lpgr.delaysTouchesBegan = YES;
        [_collectionView addGestureRecognizer:lpgr];
    }
    return _collectionView;
}



-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        DLog(@"couldn't find index path");
    } else {
        if (self.consultationModel.creator_id == LoginData.userID) {
            self.currentIndexPath = indexPath;
            
            TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[@"设置为采集人"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
            actionSheet.delegate = self;
            [actionSheet showInView:kAppWindow];
        }
    }
}

- (Boolean)checkConnetState{
    CONNECT_STATE state = [[HHBlueToothManager shareManager] getConnectState];
    if (state == DEVICE_CONNECTING) {
        [self.view makeToast:@"设备连接中，请稍后" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    } else if (state == DEVICE_NOT_CONNECT) {
        [self.view makeToast:@"请先连接设备" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    } else if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self.view makeToast:@"您连接的设备不是听诊器" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    return YES;
}


- (BOOL)shouldHoldBackButtonEvent {
    return YES;
}

- (BOOL)canPopViewController {
    // 这里不要做一些费时的操作，否则可能会卡顿。
    __weak typeof(self) wself = self;
    [Tools showAlertView:nil andMessage:@"是否临时退出临床教学？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
        [wself.navigationController popViewControllerAnimated:YES];
    } cancel:^{
        
    }];
    return NO;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[HHBlueToothManager shareManager] stop];
    self.recordingState = recordingState_stop;
    [self.meetingRoom Exit];
}

- (HHBluetoothButton *)buttonBluetooth{
    if(!_buttonBluetooth) {
        _buttonBluetooth  = [[HHBluetoothButton alloc] init];
        _buttonBluetooth.bluetoothButtonDelegate = self;
        //_buttonBluetooth.imageEdgeInsets = UIEdgeInsetsMake(-Ratio5, -Ratio5, -Ratio5, -Ratio5);
    }
    return _buttonBluetooth;
}

@end
