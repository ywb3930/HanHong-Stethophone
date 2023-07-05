//
//  NoDataView.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/5.
//

#import "NoDataView.h"

@interface NoDataView()

@property (retain, nonatomic) UIImageView               *imageViewNoData;
@property (retain, nonatomic) UILabel                   *labelNoData;

@end

@implementation NoDataView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    [self addSubview:self.imageViewNoData];
    [self addSubview:self.labelNoData];
    self.imageViewNoData.sd_layout.centerXEqualToView(self).centerXIs(self.frame.size.height/2-Ratio44).widthIs(screenW/2).heightIs(screenW/2);
    self.labelNoData.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio16).topSpaceToView(self.imageViewNoData, 0);
}

- (UIImageView *)imageViewNoData{
    if (!_imageViewNoData) {
        _imageViewNoData = [[UIImageView alloc] init];
        _imageViewNoData.image = [UIImage imageNamed:@"no-data"];
    }
    return _imageViewNoData;
}

- (UILabel *)labelNoData{
    if (!_labelNoData) {
        _labelNoData = [[UILabel alloc] init];
        _labelNoData.textAlignment = NSTextAlignmentCenter;
        _labelNoData.text = @"暂时还没有数据";
        _labelNoData.textColor = MainNormal;
        _labelNoData.font = Font15;
    }
    return _labelNoData;
}

@end
