//
//  RecordListVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "RecordListVC.h"
#import "TTPopView.h"
#import "LRTextField.h"
#import "RecordListCell.h"
#import "AnnotationVC.h"
#import "TTActionSheet.h"
#import "WXApi.h"

@interface RecordListVC ()<TTPopViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, TTActionSheetDelegate>

@property (retain, nonatomic) UIButton              *selectButton;
@property (retain, nonatomic) TTPopView             *popView;
@property (retain, nonatomic) NSArray               *listInfo;
@property (retain, nonatomic) LRTextField           *textField;
@property (retain, nonatomic) UITableView           *recordTableView;
@property (retain, nonatomic) NSMutableArray        *arrayData;
@property (assign, nonatomic) NSInteger             selectMode;
@property (retain, nonatomic) NSIndexPath           *currentIndexPath;
@property (retain, nonatomic) NSString              *path;

@end

@implementation RecordListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.path = [HHFileLocationHelper getAppDocumentPath:[Constant shareManager].userInfoPath];
    self.selectMode = 0;
    self.arrayData = [NSMutableArray array];
    self.view.backgroundColor = HEXCOLOR(0xE2E8F0, 1);
    if (self.idx == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLocalData) name:@"add_record_success" object:nil];
    }
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    if (tag == 0) {
        if (index == 0) {
            [self actionUploadToClound];
        } else {
            [self actionDeleteLocalData];
        }
    } else if(tag == 1) {
        if (index == 0) {
            [self actionToShareCloud];
        } else {
            [self actionDeleteCloudData];
        }
    }
}
//unexpected service error: build aborted due to an internal error: 
- (void)actionUploadToClound{
    RecordModel *model = self.arrayData[self.currentIndexPath.row];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"tag"] = model.tag;
    params[@"parient_id"] = model.patient_id;
    params[@"patient_area"] = model.patient_area;
    
    params[@"type_id"] = [@(model.type_id) stringValue];
    params[@"record_filter"] = [@(model.record_filter) stringValue];
    params[@"position_tag"] = model.position_tag;
    params[@"patient_symptom"] = model.patient_symptom;
    params[@"patient_diagnosis"] = model.patient_diagnosis;
    params[@"patient_sex"] = [@(model.patient_sex) stringValue];
    params[@"patient_birthday"] = model.patient_birthday;
    params[@"patient_height"] = model.patient_height;
    params[@"patient_weight"] = model.patient_weight;
    params[@"characteristics"] = [model.characteristics stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    params[@"record_time"] = model.record_time;
    params[@"record_length"] = [@(model.record_length) stringValue];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", self.path, model.file_path];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [Tools showWithStatus:@"正在上传"];
    [TTRequestManager recordAdd:params recordData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        double f = (double)uploadProgress.completedUnitCount / (double)uploadProgress.totalUnitCount * 100;
        NSString *string = [NSString stringWithFormat:@"已上传%i%%", (int)f];
        [Tools showWithStatus:string];
    } success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
        }
        [self.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)actionToShareCloud{
    
    RecordModel *model = self.arrayData[self.currentIndexPath.row];
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
                [self.recordTableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    RecordModel *model = self.arrayData[self.currentIndexPath.row];
    Boolean result = [[HHDBHelper shareInstance] deleteRecordItemInTime:model.record_time];
    if (result) {
        
       //202307011059120145 NSString *relativePath = [NSString stringWithFormat:@"audio/%@.wav", model.file_path];
        NSString *filePath = [NSString stringWithFormat:@"%@%@", self.path, model.file_path];
        [HHFileLocationHelper deleteFilePath:filePath];
        [self.arrayData removeObjectAtIndex:self.currentIndexPath.row];
        [self.recordTableView deleteRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSLog(@"删除数据库失败");
    }
}

- (void)actionDeleteCloudData{
    RecordModel *model = self.arrayData[self.currentIndexPath.row];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"tag"] = model.tag;
    [Tools showWithStatus:@"正在删除"];
    __weak typeof(self) wself = self;
    [TTRequestManager recordDelete:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.arrayData removeObjectAtIndex:wself.currentIndexPath.row];
                [wself.recordTableView deleteRowsAtIndexPaths:@[wself.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewWarmingTime position:CSToastPositionCenter];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}
    

- (void)actionSelectedInfoCallBack:(NSString *)info row:(NSInteger)row tag:(NSInteger)tag{
    if(row != self.listInfo.count - 1) {
        [self.selectButton setTitle:self.listInfo[row] forState:UIControlStateNormal];
    }
    self.selectMode = row;
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
    NSInteger localReordFilterType = 0;
    if (self.selectMode == 0) {
        localReordFilterType = All_filtrate_type;
    } else if (self.selectMode == 1) {
        localReordFilterType = Source_quick_filtrate_type;
    } else if (self.selectMode == 2) {
        localReordFilterType = Source_stand_filtrate_type;
    } else if (self.selectMode == 3) {
        localReordFilterType = Serial_number_filtrate_type;
    } else if (self.selectMode == 4) {
        localReordFilterType = Date_filtrate_type;
    } else if (self.selectMode == 5) {
        localReordFilterType = Annotation_filtrate_type;
    } else if (self.selectMode == 6) {
        localReordFilterType = heart_filtrate_type;
    } else if (self.selectMode == 7) {
        localReordFilterType = lung_filtrate_type;
    }
    Boolean mode_select = (localReordFilterType == Source_quick_filtrate_type) || (localReordFilterType == Source_stand_filtrate_type) || (localReordFilterType == Source_remote_filtrate_type);
    NSInteger mode = (localReordFilterType == Source_quick_filtrate_type) ? QuickRecord : ((localReordFilterType == Source_stand_filtrate_type) ? StanarRecord : RemoteRecord);
    Boolean type_select = (localReordFilterType == heart_filtrate_type) || (localReordFilterType == lung_filtrate_type);
    NSInteger type = (localReordFilterType == heart_filtrate_type) ? 1 : 2;
    NSArray *data = [[HHDBHelper shareInstance] selectRecord:mode_select mode:mode typeSelect:type_select type:type];
    [self.arrayData addObjectsFromArray:data];
    [self.recordTableView reloadData];
}

- (void)initCouldData{
    self.bLoadData = YES;
    self.listInfo = @[@"全部", @"患者ID",@"日期",@"标注",@"心音",@"肺音", @"已分享",@"取消"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    [TTRequestManager recordList:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            NSArray *data = [NSArray yy_modelArrayWithClass:[RecordModel class] json:responseObject[@"data"]];
            [self.arrayData addObjectsFromArray:data];
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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    [Tools showWithStatus:nil];
    [TTRequestManager recordFavoriteList:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            NSArray *data = [NSArray yy_modelArrayWithClass:[RecordModel class] json:responseObject[@"data"]];
            [self.arrayData addObjectsFromArray:data];
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
        _textField.font = [UIFont systemFontOfSize:Ratio10];
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
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]  initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.delegate = self;
        lpgr.delaysTouchesBegan = YES;
        [_recordTableView addGestureRecognizer:lpgr];
    }
    return _recordTableView;
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.recordTableView];

    NSIndexPath *indexPath = [self.recordTableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        self.currentIndexPath = indexPath;
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
