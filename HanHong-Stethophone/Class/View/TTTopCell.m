//
//  TTTopCell.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "TTTopCell.h"

@interface TTTopCell()


@property (retain, nonatomic) UILabel       *lblName;

@end

@implementation TTTopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setName:(NSString *)name{
    self.lblName.text = name;
}

- (void)setColor:(UIColor *)color{
    self.lblName.textColor = color;
}

- (void)setupView{
    self.contentView.backgroundColor = WHITECOLOR;
    [self.contentView addSubview:self.lblName];
    self.lblName.sd_layout.leftSpaceToView(self.contentView, 0).topSpaceToView(self.contentView, 0).rightSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0);
}

- (UILabel *)lblName{
    if (!_lblName) {
        _lblName = [[UILabel alloc] init];
        _lblName.textColor = MainBlack;
        _lblName.font = Font15;
        _lblName.textAlignment = NSTextAlignmentCenter;
        
    }
    return _lblName;
}

@end
