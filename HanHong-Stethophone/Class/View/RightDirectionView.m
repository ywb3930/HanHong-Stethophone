//
//  RightDirectionView.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import "RightDirectionView.h"

@interface RightDirectionView()

@property (retain, nonatomic) NSString          *title;

@property (retain, nonatomic) UIImageView       *imageViewRight;
@property (retain, nonatomic) UIView            *viewLine;

@end

@implementation RightDirectionView

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super init]) {
        self.title = title;
        [self initView];
        
        UITapGestureRecognizer *tapGestre = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [self addGestureRecognizer:tapGestre];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)actionTap:(UITapGestureRecognizer *)tap{
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)initView{
    [self addSubview:self.labelName];
    [self addSubview:self.labelInfo];
    [self addSubview:self.imageViewRight];
    [self addSubview:self.viewLine];
    self.labelName.sd_layout.leftSpaceToView(self, 0).topSpaceToView(self, 0).bottomSpaceToView(self, 0).widthIs(Ratio33);
    [self.labelName setSingleLineAutoResizeWithMaxWidth:Ratio135];
    self.imageViewRight.sd_layout.rightSpaceToView(self, 0).centerYEqualToView(self.labelName).widthIs(Ratio8).heightIs(Ratio13);
    self.labelInfo.sd_layout.leftSpaceToView(self.labelName, Ratio22).rightSpaceToView(self.imageViewRight, Ratio11).bottomSpaceToView(self, 0).centerYEqualToView(self.labelName);
    self.viewLine.sd_layout.leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(Ratio1).bottomSpaceToView(self, 0);
}

- (void)reloadView{
    self.labelName.sd_layout.leftSpaceToView(self, Ratio17);
    self.imageViewRight.sd_layout.rightSpaceToView(self, Ratio11);
    [self.labelName updateLayout];
    [self.imageViewRight updateLayout];
}

- (UILabel *)labelName{
    if(!_labelName) {
        _labelName = [[UILabel alloc] init];
        _labelName.font = Font15;
        _labelName.textColor = MainBlack;
        _labelName.text = self.title;
    }
    return _labelName;
}

- (UILabel *)labelInfo{
    if(!_labelInfo) {
        _labelInfo = [[UILabel alloc] init];
        _labelInfo.font = Font15;
        _labelInfo.textColor = MainBlack;
        _labelInfo.textAlignment = NSTextAlignmentRight;
    }
    return _labelInfo;
}

-(UIImageView *)imageViewRight{
    if(!_imageViewRight){
        _imageViewRight = [[UIImageView alloc] init];
        _imageViewRight.image = [UIImage imageNamed:@"enter_into"];
    }
    return _imageViewRight;
}


- (UIView *)viewLine{
    if(!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = ColorF5F5F5;
    }
    return _viewLine;
}

@end
