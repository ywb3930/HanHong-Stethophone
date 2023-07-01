//
//  DeviceManagerSettingView.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceManagerSettingView : UITableView

@property (retain, nonatomic) NSArray               *arrayTitle;
@property (retain, nonatomic) NSArray               *arrayType;
@property (retain, nonatomic) NSMutableArray         *arrayValue;
@property (retain, nonatomic) NSMutableDictionary    *settingData;
@property (assign, nonatomic) NSInteger             recordingState;
@property (assign, nonatomic) Boolean               bStandart;

@end

NS_ASSUME_NONNULL_END
