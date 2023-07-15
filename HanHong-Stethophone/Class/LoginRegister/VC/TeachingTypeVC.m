//
//  TeachingTypeVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/13.
//

#import "TeachingTypeVC.h"

@interface TeachingTypeVC ()

@property (retain, nonatomic) UIButton          *buttonTeacher;
@property (retain, nonatomic) UIButton          *buttonStudent;

@end

@implementation TeachingTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择身份";
    self.view.backgroundColor = WHITECOLOR;
    [self initView];
}

- (void)actionTeacher:(UIButton *)button{
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSDictionary *info = @{@"login_type": [@(login_type_teaching) stringValue], @"teaching_role": [@(Teacher_role) stringValue]};
    [[NSNotificationCenter defaultCenter] postNotificationName:login_type_broadcast object:nil userInfo:info];
}

- (void)actionStudent:(UIButton *)button{
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSDictionary *info = @{@"login_type": [@(login_type_teaching) stringValue], @"teaching_role": [@(Student_role) stringValue]};
    [[NSNotificationCenter defaultCenter] postNotificationName:login_type_broadcast object:nil userInfo:info];
}

- (void)initView{
    [self.view addSubview:self.buttonTeacher];
    [self.view addSubview:self.buttonStudent];
    self.buttonTeacher.sd_layout.leftSpaceToView(self.view, Ratio22).rightSpaceToView(self.view, Ratio22).topSpaceToView(self.view, kNavBarAndStatusBarHeight + Ratio55).heightIs(Ratio99);
    self.buttonStudent.sd_layout.leftEqualToView(self.buttonTeacher).rightEqualToView(self.buttonTeacher).heightIs(Ratio99).topSpaceToView(self.buttonTeacher, Ratio20);
}

- (UIButton *)buttonTeacher{
    if(!_buttonTeacher){
        _buttonTeacher = [[UIButton alloc] init];
        _buttonTeacher.backgroundColor = MainColor;
        _buttonTeacher.layer.cornerRadius = Ratio12;
        [_buttonTeacher setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        [_buttonTeacher setTitle:@"教授版" forState:UIControlStateNormal];
        _buttonTeacher.titleLabel.font = Font18;
        [_buttonTeacher addTarget:self action:@selector(actionTeacher:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTeacher;
}

- (UIButton *)buttonStudent{
    if(!_buttonStudent){
        _buttonStudent = [[UIButton alloc] init];
        _buttonStudent.backgroundColor = AlreadyColor;
        _buttonStudent.layer.cornerRadius = Ratio12;
        [_buttonStudent setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        [_buttonStudent setTitle:@"学生版" forState:UIControlStateNormal];
        _buttonStudent.titleLabel.font = Font18;
        [_buttonStudent addTarget:self action:@selector(actionStudent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonStudent;
}

@end
