//
//  LoginTypeVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/13.
//

#import "LoginTypeVC.h"
#import "TeachingTypeVC.h"

@interface LoginTypeVC ()

@property (retain, nonatomic) UIButton          *buttonPersonal;
@property (retain, nonatomic) UIButton          *buttonTeaching;
@property (retain, nonatomic) UIButton          *buttonUnion;

@end

@implementation LoginTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO  animated:YES];
}

- (void)actionPersonal:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
    NSDictionary *info = @{@"login_type": [@(login_type_personal) stringValue]};
    [[NSNotificationCenter defaultCenter] postNotificationName:login_type_broadcast object:nil userInfo:info];
}

- (void)actionTeaching:(UIButton *)button{
    TeachingTypeVC *teachingType = [[TeachingTypeVC alloc] init];
    [self.navigationController pushViewController:teachingType animated:YES];
}

- (void)actionUnion:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:YES];
    NSDictionary *info = @{@"login_type": [@(login_type_union) stringValue]};
    [[NSNotificationCenter defaultCenter] postNotificationName:login_type_broadcast object:nil userInfo:info];
}

- (void)initView{
    [self.view addSubview:self.buttonPersonal];
    [self.view addSubview:self.buttonTeaching];
    [self.view addSubview:self.buttonUnion];
    self.buttonPersonal.sd_layout.leftSpaceToView(self.view, Ratio22).rightSpaceToView(self.view, Ratio22).topSpaceToView(self.view, kNavBarAndStatusBarHeight + Ratio33).heightIs(Ratio99);
    self.buttonTeaching.sd_layout.leftEqualToView(self.buttonPersonal).rightEqualToView(self.buttonPersonal).heightIs(Ratio99).topSpaceToView(self.buttonPersonal, Ratio20);
    self.buttonUnion.sd_layout.leftEqualToView(self.buttonPersonal).rightEqualToView(self.buttonPersonal).heightIs(Ratio99).topSpaceToView(self.buttonTeaching, Ratio20);
}

- (UIButton *)buttonPersonal{
    if(!_buttonPersonal){
        _buttonPersonal = [self setButtonType:@"个人版"];
        _buttonPersonal.backgroundColor = MainColor;
        [_buttonPersonal addTarget:self action:@selector(actionPersonal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonPersonal;
}

- (UIButton *)buttonTeaching{
    if(!_buttonTeaching){
        _buttonTeaching = [self setButtonType:@"教学版"];
        _buttonTeaching.backgroundColor = AlreadyColor;
        [_buttonTeaching addTarget:self action:@selector(actionTeaching:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTeaching;
}

- (UIButton *)buttonUnion{
    if(!_buttonUnion){
        _buttonUnion = [self setButtonType:@"医联版"];
        _buttonUnion.backgroundColor = HEXCOLOR(0x00AAFF, 1);
        [_buttonUnion addTarget:self action:@selector(actionUnion:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonUnion;
}

- (UIButton *)setButtonType:(NSString *)info{
    UIButton *button = [[UIButton alloc] init];
    button.layer.cornerRadius = Ratio12;
    [button setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    [button setTitle:info forState:UIControlStateNormal];
    button.titleLabel.font = Font18;
    return button;
}

@end
