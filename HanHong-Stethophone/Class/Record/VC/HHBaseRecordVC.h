//
//  HHBaseRecordVC.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/5.
//

#import <UIKit/UIKit.h>
#import "ReadyRecordView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHBaseRecordVC : UIViewController

//蓝牙图标按钮
@property (retain, nonatomic) HHBluetoothButton     *buttonBluetooth;
@property (assign, nonatomic) NSInteger             recordDuration;//记录录音时长
@property (assign, nonatomic) NSInteger             recordingState;//录音状态
@property (assign, nonatomic) NSInteger             soundsType;//快速录音类型
@property (assign, nonatomic) NSInteger             recordModel;//快速录音类型
@property (assign, nonatomic) NSInteger             isFiltrationRecord;//滤波状态
@property (assign, nonatomic) NSInteger             recordDurationAll;// 录音总时长
@property (assign, nonatomic) NSInteger             RECORD_TYPE;//判断滤波状态
@property (retain, nonatomic) NSString              *recordCode;//录音编号
@property (retain, nonatomic) NSString              *relativePath;
@property (assign, nonatomic) NSInteger             successCount;
@property (retain, nonatomic) ReadyRecordView       *readyRecordView;

- (void)initNavi:(NSInteger)number;
- (void)actionDeviceHelperRecordReady;
- (void)actionDeviceHelperRecordBegin;
- (void)actionDeviceHelperRecordingTime:(float)number;
- (void)actionDeviceHelperRecordPause;
- (void)actionDeviceHelperRecordEnd;
- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel;
- (void)loadData;
- (void)actionClickBlueToothCallBack:(UIButton *)button;
- (void)actionCancelClickBluetooth;
- (void)reloadView;
- (void)actionRecordFinish;
- (void)actionStartRecord;
- (void)loadPlistData:(Boolean)firstLoadData;
- (void)realodFilerView;
- (void)reloadViewRecordView;

@end

NS_ASSUME_NONNULL_END
