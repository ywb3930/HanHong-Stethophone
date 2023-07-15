//
//  NoDataView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/7/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^NoDataViewTapImageViewBlock)(void);

@interface NoDataView : UIView

@property (nonatomic, copy) NoDataViewTapImageViewBlock tapBloack;

@end

NS_ASSUME_NONNULL_END
