//
//  HMEditView.h
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import <UIKit/UIKit.h>
#import "LRTextField.h"
NS_ASSUME_NONNULL_BEGIN

@protocol HMEditViewDelegate <NSObject>
@optional
- (void)actionEditInfoCallback:(NSString *)string idx:(NSInteger)idx;

@end

@interface HMEditView : UIView

@property (weak, nonatomic) id<HMEditViewDelegate> delegate;
- (instancetype)initWithTitle:(NSString *)title info:(nullable NSString *)info placeholder:(NSString *)placeholder idx:(NSInteger)idx;
@property (retain, nonatomic) LRTextField               *textField;
@property (retain, nonatomic) NSString                  *cancelTitle;
@property (retain, nonatomic) NSString                  *okTitle;

@end

NS_ASSUME_NONNULL_END
