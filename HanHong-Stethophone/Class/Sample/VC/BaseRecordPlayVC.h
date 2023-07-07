//
//  BaseRecordPlayVC.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/5.
//

#import <UIKit/UIKit.h>
#import "HHBaseViewController.h"
#import "KSYAudioPlotView.h"
#import "KSYAudioFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseRecordPlayVC : HHBaseViewController

@property (retain, nonatomic) RecordModel           *recordModel;
@property (retain, nonatomic) KSYAudioPlotView              *audioPlotView;
@property (nonatomic, strong) KSYAudioFile                  *audioFile;
@property (assign, nonatomic) Boolean                       bCurrentView;//是否在当前页面
@property (assign, nonatomic) Boolean                       bPlaying;

- (void)actionDeviceHelperPlayBegin;
- (void)actionDeviceHelperPlayingTime:(float)value;
//- (void)actionClickPlay:(UIButton *)button;
- (void)stopPlayRecord;
- (void)actionDeviceHelperPlayEnd;
- (void)openFileWithFilePathURL;
- (void)actionToStar:(float)startTime endTime:(float)endTime;

@end

NS_ASSUME_NONNULL_END
