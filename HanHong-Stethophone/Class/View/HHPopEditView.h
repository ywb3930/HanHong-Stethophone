//
//  HHPopEditView.h
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import <UIKit/UIKit.h>
#import "LRTextField.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HHPopEditViewDelegate <NSObject>

- (void)actionClickCommnitCallback:(NSInteger)time tag:(NSInteger)tag;

@end

@interface HHPopEditView : UIView

@property (weak, nonatomic) id<HHPopEditViewDelegate> delegate;
@property (retain, nonatomic) NSString              *unit;
@property (retain, nonatomic) NSString              *defaultNumber;

@property (retain, nonatomic) LRTextField           *textFieldNumber;

@end

NS_ASSUME_NONNULL_END
