//
//  RecordFinishVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/30.
//

#import "RecordFinishVC.h"

@interface RecordFinishVC ()<UIGestureRecognizerDelegate>

@property (retain, nonatomic) UILabel               *labelSuccess;
@property (retain, nonatomic) YYLabel               *labelMessage;
@property (retain, nonatomic) UIButton              *buttonOk;
@property (retain, nonatomic) UIImageView           *imageViewOk;

@end

@implementation RecordFinishVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITECOLOR;
    [self setupView];
}

- (void)setRecordCount:(NSInteger)recordCount{
    NSString *title = [NSString stringWithFormat:@"你已完成了%li条记录, 请查看", recordCount];
    NSString *number = [NSString stringWithFormat:@"%li", recordCount];
    NSMutableAttributedString *atext= [[NSMutableAttributedString alloc]initWithString:title];
    NSRange numberRange = [[atext string] rangeOfString:number];
    atext.yy_font = Font13;
    atext.yy_color = MainGray;
    atext.yy_alignment = NSTextAlignmentCenter;
    [atext yy_setTextHighlightRange:numberRange color:MainColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        
    }];
    self.labelMessage.attributedText = atext;
}

- (void)setupView{
    [self.view addSubview:self.imageViewOk];
    [self.view addSubview:self.labelSuccess];
    [self.view addSubview:self.labelMessage];
    [self.view addSubview:self.buttonOk];
    
    self.imageViewOk.sd_layout.centerXEqualToView(self.view).topSpaceToView(self.view, screenH*0.3).widthIs(Ratio44).heightIs(Ratio44);
    self.labelSuccess.sd_layout.topSpaceToView(self.imageViewOk, Ratio11).heightIs(Ratio16).leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0);
    self.labelMessage.sd_layout.centerXEqualToView(self.view).heightIs(Ratio15).topSpaceToView(self.labelSuccess, Ratio18).widthIs(screenW);
    self.buttonOk.sd_layout.centerXEqualToView(self.view).heightIs(Ratio44).bottomSpaceToView(self.view, kBottomSafeHeight + Ratio22).widthIs(screenW - Ratio36);
    
}

- (UIImageView *)imageViewOk{
    if (!_imageViewOk) {
        _imageViewOk = [[UIImageView alloc] init];
        _imageViewOk.image = [UIImage imageNamed:@"check_true"];
    }
    return _imageViewOk;
}

- (UILabel *)labelSuccess{
    if (!_labelSuccess) {
        _labelSuccess = [[UILabel alloc] init];
        _labelSuccess.font = Font15;
        _labelSuccess.textColor = MainColor;
        _labelSuccess.textAlignment = NSTextAlignmentCenter;
        _labelSuccess.text = @"录音已完成";
    }
    return _labelSuccess;
}

- (YYLabel *)labelMessage{
    if (!_labelMessage) {
        _labelMessage = [[YYLabel alloc] init];
    }
    return _labelMessage;;
}

- (UIButton *)buttonOk{
    if (!_buttonOk) {
        _buttonOk = [[UIButton alloc] init];
        [_buttonOk setTitle:@"确定" forState:UIControlStateNormal];
        [_buttonOk setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonOk.backgroundColor = MainColor;
        _buttonOk.layer.cornerRadius = Ratio22;
        _buttonOk.clipsToBounds = YES;
        _buttonOk.titleLabel.font = Font15;
        [_buttonOk addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonOk;
}

- (void)actionBack:(UIButton *)button{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

@end
