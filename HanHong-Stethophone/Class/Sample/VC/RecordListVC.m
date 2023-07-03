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

@property (retain, nonatomic) UIButton              *selectButton;
@property (retain, nonatomic) TTPopView             *popView;
@property (retain, nonatomic) NSArray               *listInfo;
@property (retain, nonatomic) LRTextField           *textField;
@property (retain, nonatomic) UITableView           *recordTableView;
@property (retain, nonatomic) NSMutableArray        *arrayData;
@property (assign, nonatomic) NSInteger             selectMode;
@property (retain, nonatomic) NSIndexPath           *currentSelectIndexPath;
@property (assign, nonatomic) NSInteger             currentPlayingRow;
@property (assign, nonatomic) NSInteger             currentPlayingIdx;
@property (retain, nonatomic) NSString              *path;
@property (retain, nonatomic) NSMutableArray        *allData;

@property (assign, nonatomic) Boolean               bPlaying;
@property (assign, nonatomic) NSInteger             localReordFilterType;

@end

@implementation RecordListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bPlaying = NO;
    
    self.currentPlayingRow = 0;
    self.path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    self.selectMode = 0;
    self.localReordFilterType = 0;
    
    self.view.backgroundColor = HEXCOLOR(0xE2E8F0, 1);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionRecieveBluetoothMessage:) name:HHBluetoothMessage object:nil];
    if (self.idx == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLocalData) name:AddLocalRecordSuccess object:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    NSString *string = textField.text;
    [self stopPlayRecord];
    switch (self.localReordFilterType) {
        case All_filtrate_type:{
            [self getAllRecordFiltrate:string];
        }
            break;
        case Source_quick_filtrate_type:{
            [self getSourceQuickRecordFiltrate:string];
        }
            break;
        case Source_stand_filtrate_type: {
            [self getSourceStandRecordFiltrate:string];
        }
            break;
        case Source_remote_filtrate_type: {
            [self getRemoteRecordFiltrate:string];
        }   break;;
        case heart_filtrate_type: {
            [self getHeartRecordFiltrate:string];
        }
            break;
        case lung_filtrate_type:{
            [self getLungRecordFiltrate:string];
        }
            break;
        case Date_filtrate_type:{
            [self getDateRecordFiltrate:string];
        }
            break;
        case Serial_number_filtrate_type:{
            [self getSerialNumberFiltrate:string];
        }
            break;
        case Annotation_filtrate_type:{
            [self getAnnotationFiltrate:string];
        }
        case Shared_filtrate_type:{
            [self getShareRecordFiltrate:string];
        }
            break;
        default:
            break;
    }
    return YES;
}

- (void)getShareRecordFiltrate:(NSString *)string {
    self.arrayData = [NSMutableArray array];
    for (RecordModel *model in self.allData) {
        if (model.shared == 1) {
            [self.arrayData addObject:model];
        }
    }
    [self.recordTableView reloadData];
}

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
    
//    NSInteger loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
//    for (RecordModel *model in self.allData) {
//        if ([string containsString:@"心音"] && model.type_id == heart_sounds) {
//            [self.arrayData addObject:model];
//            continue;
//        }
//        if ([string containsString:@"肺音"] && model.type_id == lung_sounds) {
//            [self.arrayData addObject:model];
//            continue;
//        }
//        if ([string containsString:@"便捷录音"] && model.record_mode == QuickRecord) {
//            [self.arrayData addObject:model];
//            continue;
//        }
//        if ([string containsString:@"标准录音"] && model.record_mode == StanarRecord) {
//            [self.arrayData addObject:model];
//            continue;
//        }
//        if (loginType == login_type_teaching) {
//            if (LoginData.role == Teacher_role) {
//                if ([string containsString:@"教学录音"] && model.record_mode == RemoteRecord) {
//                    [self.arrayData addObject:model];
//                    continue;
//                }
//            }
//        } else {
//            if ([string containsString:@"会诊录音"] && model.record_mode == RemoteRecord) {
//                [self.arrayData addObject:model];
//                continue;;
//            }
//        }
//
//        if ([string containsString:@"未标注"]) {
//            if ([model.characteristics isEqualToString:@"[]"] || [model.characteristics isEqualToString:@""]) {
//                [self.arrayData addObject:model];
//                continue;;
//            }
//        }
//        if ([string containsString:@"已分享"]) {
//            if (model.shared == 1) {
//                [self.arrayData addObject:model];
//                continue;;
//            }
//        }
//
//        if ([model.characteristics containsString:string] || [model.record_time containsString:string] || [model.patient_id containsString:string] || [model.patient_area containsString:string] || [model.patient_diagnosis containsString:string] || [model.patient_symptom containsString:string]) {
//            [self.arrayData addObject:model];
//        }
//
//    }
}

- (void)stopPlayRecord{
    if(self.bPlaying) {
        [[HHBlueToothManager shareManager] stop];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPlayingRow inSection:0];
        RecordListCell *cell = (RecordListCell *)[self.recordTableView cellForRowAtIndexPath:indexPath];
        cell.bStop = NO;;
        cell.playProgess = 0;
        self.bPlaying = NO;
    }
    
}

- (void)actionSelectedInfoCallBack:(NSString *)info row:(NSInteger)row tag:(NSInteger)tag{
    if(row != self.listInfo.count - 1) {
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
}



- (void)actionRecieveBluetoothMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    DEVICE_HELPER_EVENT event = [userInfo[@"event"] integerValue];
    NSObject *args1 = userInfo[@"args1"];
    NSObject *args2 = userInfo[@"args2"];
    if (self.currentPlayingIdx != self.idx) {
        return;
    }
    NSLog(@"string = %@, currentPlayingIdx = %li, self.idx = %li", self.string,self.currentPlayingIdx, self.idx);
    if (event == DeviceHelperPlayBegin) {
        self.bPlaying = YES;
    } else if (event == DeviceHelperPlayingTime) {
        __weak typeof(self) wself = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:wself.currentPlayingRow inSection:0];
            RecordListCell *cell = (RecordListCell *)[wself.recordTableView cellForRowAtIndexPath:indexPath];
            NSNumber *number = (NSNumber *)args1;
            float value = [number floatValue];
            cell.playProgess = value;
            NSLog(@"播放进度：%f", value);
        });
        
        
    } else if (event == DeviceHelperPlayEnd) {
        NSLog(@"播放结束");
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopPlayRecord];
        });
        
    }
}

- (Boolean)actionRecordListCellItemClick:(RecordModel *)model bSelected:(Boolean)bSelected idx:(NSInteger)idx{
    self.currentPlayingIdx = idx;
    NSInteger modelIndex = [self.arrayData indexOfObject:model];
    if (self.bPlaying && modelIndex != self.currentPlayingRow) {
        [self.view makeToast:@"当前正在播放中，不可播放其它录音" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return NO;
    }
    self.currentPlayingRow = modelIndex;
    
    NSString *filePath = [NSString stringWithFormat:@"%@audio/%@", self.path,model.tag];
    
    if(bSelected) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:modelIndex inSection:0];
        [[HHBlueToothManager shareManager] stop];
        RecordListCell *cell = (RecordListCell *)[self.recordTableView cellForRowAtIndexPath:indexPath];
        cell.playProgess = 0;
    } else {
        if (self.idx == 0) {
            NSLog(@"filePath = %@", filePath);
            [self startPlayRecordVoice:filePath];
        } else if(self.idx == 1) {
            [self playCloudRecordVoice:filePath model:model];
        }
    }
    
    return !bSelected;
}

- (void)playCloudRecordVoice:(NSString *)filePath model:(RecordModel *)model{
    if ([HHFileLocationHelper fileExistsAtPath:filePath]) {
        [self startPlayRecordVoice:filePath];
    } else {
        [AFNetRequestManager downLoadFileWithUrl:model.url path:filePath downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } successBlock:^(NSURL * _Nonnull url) {
            [self startPlayRecordVoice:url.path];
        } fileDownloadFail:^(NSError * _Nonnull error) {
            
        }];
    }
    
}


- (void)startPlayRecordVoice:(NSString *)filePath{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [[HHBlueToothManager shareManager] setPlayFile:data];
    [[HHBlueToothManager shareManager] startPlay:PlayingWithSettingData];
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    NSString *fileName = model.record_time;
    if (tag == 0) {
        if (index == 0) {
            [Tools showAlertView:nil andMessage:[NSString stringWithFormat:@"您确定要上传%@的录音吗?",fileName] andTitles:@[@"取消", @"确定"] andColors:@[MainNormal, MainColor] sure:^{
                [self actionUploadToClound];
            } cancel:^{
                
            }];
            
        } else {
            [Tools showAlertView:nil andMessage:[NSString stringWithFormat:@"您确定要删除%@的录音吗?",fileName] andTitles:@[@"取消", @"确定"] andColors:@[MainNormal, MainColor] sure:^{
                [self actionDeleteLocalData];
            } cancel:^{
                
            }];
            
        }
    } else if(tag == 1) {
        if (index == 0) {
            [Tools showAlertView:nil andMessage:[NSString stringWithFormat:@"您确定要分享%@的录音吗?",fileName] andTitles:@[@"取消", @"确定"] andColors:@[MainNormal, MainColor] sure:^{
                [self actionToShareCloud];
            } cancel:^{
                
            }];
            
        } else {
            [Tools showAlertView:nil andMessage:[NSString stringWithFormat:@"您确定要删除%@的录音吗?",fileName] andTitles:@[@"取消", @"确定"] andColors:@[MainNormal, MainColor] sure:^{
                [self actionDeleteCloudData];
            } cancel:^{
                
            }];
        }
    }
}
//unexpected service error: build aborted due to an internal error: 
- (void)actionUploadToClound{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
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
    NSString *filePath = [NSString stringWithFormat:@"%@%@", self.path, model.file_path];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [Tools showWithStatus:@"正在上传"];
    [TTRequestManager recordAdd:params recordData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"completedUnitCount = %lli,totalUnitCount = %lli ", uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
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
            [self actionAfterUploadRecordSuccess];
        }
        [self.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)addCouldRecordItem:(RecordModel *)model{
    [self.arrayData insertObject:model atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.recordTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)actionAfterUploadRecordSuccess{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    [self actionDeleteLocalData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionRecordListItemChange:type:fromIndex:)]) {
        [self.delegate actionRecordListItemChange:model type:1 fromIndex:0];
    }
}

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
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.recordTableView reloadRowsAtIndexPaths:@[self.currentSelectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
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
        
    }];
}

- (void)actionDeleteLocalData{
    RecordModel *model = self.arrayData[self.currentSelectIndexPath.row];
    Boolean result = [[HHDBHelper shareInstance] deleteRecordItemInTime:model.record_time];
    if (result) {
        
       //202307011059120145 NSString *relativePath = [NSString stringWithFormat:@"audio/%@.wav", model.file_path];
        NSString *filePath = [NSString stringWithFormat:@"%@%@", self.path, model.file_path];
        [HHFileLocationHelper deleteFilePath:filePath];
        [self.arrayData removeObject:model];
        [self.allData removeObject:model];
        [self.recordTableView deleteRowsAtIndexPaths:@[self.currentSelectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSLog(@"删除数据库失败");
    }
}

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
                [wself.arrayData removeObject:model];
                [wself.allData removeObject:model];
                [wself.recordTableView deleteRowsAtIndexPaths:@[wself.currentSelectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}
    




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AnnotationVC *annotationVC = [[AnnotationVC alloc] init];
    annotationVC.recordModel = self.arrayData[indexPath.row];
    [self.navigationController pushViewController:annotationVC animated:YES];
    
}

- (void)initLocalData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部",@"便捷录音",@"标准录音",@"患者ID",@"日期",@"标注",@"心音",@"肺音",@"取消"];
    [self loadLocalDBData];
}

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
    }
    Boolean mode_select = (self.localReordFilterType == Source_quick_filtrate_type) || (self.localReordFilterType == Source_stand_filtrate_type) || (self.localReordFilterType == Source_remote_filtrate_type);
    NSInteger mode = (self.localReordFilterType == Source_quick_filtrate_type) ? QuickRecord : ((self.localReordFilterType == Source_stand_filtrate_type) ? StanarRecord : RemoteRecord);
    Boolean type_select = (self.localReordFilterType == heart_filtrate_type) || (self.localReordFilterType == lung_filtrate_type);
    NSInteger type = (self.localReordFilterType == heart_filtrate_type) ? 1 : 2;
    NSArray *data = [[HHDBHelper shareInstance] selectRecord:mode_select mode:mode typeSelect:type_select type:type];
    [self.arrayData addObjectsFromArray:data];
    [self.allData addObjectsFromArray:data];
    [self.recordTableView reloadData];
}



- (void)initCouldData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部", @"患者ID",@"日期",@"标注",@"心音",@"肺音", @"已分享",@"取消"];
    self.arrayData = [NSMutableArray array];
    self.allData = [NSMutableArray array];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    [TTRequestManager recordList:params success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            NSArray *data = [NSArray yy_modelArrayWithClass:[RecordModel class] json:responseObject[@"data"]];
            [self.arrayData addObjectsFromArray:data];
            [self.allData addObjectsFromArray:data];
            [self.recordTableView reloadData];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}



- (void)initCollectData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部", @"日期",@"标注",@"心音",@"肺音",@"取消"];
    self.arrayData = [NSMutableArray array];
    self.allData = [NSMutableArray array];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    [TTRequestManager recordFavoriteList:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            NSArray *data = [NSArray yy_modelArrayWithClass:[RecordModel class] json:responseObject[@"data"]];
            [self.arrayData addObjectsFromArray:data];
            [self.allData addObjectsFromArray:data];
            [self.recordTableView reloadData];
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
        NSArray *arrayTitle = @[@"上传云标本库", @"删除"];
        if (self.idx == 1) {
            arrayTitle = @[model.shared ? @"取消分享": @"分享", @"删除"];
        }
        TTActionSheet *actionSheet = [TTActionSheet showActionSheet:arrayTitle cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        actionSheet.delegate = self;
        actionSheet.tag = 0;
        [actionSheet showInView:kAppWindow];
        
    }
}


@end
