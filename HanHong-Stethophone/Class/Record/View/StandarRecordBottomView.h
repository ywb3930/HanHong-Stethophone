//
//  StandarRecordBottomView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/30.
//

#import <UIKit/UIKit.h>
#import "ReadyRecordView.h"

@protocol StandarRecordBottomViewDelegate <NSObject>

- (Boolean)actionHeartLungFilterChange:(NSInteger)filterModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface StandarRecordBottomView : UIView

@property (weak, nonatomic) id<StandarRecordBottomViewDelegate> delegate;
@property (assign, nonatomic) NSInteger                 index;
@property (retain, nonatomic) ReadyRecordView           *readyRecordView;
@property (retain, nonatomic) UILabel                   *labelStartRecord;
@property (retain, nonatomic) NSString                  *positionName;
@property (retain, nonatomic) NSString                  *recordMessage;
@property (retain, nonatomic) NSString                  *deviceConnectMessage;

- (void)filterGrayString:(NSString *)grayString blueString:(NSString *)blueString;

@end

NS_ASSUME_NONNULL_END
