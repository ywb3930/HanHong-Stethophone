//
//  RecordListVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "RecordListVC.h"
#import "TTPopView.h"
#import "LRTextField.h"
#import "AnnotationVC.h"
#import "TTActionSheet.h"
#import "WXApi.h"

@interface RecordListVC ()<TTPopViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, TTActionSheetDelegate, RecordListCellDelegate, UITextFieldDelegate>

@property (retain, nonatomic) UIButton              *selectButton;//选择按钮
@property (retain, nonatomic) TTPopView             *popView;//选择按钮时弹出的页面
@property (retain, nonatomic) NSArray               *listInfo;//选择按钮时弹出的页面的数据
@property (retain, nonatomic) LRTextField           *textField;//搜索输入框
@property (retain, nonatomic) UITableView           *recordTableView;//列表
@property (retain, nonatomic) NSMutableArray        *arrayData;//列表展示数据
@property (assign, nonatomic) NSInteger             selectMode;//选择按钮时弹出的页面选择的列数从0开始
@property (retain, nonatomic) NSIndexPath           *currentSelectIndexPath;//当前选择的cell
@property (assign, nonatomic) NSInteger             currentPlayingRow;//正在播放的列数 用于处理点击播放按钮事件


@property (retain, nonatomic) NSString              *path; //本地文件保存目录
@property (retain, nonatomic) NSMutableArray        *allData;//所有数据，用于筛选是使用

@property (assign, nonatomic) NSInteger             localReordFilterType;
@property (retain, nonatomic) NoDataView            *noDataView;

@end

@implementation RecordListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentPlayingRow = -1;
    self.path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    self.selectMode = 0;
    self.localReordFilterType = 0;
    
    self.view.backgroundColor = HEXCOLOR(0xE2E8F0, 1);
    if (self.idx == 0) {
        //录音成功事件广播，用于刷新本地数据
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLocalData) name:AddLocalRecordSuccess object:nil];
    }
}
//输入框return事件处理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //隐藏键盘
    [self.view endEditing:YES];
    NSString *string = textField.text;
    //停止播放
    [self stopPlayRecord];
    switch (self.localReordFilterType) {
        case All_filtrate_type:{
            //获取全部数据
            [self getAllRecordFiltrate:string];
        }
            break;
        case Source_quick_filtrate_type:{
            //获取快速录音数据
            [self getSourceQuickRecordFiltrate:string];
        }
            break;
        case Source_stand_filtrate_type: {
            //获取标准录音数据
            [self getSourceStandRecordFiltrate:string];
        }
            break;
        case Source_remote_filtrate_type: {
            //获取会诊录音数据
            [self getRemoteRecordFiltrate:string];
        }   break;;
        case heart_filtrate_type: {
            //获取心音数据
            [self getHeartRecordFiltrate:string];
        }
            break;
        case lung_filtrate_type:{
            //获取肺音数据
            [self getLungRecordFiltrate:string];
        }
            break;
        case Date_filtrate_type:{
            //根据日期选择
            [self getDateRecordFiltrate:string];
        }
            break;
        case Serial_number_filtrate_type:{
            //根据患者ID选择
            [self getSerialNumberFiltrate:string];
        }
            break;
        case Annotation_filtrate_type:{
            //根据标注选择
            [self getAnnotationFiltrate:string];
        }
        case Shared_filtrate_type:{
            //根据是否分享选择
            [self getShareRecordFiltrate:string];
        }
            break;
        default:
            break;
    }
    if(self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
    } else {
        self.noDataView.hidden = YES;
    }
    return YES;
}
//根据是否分享选择
- (void)getShareRecordFiltrate:(NSString *)string {
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if (model.shared == 1) {
            [self.arrayData addObject:model];
        }
    }
    [self.recordTableView reloadData];
}
//根据标注选择
- (void)getAnnotationFiltrate:(NSString *)string {
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if([Tools isBlankString:string]) {
            [self.arrayData addObject:model];
        } else if ([model.characteristics containsString:string]) {
            [self.arrayData addObject:model];
        }
    }
    [self.recordTableView reloadData];
}
//根据患者ID选择
- (void)getSerialNumberFiltrate:(NSString *)string {
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if ([Tools isBlankString:string]) {
            [self.arrayData addObject:model];
        } else if ([model.patient_id containsString:string]) {
            [self.arrayData addObject:model];
        }
    }
    [self.recordTableView reloadData];
}

//获取心音数据
- (void)getHeartRecordFiltrate:(NSString *)string{
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if (model.type_id == heart_sounds) {
            if ([Tools isBlankString:string]) {
                [self.arrayData addObject:model];
            } else {
                if ([model.characteristics containsString:string] || [model.record_time containsString:string] || [model.patient_id containsString:string] || [model.patient_area containsString:string] || [model.patient_diagnosis containsString:string] || [model.patient_symptom containsString:string]) {
                    [self.arrayData addObject:model];
                }
            }
        }
    }
    [self.recordTableView reloadData];
}

//获取肺音数据
- (void)getLungRecordFiltrate:(NSString *)string{
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if (model.type_id == lung_sounds) {
            [self.arrayData addObject:model];
           
        } else if ([model.characteristics containsString:string] || [model.record_time containsString:string] || [model.patient_id containsString:string] || [model.patient_area containsString:string] || [model.patient_diagnosis containsString:string] || [model.patient_symptom containsString:string]) {
            [self.arrayData addObject:model];
        }
    }
    [self.recordTableView reloadData];
}
//获取标准录音数据
- (void)getSourceStandRecordFiltrate:(NSString *)string{
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if(model.record_mode == StanarRecord) {
            if ([Tools isBlankString:string]) {
                [self.arrayData addObject:model];
            } else if ([model.characteristics containsString:string] || [model.record_time containsString:string] || [model.patient_id containsString:string] || [model.patient_area containsString:string] || [model.patient_diagnosis containsString:string] || [model.patient_symptom containsString:string]) {
                [self.arrayData addObject:model];
            }
        }
        
    }
    [self.recordTableView reloadData];
}
//获取快速录音数据
- (void)getSourceQuickRecordFiltrate:(NSString *)string{
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if(model.record_mode == QuickRecord) {
            if ([Tools isBlankString:string]) {
                [self.arrayData addObject:model];
            } else if ([model.characteristics containsString:string] || [model.record_time containsString:string] || [model.patient_id containsString:string] || [model.patient_area containsString:string] || [model.patient_diagnosis containsString:string] || [model.patient_symptom containsString:string]) {
                [self.arrayData addObject:model];
            }
        }
        
    }
    [self.recordTableView reloadData];
}
//根据日期选择
- (void)getDateRecordFiltrate:(NSString *)string {
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if ([Tools isBlankString:string]) {
            [self.arrayData addObject:model];
        } else if ([model.record_time containsString:string]) {
            [self.arrayData addObject:model];
        }
        
    }
    [self.recordTableView reloadData];
}
//获取会诊录音数据
- (void)getRemoteRecordFiltrate:(NSString *)string{
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if (model.record_mode == RemoteRecord) {
            if ([Tools isBlankString:string]) {
                [self.arrayData addObject:model];
            } else if ([model.characteristics containsString:string] || [model.record_time containsString:string] || [model.patient_id containsString:string] || [model.patient_area containsString:string] || [model.patient_diagnosis containsString:string] || [model.patient_symptom containsString:string]) {
                [self.arrayData addObject:model];
            }
        }
    }
    [self.recordTableView reloadData];
}
//获取全部数据
- (void)getAllRecordFiltrate:(NSString *)string{
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if ([Tools isBlankString:string]) {
            [self.arrayData addObject:model];
        } else if ([model.characteristics containsString:string] || [model.record_time containsString:string] || [model.patient_id containsString:string] || [model.patient_area containsString:string] || [model.patient_diagnosis containsString:string] || [model.patient_symptom containsString:string]) {
            [self.arrayData addObject:model];
        }
    }
    [self.recordTableView reloadData];
}

- (void)actionDeviceHelperPlayBegin{
    
}

- (void)actionDeviceHelperPlayingTime:(float)value{
    if (self.currentPlayingRow == -1) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPlayingRow inSection:0];
    RecordListCell *cell = (RecordListCell *)[self.recordTableView cellForRowAtIndexPath:indexPath];
    cell.playProgess = value;
    NSLog(@"播放进度：%f", value);
}

- (void)actionDeviceHelperPlayEnd{
    if (self.currentPlayingRow == -1) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPlayingRow inSection:0];
    RecordListCell *cell = (RecordListCell *)[self.recordTableView cellForRowAtIndexPath:indexPath];
    cell.bStop = NO;;
    cell.playProgess = 0;
}

//选择不同类型之后的回调
- (void)actionSelectedInfoCallBack:(NSString *)info row:(NSInteger)row tag:(NSInteger)tag{
    if(row == self.listInfo.count - 1) {
        return;
    } else {
        [self.selectButton setTitle:self.listInfo[row] forState:UIControlStateNormal];
    }
    self.textField.text = @"";
    self.selectMode = row;
    if (self.idx == 0) {
        [self loadLocalDBData];
        [self stopPlayRecord];
    } else if (self.idx == 1) {
        if (row == 0) {
            self.localReordFilterType  = All_filtrate_type;
            [self getAllRecordFiltrate:@""];
        } else if (row == 1) {
            self.localReordFilterType = Serial_number_filtrate_type;
            [self getSerialNumberFiltrate:@""];
        } else if (row == 2) {
            self.localReordFilterType = Date_filtrate_type;
            [self getDateRecordFiltrate:@""];
        } else if (row == 3) {
            self.localReordFilterType = Annotation_filtrate_type;
            [self getAnnotationFiltrate:@""];
        } else if (row == 4) {
            self.localReordFilterType = heart_filtrate_type;
            [self getHeartRecordFiltrate:@""];
        } else if (row == 5) {
            self.localReordFilterType = lung_filtrate_type;
            [self getLungRecordFiltrate:@""];
        } else if (row == 6) {
            self.localReordFilterType = Shared_filtrate_type;
            [self getShareRecordFiltrate:@""];
        }
    }  else if (self.idx == 2) {
        if (row == 0) {
            self.localReordFilterType  = All_filtrate_type;
            [self getAllRecordFiltrate:@""];
        } else if (row == 1) {
            self.localReordFilterType = Date_filtrate_type;
            [self getDateRecordFiltrate:@""];
        } else if (row == 2) {
            self.localReordFilterType = Annotation_filtrate_type;
            [self getAnnotationFiltrate:@""];
        } else if (row == 3) {
            self.localReordFilterType = heart_filtrate_type;
            [self getHeartRecordFiltrate:@""];
        } else if (row == 4) {
            self.localReordFilterType = lung_filtrate_type;
            [self getLungRecordFiltrate:@""];
        }
    }
    if(self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
    } else {
        self.noDataView.hidden = YES;
    }
}

//点击播放按钮事件处理
- (Boolean)actionRecordListCellItemClick:(RecordModel *)model bSelected:(Boolean)bSelected idx:(NSInteger)idx{
    //self.currentPlayingIdx = idx;
    NSInteger modelIndex = [self.arrayData indexOfObject:model];
    //正在播放时点击其它行
    if (self.bPlaying && modelIndex != self.currentPlayingRow) {
        [self.view makeToast:@"当前正在播放中，不可播放其它录音" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    self.currentPlayingRow = modelIndex;
    
    NSString *filePath = [NSString stringWithFormat:@"%@audio/%@", self.path,model.tag];
    //正在播放中暂停播放
    if(bSelected) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:modelIndex inSection:0];
        [[HHBlueToothManager shareManager] stop];
        RecordListCell *cell = (RecordListCell *)[self.recordTableView cellForRowAtIndexPath:indexPath];
        cell.playProgess = 0;
    } else {
        //没播放的开始播放
        if (self.idx == 0) {
            //本地录音播放事件处理
            NSLog(@"filePath = %@", filePath);
            [self startPlayRecordVoice:filePath];
        } else if(self.idx == 1) {
            //云标本库播放事件处理
            [self playCloudRecordVoice:filePath model:model];
        }
    }
    
    return !bSelected;
}
//处理云标本库播放事件
- (void)playCloudRecordVoice:(NSString *)filePath model:(RecordModel *)model{
    //如本地有缓存的播放文件，直接播放
    if ([HHFileLocationHelper fileExistsAtPath:filePath]) {
        [self startPlayRecordVoice:filePath];
    } else {
        //如果本地没有缓存文件，先下载，后播放缓存文件
        [AFNetRequestManager downLoadFileWithUrl:model.url path:filePath downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } successBlock:^(NSURL * _Nonnull url) {
            //播放下载后的文件
            [self startPlayRecordVoice:url.path];
        } fileDownloadFail:^(NSError * _Nonnull error) {
            
        }];
    }
    
}

//播放录音文件
- (void)startPlayRecordVoice:(NSString *)filePath{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [[HHBlueToothManager shareManager] setPlayFile:data];
    [[HHBlueToothManager shareManager] startPlay:PlayingWithSettingData];
}
//长按事件点击选择后的处理
- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    NSString *fileName = model.record_time;
    // tag: 0 本地录音 1 云标本库 2 我的收藏
    if (tag == 0) {
        if (index == 0) {
            
            [Tools showAlertView:nil andMessage:[NSString stringWithFormat:@"您确定要上传%@的录音吗?",fileName] andTitles:@[@"取消", @"确定"] andColors:@[MainNormal, MainColor] sure:^{
                //将本地录音上传至云标本库
                [self actionUploadToClound];
            } cancel:^{
            }];
            
        } else {
            [Tools showAlertView:nil andMessage:[NSString stringWithFormat:@"您确定要删除%@的录音吗?",fileName] andTitles:@[@"取消", @"确定"] andColors:@[MainNormal, MainColor] sure:^{
                //删除本地录音
                [self actionDeleteLocalData];
            } cancel:^{
            }];
            
        }
    } else if(tag == 1) {
        if (index == 0 || (index == 1 && model.shared)) {
            [self actionToShareRecord:model];
        } else {
            [self actionToDeleteRecord:model];
        }
    }
}

- (void)actionToShareRecord:(RecordModel *)model{
    NSString *message = model.shared ? @"取消分享" : @"分享";
    [Tools showAlertView:nil andMessage:[NSString stringWithFormat:@"您确定要%@%@的录音吗?", message,model.record_time] andTitles:@[@"取消", @"确定"] andColors:@[MainNormal, MainColor] sure:^{
        //分享云标本库
        [self actionToShareCloud];
    } cancel:^{
        
    }];
}

- (void)actionToDeleteRecord:(RecordModel *)model{
    [Tools showAlertView:nil andMessage:[NSString stringWithFormat:@"您确定要删除%@的录音吗?",model.record_time] andTitles:@[@"取消", @"确定"] andColors:@[MainNormal, MainColor] sure:^{
        //删除云标本库
        [self actionDeleteCloudData];
    } cancel:^{
        
    }];
}
//上传本地录音至云标本库
- (void)actionUploadToClound{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    if (model.record_length > 180) {
        [self.view makeToast:@"不能上传超过3分钟的音频" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *a = [NSString stringWithFormat:@"%@%@",[Tools getCurrentTimes], [Tools getRamdomString]];
    params[@"token"] = LoginData.token;
    params[@"tag"] = [NSString stringWithFormat:@"%@.wav", a];//model.tag;
    params[@"parient_id"] = model.patient_id;
    params[@"patient_area"] = model.patient_area;
    params[@"type_id"] = [@(model.type_id) stringValue];
    params[@"record_filter"] = [@(model.record_filter) stringValue];
    params[@"position_tag"] = model.position_tag;
    params[@"patient_symptom"] = model.patient_symptom;
    params[@"patient_diagnosis"] = model.patient_diagnosis;
    NSLog(@"model.patient_birthday = %@", model.patient_birthday);
    if (![Tools isBlankString:model.patient_birthday]) {
        params[@"patient_birthday"] = model.patient_birthday;
    }
    params[@"patient_sex"] = [@(model.patient_sex) stringValue];
   
    params[@"patient_height"] = model.patient_height;
    params[@"patient_weight"] = model.patient_weight;
    params[@"characteristics"] = [model.characteristics stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    params[@"record_time"] = model.record_time;
    params[@"record_length"] = [@(model.record_length) stringValue];
    params[@"record_model"] = [@(model.record_mode) stringValue];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", self.path, model.file_path];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [Tools showWithStatus:@"正在上传"];
    [TTRequestManager recordAdd:params recordData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        double f = (double)uploadProgress.completedUnitCount / (double)uploadProgress.totalUnitCount * 100;
        NSString *string = [NSString stringWithFormat:@"已上传%i%%", (int)f];
        [Tools showWithStatus:string];
    } success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSDictionary *dic = responseObject[@"data"];
            model.shared = [dic[@"shared"] integerValue];
            model.url = dic[@"url"];
            model.create_time = dic[@"create_time"];
            model.modify_time = dic[@"modify_time"];
            //上传成功后的事件处理
            [self actionAfterUploadRecordSuccess];
        }
        [self.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}
//本地录音上传后，添加至云标本库头一行
- (void)addCouldRecordItem:(RecordModel *)model{
    [self.arrayData insertObject:model atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.recordTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
//上传成功后的事件处理
- (void)actionAfterUploadRecordSuccess{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    //删除本地数据
    [self actionDeleteLocalData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionRecordListItemChange:type:fromIndex:)]) {
        //通过回调 让云标本库添加数据
        [self.delegate actionRecordListItemChange:model type:1 fromIndex:0];
    }
}
//分享云标本库
- (void)actionToShareCloud{
    
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    Boolean shared = !model.shared;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"tag"] = model.tag;
    params[@"shared"] = [@(shared) stringValue];
    [TTRequestManager recordShare:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSDictionary *data = responseObject[@"data"];
            Boolean shared = [data[@"shared"] boolValue];
            if (shared) {
                NSString *shareCode = data[@"share_code"];
                model.share_code = shareCode;
                [self shareWX:shareCode];
            } else {
                model.share_code = @"";
            }
           
            [self.recordTableView reloadRowsAtIndexPaths:@[self.currentSelectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
//分享
- (void)shareWX:(NSString *)shareCode{
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [NSString stringWithFormat:@"%@%@",[[Constant shareManager] getRecordShareBrief], shareCode];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"汉泓听诊工具";
    message.description = [NSString stringWithFormat:@"%@分享了标本", LoginData.name];
    [message setThumbImage:[UIImage imageNamed:@"icon"]];
    message.mediaObject = webpageObject;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            //dispatch_sync(dispatch_get_main_queue(), ^{
                [self.recordTableView reloadRowsAtIndexPaths:@[self.currentSelectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //});
        }
    }];
}
//删除本地数据
- (void)actionDeleteLocalData{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    //删除数据库
    Boolean result = [[HHDBHelper shareInstance] deleteRecordItemInTime:model.record_time];
    if (result) {
        [self deleteAndRefrshLocalRecordData];
    } else {
        NSLog(@"删除数据库失败");
    }
}
//寻找本地缓存文件，如果有先删除，再刷新
- (void)deleteAndRefrshLocalRecordData{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    NSString *filePath = [NSString stringWithFormat:@"%@audio/%@", self.path, model.tag];
    if ([HHFileLocationHelper fileExistsAtPath:filePath]) {
        [HHFileLocationHelper deleteFilePath:filePath];
    }
    [self.arrayData removeObject:model];
    [self.allData removeObject:model];
    [self.recordTableView deleteRowsAtIndexPaths:@[self.currentSelectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if(self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
    }
}
//删除云标本库
- (void)actionDeleteCloudData{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"tag"] = model.tag;
    [Tools showWithStatus:@"正在删除"];
    __weak typeof(self) wself = self;
    [TTRequestManager recordDelete:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //寻找本地缓存文件，如果有先删除，再刷新
                [wself deleteAndRefrshLocalRecordData];
            });
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}
    

//点击列表进入标注界面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AnnotationVC *annotationVC = [[AnnotationVC alloc] init];
    annotationVC.recordModel = self.arrayData[indexPath.row];
    annotationVC.saveLocation = self.idx;
    self.currentPlayingRow = -1;
    annotationVC.resultBlock = ^(RecordModel * _Nullable record) {
        NSInteger row = [self.arrayData indexOfObject:record];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.recordTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    [self.navigationController pushViewController:annotationVC animated:YES];
    
}
//初始化本地录音数据
- (void)initLocalData{
    self.bLoadData = YES;
    NSInteger loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
    if (loginType == login_type_teaching) {
        if (LoginData.role == Teacher_role) {//教学 教授数据
            self.listInfo = @[@"全部",@"便捷录音",@"标准录音",@"患者ID",@"日期",@"标注",@"心音",@"肺音", @"教学录音",@"取消"];
        } else {//教学 学生数据
            self.listInfo = @[@"全部",@"便捷录音",@"标准录音",@"患者ID",@"日期",@"标注",@"心音",@"肺音",@"取消"];
        }
            
    } else {//其它数据
        self.listInfo = @[@"全部",@"便捷录音",@"标准录音",@"患者ID",@"日期",@"标注",@"心音",@"肺音", @"会诊录音",@"取消"];
    }
          
    //读取本地数据库
    if ([NSThread isMainThread]) {
        [self loadLocalDBData];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self loadLocalDBData];
        });
    }
}
//读取本地数据库
- (void)loadLocalDBData{
    self.arrayData = [NSMutableArray array];
    self.allData = [NSMutableArray array];
    if (self.selectMode == 0) {
        self.localReordFilterType = All_filtrate_type;
    } else if (self.selectMode == 1) {
        self.localReordFilterType = Source_quick_filtrate_type;
    } else if (self.selectMode == 2) {
        self.localReordFilterType = Source_stand_filtrate_type;
    } else if (self.selectMode == 3) {
        self.localReordFilterType = Serial_number_filtrate_type;
    } else if (self.selectMode == 4) {
        self.localReordFilterType = Date_filtrate_type;
    } else if (self.selectMode == 5) {
        self.localReordFilterType = Annotation_filtrate_type;
    } else if (self.selectMode == 6) {
        self.localReordFilterType = heart_filtrate_type;
    } else if (self.selectMode == 7) {
        self.localReordFilterType = lung_filtrate_type;
    } else if (self.selectMode == 8) {
        self.localReordFilterType = Source_remote_filtrate_type;
    }
    Boolean mode_select = (self.localReordFilterType == Source_quick_filtrate_type) || (self.localReordFilterType == Source_stand_filtrate_type) || (self.localReordFilterType == Source_remote_filtrate_type);
    NSInteger mode = (self.localReordFilterType == Source_quick_filtrate_type) ? QuickRecord : ((self.localReordFilterType == Source_stand_filtrate_type) ? StanarRecord : RemoteRecord);
    Boolean type_select = (self.localReordFilterType == heart_filtrate_type) || (self.localReordFilterType == lung_filtrate_type);
    NSInteger type = (self.localReordFilterType == heart_filtrate_type) ? 1 : 2;
    NSArray *data = [[HHDBHelper shareInstance] selectRecord:mode_select mode:mode typeSelect:type_select type:type];
    [self.arrayData addObjectsFromArray:data];
    [self.allData addObjectsFromArray:data];
    if (self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
    } else {
        self.noDataView.hidden = YES;
        [self.recordTableView reloadData];
    }
    
}

//初始化云标本库数据
- (void)initCouldData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部", @"患者ID",@"日期",@"标注",@"心音",@"肺音", @"已分享",@"取消"];
    self.arrayData = [NSMutableArray array];
    self.allData = [NSMutableArray array];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    __weak typeof(self) wself = self;
    [TTRequestManager recordList:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            NSArray *data = [NSArray yy_modelArrayWithClass:[RecordModel class] json:responseObject[@"data"]];
            [wself.arrayData addObjectsFromArray:data];
            [wself.allData addObjectsFromArray:data];
            if(wself.arrayData.count == 0) {
                wself.noDataView.hidden = NO;
            } else {
                wself.noDataView.hidden = YES;
                [wself.recordTableView reloadData];
            }
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

//初始化我的收藏数据
- (void)initCollectData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部", @"日期",@"标注",@"心音",@"肺音",@"取消"];
    self.arrayData = [NSMutableArray array];
    self.allData = [NSMutableArray array];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    __weak typeof(self) wself = self;
    [TTRequestManager recordFavoriteList:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            NSArray *data = [NSArray yy_modelArrayWithClass:[RecordModel class] json:responseObject[@"data"]];
            [wself.arrayData addObjectsFromArray:data];
            [wself.allData addObjectsFromArray:data];
            if(wself.arrayData.count == 0) {
                wself.noDataView.hidden = NO;
            } else {
                wself.noDataView.hidden = YES;
                [wself.recordTableView reloadData];
            }
            
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
    //unexpected attempt to have multiple concurrent normal build operations
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordListCell *cell = (RecordListCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RecordListCell class])];
    //NSLog(@"self.arrayData = %@", [Tools convertToJsonData:self.arrayData]);
    cell.recordModel = self.arrayData[indexPath.row];
    cell.idx = self.idx;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 129.f*screenRatio;
}



- (void)initView{
    [self.view addSubview:self.selectButton];
    self.selectButton.sd_layout.leftSpaceToView(self.view, Ratio11).topSpaceToView(self.view, Ratio6).heightIs(Ratio25).widthIs(Ratio66);
    
    [self.view addSubview:self.textField];
    self.textField.sd_layout.leftSpaceToView(self.selectButton, Ratio4).centerYEqualToView(self.selectButton).heightIs(Ratio25).rightSpaceToView(self.view, Ratio11);
    
    [self.view addSubview:self.recordTableView];
    self.recordTableView.sd_layout.leftSpaceToView(self.view, Ratio11).rightSpaceToView(self.view, Ratio11).topSpaceToView(self.selectButton, Ratio6).bottomSpaceToView(self.view, kTabBarHeight);
    

    [self.view addSubview:self.noDataView];
}

- (void)actionCilckSelect:(UIButton *)button{
    self.popView.hidden = NO;
}

- (UIButton *)selectButton{
    if(!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        _selectButton.backgroundColor = WHITECOLOR;
        _selectButton.cs_imagePositionMode = ImagePositionModeRight;
        _selectButton.cs_middleDistance = Ratio1;
        //_selectButton.cs_imageSize = CGSizeMake(Ratio16, Ratio16);
        [_selectButton setImage:[UIImage imageNamed:@"pull_down"] forState:UIControlStateNormal];
        [_selectButton setTitle:@"全部" forState:UIControlStateNormal];
        [_selectButton setTitleColor:MainBlack forState:UIControlStateNormal];
        _selectButton.titleLabel.font = Font13;
        _selectButton.layer.cornerRadius = Ratio5;
        _selectButton.layer.borderWidth = Ratio1;
        _selectButton.layer.borderColor = ViewBackGroundColor.CGColor;
        [_selectButton addTarget:self action:@selector(actionCilckSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (TTPopView *)popView{
    if (!_popView) {
        _popView = [[TTPopView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        _popView.hidden = YES;
        _popView.delegate = self;
        [_popView setWidth:screenW listInfo:self.listInfo];
        [kAppWindow addSubview:_popView];
        
    }
    return _popView;
}

- (LRTextField *)textField{
    if(!_textField) {
        _textField = [[LRTextField alloc] init];
        [_textField setPlaceholder:@"请输入搜索内容"];
        _textField.font = Font13;
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.layer.cornerRadius = Ratio5;
        _textField.layer.borderWidth = Ratio1;
        _textField.layer.borderColor = ViewBackGroundColor.CGColor;
        _textField.backgroundColor = WHITECOLOR;
    }
    return _textField;
}

- (UITableView *)recordTableView{
    if(!_recordTableView) {
        _recordTableView = [[UITableView alloc] init];
        [_recordTableView registerClass:[RecordListCell class] forCellReuseIdentifier:NSStringFromClass([RecordListCell class])];
        _recordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _recordTableView.showsVerticalScrollIndicator = NO;
        _recordTableView.backgroundColor = HEXCOLOR(0xE2E8F0, 1);
        _recordTableView.delegate = self;
        _recordTableView.dataSource = self;
        _recordTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]  initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.delegate = self;
        lpgr.delaysTouchesBegan = YES;
        [_recordTableView addGestureRecognizer:lpgr];
    }
    return _recordTableView;
}

//长按列表事件
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.recordTableView];

    NSIndexPath *indexPath = [self.recordTableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        self.currentSelectIndexPath = indexPath;
        RecordModel *model = [self.arrayData objectAtIndex:indexPath.row];
        NSArray *arrayTitle = @[@"加入云标本库", @"删除"];
        if (self.idx == 1) {
            if(model.shared) {
                arrayTitle = @[@"分享", @"取消分享", @"删除"];
            } else {
                arrayTitle = @[@"分享", @"删除"];
            }
        }
        TTActionSheet *actionSheet = [TTActionSheet showActionSheet:arrayTitle cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        actionSheet.delegate = self;
        actionSheet.tag = self.idx;
        [actionSheet showInView:kAppWindow];
        
    }
}
//切换页面时停止播放
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //self.bCurrentView = NO;
    //[self stopPlayRecord];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //self.bCurrentView = YES;
}

- (NoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight + Ratio33, screenW, screenH - kNavBarAndStatusBarHeight - kTabBarHeight - Ratio33)];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

@end
