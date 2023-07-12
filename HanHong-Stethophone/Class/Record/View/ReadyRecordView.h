//
//  ReadyRecordView.h
//  HanHong-Stethophone
//  准备录音界面
//  Created by Hanhong on 2023/6/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReadyRecordView : UIView

@property (retain, nonatomic) UILabel               *labelReadyRecord;
@property (assign, nonatomic) NSInteger             duration;
@property (assign, nonatomic) float                 recordTime;
@property (assign, nonatomic) float                 progress;
@property (assign, nonatomic) Boolean               stop;
@property (retain, nonatomic) NSString              *recordCode;
@property (retain, nonatomic) NSString              *startTime;

@end

NS_ASSUME_NONNULL_END
