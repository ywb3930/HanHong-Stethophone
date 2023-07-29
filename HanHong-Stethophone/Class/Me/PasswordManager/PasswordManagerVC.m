//
//  PasswordManagerVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import "PasswordManagerVC.h"
#import "ChangePasswordVC.h"
#import "ChangePhoneVC.h"
#import "ChangeEmailVC.h"

@interface PasswordManagerVC ()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UITableView               *tableView;
@property (retain, nonatomic) NSArray                   *arrayTitle;

@end

@implementation PasswordManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"密码管理";
    self.view.backgroundColor = WHITECOLOR;
    self.arrayTitle = @[@"修改密码", @"更换注册手机", @"修改注册邮箱"];
    [self initView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if(row == 0) {
        ChangePasswordVC *changePassword = [[ChangePasswordVC alloc] init];
        [self.navigationController pushViewController:changePassword animated:YES];
    } else if(row == 1) {
        ChangePhoneVC *changePhone = [[ChangePhoneVC alloc] init];
        [self.navigationController pushViewController:changePhone animated:YES];
    } else if(row == 2) {
        ChangeEmailVC *changeEmail = [[ChangeEmailVC alloc] init];
        [self.navigationController pushViewController:changeEmail animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.arrayTitle[indexPath.row];
    cell.textLabel.font = Font15;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio44;
}

- (void)initView{
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = WHITECOLOR;
        
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
