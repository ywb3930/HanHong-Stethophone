//
//  AnnotationItemCell.h
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AnnotationItemCellDelegate <NSObject>

- (void)actionClickDeleteCallback:(UITableViewCell *)cell;

@end

@interface AnnotationItemCell : UITableViewCell

@property (weak, nonatomic) id<AnnotationItemCellDelegate>   delegate;
@property (nonatomic, retain) NSDictionary                  *info;
@property (nonatomic, retain) NSString                      *title;
@property (nonatomic, assign) NSInteger                     row;

@end

NS_ASSUME_NONNULL_END
