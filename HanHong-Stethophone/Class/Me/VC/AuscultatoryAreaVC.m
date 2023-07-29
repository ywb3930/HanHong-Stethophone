//
//  AuscultatoryAreaVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/28.
//

#import "AuscultatoryAreaVC.h"

@interface AuscultatoryAreaVC ()

@property (retain, nonatomic) NSArray                   *arrayData;
@property (retain, nonatomic) NSMutableArray            *arrayButtons;


@property (retain, nonatomic) UILabel                   *labelMessage;
@property (retain, nonatomic) NSArray                   *arraySelect;

@end

@implementation AuscultatoryAreaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    [self initData];
    [self setupView];
}

- (void)actionButtonClick:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        button.layer.borderWidth = 0;
        button.backgroundColor = MainColor;
        [self.arraySelectButtons addObject:button];
        
    } else {
        button.layer.borderWidth = 1;
        button.backgroundColor = WHITECOLOR;
        if ([self.arraySelectButtons containsObject:button]) {
            [self.arraySelectButtons removeObject:button];
        }
    }
    [self reloadView];
}

- (void)resetView{
    self.arraySelectButtons = [NSMutableArray array];
    for (UIButton *button in self.arrayButtons) {
        button.layer.borderWidth = 1;
        button.backgroundColor = WHITECOLOR;
        button.selected = NO;
    }
    [self reloadView];
}

- (void)reloadView{
    NSString *string = @"";
    for (UIButton *button in self.arraySelectButtons) {
        if (button.selected) {
            string = [NSString stringWithFormat:@"%@%@→", string,button.titleLabel.text];
        }
    }
    if (string.length > 0) {
        string = [string substringToIndex:string.length - 1];
        
    }
    self.labelMessage.text = string;
}

- (void)initData{
    self.arrayButtons = [NSMutableArray array];
    self.arraySelectButtons = [NSMutableArray array];
    if (self.idx == 0) {
        self.arrayData = heart_positions;
        self.arraySelect = [self.settingData objectForKey:@"heartReordSequence"];//录音顺序 心音顺序
    } else if (self.idx == 1){
        self.arrayData = lung_positions;
        self.arraySelect = [self.settingData objectForKey:@"lungReordSequence"];//录音顺序 肺音顺序
    }
    NSLog(@"self.arraySelect = %@", self.arraySelect);
}

- (void)setupView{
    CGFloat buttonWidth = (screenW - Ratio44)/2;
    UIButton *lastButton;
    for (NSInteger i = 0; i < self.arrayData.count; i++) {
        NSInteger ii = i % 2;
        NSInteger jj = i / 2;
        UIButton *button = [self setupButton:[self.arrayData objectAtIndex:i]];
        button.tag = i + 1;
        [self.arrayButtons addObject:button];
        [button addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button.sd_layout.leftSpaceToView(self.view, Ratio18 + (buttonWidth + Ratio8) * ii).heightIs(Ratio44).widthIs(buttonWidth).topSpaceToView(self.view, Ratio22 + Ratio52*jj);
        if (i == self.arrayData.count - 1) {
            lastButton = button;
        }
        for (NSInteger j = 0; j < self.arraySelect.count; j++) {
            NSDictionary *data = self.arraySelect[j];
            NSInteger tag = [data[@"id"] integerValue];
            if (tag == i) {
                button.selected = YES;
                button.layer.borderWidth = 0;
                button.backgroundColor = MainColor;
                [self.arraySelectButtons addObject:button];
            }
        }
    }
    [self reloadView];

    [self.view addSubview:self.labelMessage];
    self.labelMessage.sd_layout.leftSpaceToView(self.view, Ratio22).rightSpaceToView(self.view, Ratio22).topSpaceToView(lastButton, Ratio33).autoHeightRatio(0);;
}



- (UIButton *)setupButton:(NSString *)title{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitleColor:MainBlack forState:UIControlStateNormal];
    [button setTitleColor:WHITECOLOR forState:UIControlStateSelected];
    button.backgroundColor = WHITECOLOR;
    button.titleLabel.font = Font13;
    button.layer.cornerRadius = Ratio5;
    button.layer.borderWidth = Ratio1;
    button.layer.borderColor = PlaceholderColor.CGColor;
    return button;
}


- (UILabel *)labelMessage{
    if (!_labelMessage) {
        _labelMessage = [[UILabel alloc] init];
        _labelMessage.textColor = MainColor;
        _labelMessage.font = Font15;
        _labelMessage.numberOfLines = 0;
    }
    return _labelMessage;
}

@end
