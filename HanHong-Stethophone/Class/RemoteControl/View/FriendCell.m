//
//  FriendCell.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/21.
//

#import "FriendCell.h"

@interface FriendCell()

@property (retain, nonatomic) UIImageView               *imageViewHead;
@property (retain, nonatomic) UILabel                   *labelName;
@property (retain, nonatomic) UILabel                   *labelCommpany;
@property (retain, nonatomic) UILabel                   *labelDepartment;
@property (retain, nonatomic) UIButton                  *buttonRight;
@property (retain, nonatomic) UIButton                  *buttonLeft;
@property (retain, nonatomic) UILabel                   *labelMessage;
@property (retain, nonatomic) UILabel                   *labelStateTitle;
@property (retain, nonatomic) FriendModel               *currentModel;

@property (retain, nonatomic) UIButton                  *buttonClick;

@end

@implementation FriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)actionClickLeftButton:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionFriendDeneyCallback:)]) {
        [self.delegate actionFriendDeneyCallback:self.currentModel];
    }
}

- (void)actionButtonClick:(UIButton *)button{
    button.selected = !button.selected;
    self.currentModel.bSelected = button.selected;
}

- (void)actionClickRightButton:(UIButton *)button{
    if (button.tag == 1 && self.delegate && [self.delegate respondsToSelector:@selector(actionFriendApproveCallback:)]) {
        [self.delegate actionFriendApproveCallback:self.currentModel];
    } else if (button.tag == 2 && self.delegate && [self.delegate respondsToSelector:@selector(actionAddFriendCallback:)]) {
        [self.delegate actionAddFriendCallback:self.currentModel];
    }
}

- (void)setSearchModel:(FriendModel *)searchModel{
    [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:searchModel.avatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
    NSInteger state = searchModel.state;
    if (state < 0) {
        self.buttonLeft.hidden = YES;
        self.buttonRight.hidden = NO;
        self.labelMessage.hidden = YES;
        self.buttonRight.tag = 2;
        [self.buttonRight setTitle:@"添加" forState:UIControlStateNormal];
        self.labelCommpany.sd_layout.rightSpaceToView(self.buttonRight, Ratio6);
    } else if (state == 0) {
        self.buttonLeft.hidden = YES;
        self.buttonRight.hidden = YES;
        self.labelMessage.hidden = NO;
        self.labelMessage.text = @"您已发出好友请求";
        self.labelMessage.sd_layout.rightSpaceToView(self.labelMessage, Ratio11);
        [self.labelCommpany updateLayout];
    } else if (state == 1) {
        self.buttonLeft.hidden = YES;
        self.buttonRight.hidden = YES;
        self.labelMessage.hidden = NO;
        self.labelMessage.text = @"对方已是您的好友";
        self.labelCommpany.sd_layout.rightSpaceToView(self.labelMessage, Ratio11);
    } else if (state == 2) {
        self.buttonLeft.hidden = YES;
        self.buttonRight.hidden = NO;
        self.labelMessage.hidden = YES;
        self.buttonRight.tag = 2;
        [self.buttonRight setTitle:@"添加" forState:UIControlStateNormal];
        self.labelCommpany.sd_layout.rightSpaceToView(self.buttonRight, Ratio6);
        
    }
    [self showLabelMessage:searchModel];
    NSString *text = self.labelMessage.text;
    CGFloat width = [Tools widthForString:text fontSize:Ratio13 andHeight:Ratio15];
    self.labelMessage.sd_layout.widthIs(width);
    [self.labelMessage updateLayout];
    [self.labelCommpany updateLayout];
}

- (void)showLabelMessage:(FriendModel *)model{
    self.currentModel = model;
    NSString *name = model.name;
    NSInteger role = model.role;
    
    if (role == CommUser_role) {
        self.labelCommpany.text = model.company;
        self.labelDepartment.text = model.department;
    } else if (role == Student_role) {
        self.labelCommpany.text = model.academy;
        self.labelDepartment.text = model.class;
        name = [NSString stringWithFormat:@"%@学生",name];
    } else if (role == Teacher_role) {
        self.labelCommpany.text = model.academy;
        self.labelDepartment.text = model.class;
        name = [NSString stringWithFormat:@"%@教授",name];
    }
    
    self.labelName.text = name;
    
}






- (void)setFriendModel:(FriendModel *)friendModel{
    [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:friendModel.avatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
    [self showLabelMessage:friendModel];
    self.buttonClick.selected = friendModel.bSelected;
}

- (void)setFriendNewModel:(FriendModel *)friendNewModel{
    [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:friendNewModel.avatar] placeholderImage:nil options:SDWebImageQueryMemoryData];
    
    
    NSInteger state = friendNewModel.state;
    NSInteger type = friendNewModel.type;//0：别人的请求；1：我的请求
    [self showLabelMessage:friendNewModel];
    
    if (type == 0) {//好友发出的请求
        if (state == 0) {
            self.buttonLeft.hidden = NO;
            self.buttonRight.tag = 1;
            self.buttonRight.hidden = NO;
            self.labelMessage.hidden = YES;
            self.labelStateTitle.hidden = NO;
            self.labelCommpany.sd_layout.rightSpaceToView(self.buttonRight, Ratio6);
           
        } else {
            self.buttonLeft.hidden = YES;
            self.buttonRight.hidden = YES;
            self.labelMessage.hidden = NO;
            self.labelStateTitle.hidden = YES;
            if (state == 1) {
                self.labelMessage.text = @"您通过了好友请求";
            } else if (state == 2) {
                self.labelMessage.text = @"您未通过好友请求";
            } else {
                self.labelStateTitle.text = @"好友请求";
            }
            self.labelCommpany.sd_layout.rightSpaceToView(self.labelMessage, Ratio11);
        }
    } else { //我发出的请求
        self.buttonLeft.hidden = YES;
        self.buttonRight.hidden = YES;
        self.labelMessage.hidden = NO;
        self.labelStateTitle.hidden = YES;
        
        if (state == 0) {
            self.labelMessage.text = @"等待好友通过";
        } else if (state == 1) {
            self.labelMessage.text = @"好友请求已通过";
        } else if (state == 2) {
            self.labelMessage.text = @"好友请求不通过";
        }
        self.labelCommpany.sd_layout.rightSpaceToView(self.labelMessage, Ratio11);
       
    }
    NSString *text = self.labelMessage.text;
    CGFloat width = [Tools widthForString:text fontSize:Ratio13 andHeight:Ratio15];
    self.labelMessage.sd_layout.widthIs(width);
    [self.labelMessage updateLayout];
    [self.labelCommpany updateLayout];
}

- (void)setBShowCheck:(Boolean)bShowCheck{
    self.buttonClick.hidden = !bShowCheck;
    if(bShowCheck) {
        self.buttonClick.sd_layout.widthIs(Ratio33);
    } else {
        self.buttonClick.sd_layout.widthIs(0);
    }
    
    [self.buttonClick updateLayout];
}

- (void)setupView{
    [self.contentView addSubview:self.buttonClick];
    [self.contentView addSubview:self.imageViewHead];
    [self.contentView addSubview:self.labelMessage];
    [self.contentView addSubview:self.labelName];
    [self.contentView addSubview:self.labelCommpany];
    [self.contentView addSubview:self.labelDepartment];
    [self.contentView addSubview:self.buttonLeft];
    [self.contentView addSubview:self.buttonRight];
    [self.contentView addSubview:self.labelStateTitle];
    
    self.buttonClick.sd_layout.leftSpaceToView(self.contentView, Ratio11).heightIs(Ratio33).widthIs(0).centerYEqualToView(self.contentView);
    self.imageViewHead.sd_layout.leftSpaceToView(self.buttonClick, Ratio5).topSpaceToView(self.contentView, Ratio17).heightIs(Ratio50).widthIs(Ratio50);
    self.buttonRight.sd_layout.rightSpaceToView(self.contentView, Ratio11).centerYEqualToView(self.imageViewHead).heightIs(Ratio22).widthIs(Ratio44);
    self.buttonLeft.sd_layout.rightSpaceToView(self.buttonRight, Ratio6).centerYEqualToView(self.buttonRight).heightIs(Ratio22).widthIs(Ratio44);
    self.labelMessage.sd_layout.centerYEqualToView(self.imageViewHead).heightIs(Ratio16).rightSpaceToView(self.contentView, Ratio11).widthIs(0);
    self.labelCommpany.sd_layout.leftEqualToView(self.labelName).rightSpaceToView(self.labelMessage, Ratio5).centerYEqualToView(self.imageViewHead).autoHeightRatio(0);

    self.labelName.sd_layout.leftSpaceToView(self.imageViewHead, Ratio15).rightSpaceToView(self.contentView, Ratio15).bottomSpaceToView(self.labelCommpany, Ratio3).heightIs(Ratio17);
    
    //[self.labelCommpany setSingleLineAutoResizeWithMaxWidth:screenW-Ratio99];
    self.labelDepartment.sd_layout.leftEqualToView(self.labelName).rightEqualToView(self.labelName).topSpaceToView(self.labelCommpany, Ratio3).heightIs(Ratio16);
    

    self.labelStateTitle.sd_layout.rightSpaceToView(self.contentView, Ratio11).heightIs(Ratio16).widthIs(Ratio55).bottomSpaceToView(self.buttonRight, Ratio3);
    
    [self setupAutoHeightWithBottomView:self.labelDepartment bottomMargin:Ratio11];

}

- (UIImageView *)imageViewHead{
    if (!_imageViewHead) {
        _imageViewHead = [[UIImageView alloc] init];
        _imageViewHead.backgroundColor = HEXCOLOR(0xE5E5E5, 0.7);
        _imageViewHead.contentMode = UIViewContentModeScaleAspectFit;
        _imageViewHead.layer.cornerRadius = Ratio5;
        _imageViewHead.clipsToBounds = YES;
    }
    return _imageViewHead;
}

- (UILabel *)labelName{
    if (!_labelName) {
        _labelName = [[UILabel alloc] init];
        _labelName.font = [UIFont systemFontOfSize:Ratio15 weight:UIFontWeightBold];
        _labelName.textColor = MainBlack;
    }
    return _labelName;
}

- (UILabel *)labelCommpany{
    if (!_labelCommpany) {
        _labelCommpany = [[UILabel alloc] init];
        _labelCommpany.font = Font13;
        _labelCommpany.textColor = MainBlack;
        _labelCommpany.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _labelCommpany;
}

- (UILabel *)labelDepartment{
    if (!_labelDepartment) {
        _labelDepartment = [[UILabel alloc] init];
        _labelDepartment.font = Font13;
        _labelDepartment.textColor = MainGray;
    }
    return _labelDepartment;
}

- (UILabel *)labelMessage{
    if (!_labelMessage) {
        _labelMessage = [[UILabel alloc] init];
        _labelMessage.font = Font13;
        _labelMessage.textColor = MainGray;
        _labelMessage.textAlignment = NSTextAlignmentRight;
        _labelMessage.hidden = YES;
        _labelMessage.numberOfLines = 0;
        
    }
    return _labelMessage;
}

- (UIButton *)buttonRight{
    if (!_buttonRight) {
        _buttonRight = [self setupButton];
        [_buttonRight setTitle:@"通过" forState:UIControlStateNormal];
        [_buttonRight addTarget:self action:@selector(actionClickRightButton:) forControlEvents:UIControlEventTouchUpInside];
        _buttonRight.hidden = YES;
    }
    return _buttonRight;
}

- (UILabel *)labelStateTitle{
    if (!_labelStateTitle) {
        _labelStateTitle = [[UILabel alloc] init];
        _labelStateTitle.text = @"好友请求";
        _labelStateTitle.font = Font13;
        _labelStateTitle.textColor = MainGray;
        _labelStateTitle.hidden = YES;
        _labelStateTitle.textAlignment = NSTextAlignmentRight;
    }
    return _labelStateTitle;
}

- (UIButton *)buttonLeft{
    if (!_buttonLeft) {
        _buttonLeft = [self setupButton];
        [_buttonLeft setTitle:@"不通过" forState:UIControlStateNormal];
        [_buttonLeft addTarget:self action:@selector(actionClickLeftButton:) forControlEvents:UIControlEventTouchUpInside];
        _buttonLeft.hidden = YES;
    }
    return _buttonLeft;
}

- (UIButton *)setupButton{
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = MainColor;
    button.layer.cornerRadius = Ratio5;
    [button setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    button.titleLabel.font = Font13;
    return button;
}

- (UIButton *)buttonClick{
    if (!_buttonClick) {
        _buttonClick = [[UIButton alloc] init];
        [_buttonClick setImage:[UIImage imageNamed:@"check_false"] forState:UIControlStateNormal];
        [_buttonClick setImage:[UIImage imageNamed:@"check_true"] forState:UIControlStateSelected];
        _buttonClick.imageEdgeInsets = UIEdgeInsetsMake(Ratio5, Ratio5, Ratio5, Ratio5);
        _buttonClick.hidden = YES;
        [_buttonClick addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonClick;
}

@end
