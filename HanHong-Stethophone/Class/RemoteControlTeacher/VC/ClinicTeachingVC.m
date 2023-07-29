//
//  ClinicVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/25.
//

#import "ClinicTeachingVC.h"
#import "ClinicTeachingHeaderView.h"
#import "ClinicCell.h"
#import "UINavigationController+QMUI.h"
#import "UIViewController+HBD.h"
#import "ClassRoom.h"
#import "MemberItemModel.h"
#import "UIButton+WXD.h"
#import "DeviceManagerVC.h"

@interface ClinicTeachingVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerBackButtonHandlerProtocol, ClassRoomDelegate, ClinicTeachingHeaderDelegate, HHBluetoothButtonDelegate>

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
@property (retain, nonatomic) NSOperationQueue              *mainQueue;

@property (assign, nonatomic) Boolean               bAutoSaveRecord;//是否自动保存录音
@property (assign, nonatomic) NSInteger             recordingState;//录音状态
@property (assign, nonatomic) NSInteger             soundsType;//快速录音类型
@property (assign, nonatomic) NSInteger             isFiltrationRecord;//滤波状态
@property (retain, nonatomic) HHBluetoothButton     *buttonBluetooth;
@property (assign, nonatomic) NSInteger             RECORD_TYPE;//判断滤波状态
@property (assign, nonatomic) NSInteger             recordDurationAll;// 录音总时长
@property (retain, nonatomic) NSString              *recordCode;//录音编号
@property (assign, nonatomic) NSInteger             recordDuration;//记录已经录制录音时长
@property (retain, nonatomic) NSString              *relativePath;
@property (retain, nonatomic) RecordModel            *recordDataModel;

@end

@implementation ClinicTeachingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"临床教学";
    self.mainQueue = [NSOperationQueue mainQueue];
    self.arrayData = [NSMutableArray array];
    //self.recordmodel = RecordingWithRecordDurationMaximum;
    //self.recordType = RemoteRecord;
    self.bAutoSaveRecord = NO;
    self.itemWidth = (screenW-Ratio66)/5;
    [self initNavi];
    [self setupView];
    self.view.backgroundColor = WHITECOLOR;
    [self loadPlistData:YES];
    [self loadRecordTypeData];
    
    [self getTeachingClassroom];
    [self initClassRoom];
    [self actionConfigRecordDuration];
    
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
    } else if (event == DeviceHelperRecordResume) {
        DLog(@"录音恢复");
        self.recordingState = recordingState_ing;
        //[self actionDeviceHelperRecordResume];
    } else if (event == DeviceHelperRecordEnd) {
        DLog(@"录音结束");
        self.recordingState = recordingState_stop;
        [self actionEndRecord];
    }  else if (event == DeviceRecordPlayInstable) {
        [self actionDeviceRecordPlayInstable];
    } else if (event == DeviceRecordLostEvent) {
        [self actionDeviceRecordLostEvent];
    }
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

- (void)realodFilerView{
    if (self.isFiltrationRecord == open_filtration) {
        [self.headerView.heartFilterLungView filterGrayString:@"关闭滤波" blueString:@"打开滤波/"];
    } else if (self.isFiltrationRecord == close_filtration) {
        [self.headerView.heartFilterLungView filterGrayString:@"打开滤波" blueString:@"/关闭滤波"];
    }
}

- (void)actionConfigRecordDuration{
    [[HHBlueToothManager shareManager] setRecordDuration:(int)self.recordDurationAll];//设置录音时长
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
            __weak typeof(self) wself = self;
            [Tools showAlertView:nil andMessage:@"是否确定结束本次临床教学？" andTitles:@[@"取消", @"确定"] andColors:@[MainGray, MainColor] sure:^{
                [wself.classRoom ClassEnd];
                wself.bDataServiceReady = NO;
               // self.
                if (wself.historyListBlock) {
                    wself.historyListBlock();
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
        [self actionShowRoomMessage:@"教室已断开，正在重连"];
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            [wself performSelector:@selector(actionRoomReconnect) withObject:nil afterDelay:1.f];
        }];
        
        
    } else {
        [self actionShowRoomMessage:@"教室已断开"];
    }
    //[self.view makeToast:@"教室已断开" duration:showToastViewWarmingTime position:CSToastPositionCenter];
}

- (void)actionRoomReconnect{
    [self actionEnterRoom];
}

- (void)actionClassInfoUpdate:(NSObject *)args1{
    self.classRoomInfo = (ClassRoomInfo *)args1;
    DLog(@"self.historyModel.class_state = %li, self.classroomState = %li", (long)self.historyModel.class_state, (long)self.classroomState);
    if (self.classroomState != self.classRoomInfo.class_state) {
        self.classroomState = self.classRoomInfo.class_state;
        if (self.classroomState == 1) {
            [self.classRoom StartAuscultation];
        } else if(self.historyModel.class_state == 2) {
            [self.classRoom StopAuscultation];
        }
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        wself.historyModel.class_state = wself.classroomState;
        wself.headerView.classroomState = wself.classroomState;
        
        if (wself.classroomState == 1) {
            if ([[HHBlueToothManager shareManager] getConnectState] != DEVICE_CONNECTED) {
                wself.headerView.recordMessage = @"请连接设备";
            } else if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
                wself.headerView.recordMessage = @"当前连接的设备不是听诊器";
            }
        } else if (wself.classroomState == 2) {
            [wself.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}

- (void)actionClassMemberUpdate:(NSObject *)args3{
    MemberList *memberList = (MemberList *)args3;
    DLog(@"教室状态:当前教室在线人数：%i", memberList.count);
    for (Member *member in memberList.members) {
        int user_id = member.user_id;
        if (user_id == LoginData.userID) {
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
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.collectionView reloadData];
    }];
    
}

- (void)actionClassStartAuscultationControlResult:(NSObject *)args1{
    NSString *sarg1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sarg1 boolValue];
    DLog(@"录音开始：%@", success ? @"成功" : @"失败");
    if (success) {
        [self actionShowRoomMessage:@"临床教学开始"];
    } else {
        [self actionShowRoomMessage:@"开始临床教学操作失败"];
    }
}

- (void)actionClassStopAuscultationControlResult:(NSObject *)args1{
    NSString *sarg1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sarg1 boolValue];
    DLog(@"录音结束：%@", success ? @"成功" : @"失败");
    if (success) {
        [self actionShowRoomMessage:@"临床教学已暂停"];
    } else {
        [self actionShowRoomMessage:@"暂停临床教学操作失败"];
    }
}

- (void)actionClassBeginControlResult:(NSObject *)args1{
    NSString *sarg1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sarg1 boolValue];
    DLog(@"课堂开始：%@", success ? @"成功" : @"失败");
    if (!success) {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            [wself.view makeToast:@"操作失败" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }];
        
    }
}

- (void)actionClassEndControlResult:(NSObject *)args1{
    NSString *sarg1 = [NSString stringWithFormat:@"%@", args1];
    Boolean success = [sarg1 boolValue];
    DLog(@"课堂结束：%@", success ? @"成功" : @"失败");
    if (!success) {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            [wself.view makeToast:@"操作失败" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        }];
    }
}

- (void)actionClassDataServiceConnectSuccess{
    [self actionShowRoomMessage:@"临床教学进行中"];
    self.bDataServiceReady = YES;
    [self actionStartRecord];
//    if ([[HHBlueToothManager shareManager] getConnectState] == DEVICE_CONNECTED == [[HHBlueToothManager shareManager] getDeviceType] == STETHOSCOPE) {
//        [self.classRoom SendCommand:1 data:NULL];
//        [self actionStartRecord];
//        self.bDataServiceReady = YES;
//    } else {
//        self.bDataServiceReady = NO;
//    }
    //self.headerView.roomMessage = @"临床教学进行中";
    //self.headerView.recordMessage = @"按听诊器录音键可开始录音";
    
}

//开始录音
- (void)actionStartRecord{
    if (self.recordingState != recordingState_ing) {
        [[HHBlueToothManager shareManager] startRecord:self.RECORD_TYPE record_mode:RecordingWithRecordDurationMaximum];
    }
}

- (void)actionClassDataServiceClientInfoReceived:(NSObject *)args3{
    Clients *clients = (Clients *)args3;
    DLog(@"当前教室联通人数：%i", clients.count);
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
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.collectionView reloadData];
    }];
    
}

- (void)actionDeviceConnecting{
    [self actionShowRecordMessage:@"设备正连接"];
}

- (void)actionDeviceConnected{
    if ([[HHBlueToothManager shareManager] getDeviceType] != STETHOSCOPE) {
        [self actionShowRecordMessage:@"当前连接的设备不是听诊器"];
    } else {
        if (self.bDataServiceReady) {
            [self actionStartRecord];
        } else {
            [self actionShowRecordMessage:@""];
        }
    }
}

- (void)actionStop {
    [[HHBlueToothManager shareManager] stop];
}

- (void)actionDeviceDisconnected{
    [self actionShowRecordMessage:@"设备已断开"];
    [self actionStop];
}

- (void)actionDeviceHelperRecordReady{
    [self actionShowRecordMessage:@"按听诊器录音键可开始录音"];
}

- (void)actionDeviceHelperRecordBegin{
    [self.classRoom SendCommand:1 data:nil];
}

- (void)actionDeviceConnectFailed{
    [self actionShowRecordMessage:@"设备连接失败"];
}

- (void)actionDeviceHelperRecordEnd{
    
    //self.headerView.recordMessage = @"录音完成,按听诊器键重新开始录音";
    //if(self.bDataServiceReady) {
    [self.classRoom SendCommand:0 data:NULL];
    [self actionStartRecord];
    ///}

    [self.classRoom TeachingCount];
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.view makeToast:@"录音结束" duration:showToastViewWarmingTime position:CSToastPositionBottom];
    }];
}

- (void)actionDeviceRecordLostEvent{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.view makeToast:@"无线数据传输不稳定" duration:showToastViewWarmingTime position:CSToastPositionCenter];
    }];
}

- (void)actionDeviceRecordPlayInstable{
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.view makeToast:@"无线信号弱，音频数据丢失" duration:showToastViewWarmingTime position:CSToastPositionCenter];
    }];
}

- (void)actionDeviceHelperRecordingData:(NSObject *)args1{
    NSData *data = (NSData *)args1;
    [self.classRoom SendWavFrame:0 wav_frame:data];
}

- (void)actionShowRecordMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        self.headerView.recordMessage = message;
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            wself.headerView.recordMessage = message;
        }];
    }
}

- (void)actionShowRoomMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        self.headerView.roomMessage = message;
    } else {
        __weak typeof(self) wself = self;
        [self.mainQueue addOperationWithBlock:^{
            wself.headerView.roomMessage = message;
        }];
    }
}

- (void)actionClassDataServiceDisconnected{
    [self actionShowRoomMessage:@"临床教学服务器断开"];
    self.bDataServiceReady = NO;
    [self actionStop];
    [self actionShowRecordMessage:@""];
    for (MemberItemModel *itemModel in self.arrayData) {
        itemModel.bConnect = NO;
    }
    __weak typeof(self) wself = self;
    [self.mainQueue addOperationWithBlock:^{
        [wself.collectionView reloadData];
    }];
}


- (void)on_classroom_event:(CLASSROOM_EVENT)event args1:(NSObject *)args1 args2:(NSObject *)args2 args3:(NSObject *)args3{
    //DLog(@"event = %@, args1 = %@ , args2 = %@, args3 = %@", [@(event) stringValue], args1, args2, args3);
    if (event == ClassEntering) {
        DLog(@"正在进入教室");
    } else if (event == ClassEnterSuccess) {
        [self actionShowRoomMessage:@"进入教室成功"];
        if (self.historyModel.class_state == 1) {
            [self.classRoom StartAuscultation];
        }
    } else if (event == ClassEnterFailed) {
        [self actionShowRoomMessage:@"进入教室失败"];
        self.bClassroomEnter = NO;
    } else if (event == ClassExited) {
        [self actionClassExited];
    } else if (event == ClassInfoUpdate) {
        [self actionClassInfoUpdate:args1];
        DLog(@"教室状态:%i", self.classRoomInfo.class_state);
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
        DLog(@"听诊开始");//学生收到这个信号
        [self actionShowRoomMessage:@"临床教学开始"];
    } else if (event == ClassStopAuscultation) {
        DLog(@"听诊结束");//学生收到这个信号
        if (self.classroomState == 2) {
            [self actionShowRoomMessage:@"临床教学已结束"];
        } else {
            [self actionShowRoomMessage:@"临床教学已暂停"];
        }
    } else if (event == ClassDataServiceConnecting) {
        DLog(@"远程听诊连接中");
        [self actionShowRoomMessage:@"临床教学服务器连接中"];
    } else if (event == ClassDataServiceDisconnected) {
        [self actionClassDataServiceDisconnected];
    } else if (event == ClassDataServiceConnectFailed) {
       
        [self actionShowRoomMessage:@"临床教学服务器连接失败"];
    } else if (event == ClassDataServiceConnectSuccess) {
        DLog(@"远程听诊连接成功");
        [self actionClassDataServiceConnectSuccess];
    } else if (event == ClassDataServiceClientInfoReceived) {
        [self actionClassDataServiceClientInfoReceived:args3];
    } else if (event == ClassDataServiceWavFrameReceived) {
        DLog(@"远程听诊 ClassDataServiceWavFrameReceived--");
    } else if (event == ClassDataServiceCmdReceived) {
        DLog(@"远程听诊 ClassDataServiceCmdReceived");
    }
}



- (void)actionDeviceHelperRecordingTime:(float)number{
    NSInteger second = self.recordDurationAll - number;
    NSString *secondLeft = [Tools getMMSSFromSS:second];
    NSString *message = [NSString stringWithFormat:@"正在录音%@,按录音键停止", secondLeft];
    [self actionShowRecordMessage:message];

}

- (void)actionDeviceHelperRecordPause{
    [self actionShowRecordMessage:@"录音暂停,按听诊器键重新开始录音"];
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
            DLog(@"data = %li", data.count);
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
        [self realodFilerView];
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

- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel{
    if (self.recordingState == recordingState_ing || self.recordingState == recordingState_pause) {
        [self.view makeToast:@"录音过程中，不可以改变录音模式" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    self.isFiltrationRecord = filterModel;
    [self loadRecordTypeData];
    if (self.bDataServiceReady) {
        [self actionStartRecord];
    }
    
    return YES;
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
    if (self.bDataServiceReady) {
        //[self.classRoom SendCommand:1 data:NULL];
        [self actionStartRecord];
        
    } else {
    }
    
    return YES;
}

- (HHBluetoothButton *)buttonBluetooth{
    if(!_buttonBluetooth) {
        _buttonBluetooth  = [[HHBluetoothButton alloc] init];
        _buttonBluetooth.bluetoothButtonDelegate = self;
    }
    return _buttonBluetooth;
}


@end
