//
//  SettingDepartmentVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/15.
//

#import "SettingDepartmentVC.h"
#import "RightDirectionView.h"
#import "HMEditView.h"

@interface SettingDepartmentVC ()<UITableViewDelegate, UITableViewDataSource, HMEditViewDelegate>

@property (retain, nonatomic) UITableView                       *tableView;
@property (retain, nonatomic) NSArray                           *arrayData;
@property (retain, nonatomic) RightDirectionView                *directionView;

@end

@implementation SettingDepartmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"部门(科室)";
    self.view.backgroundColor = WHITECOLOR;
    self.arrayData = @[@"内科", @"外科", @"儿科", @"妇产科", @"肿瘤科", @"中医科"];
    [self initView];
}

- (void)actionEditInfoCallback:(NSString *)string idx:(NSInteger)idx{
    self.directionView.labelInfo.text = string;
    self.directionView.labelInfo.textColor = MainBlack;
    [self actionCallBack:string];
}


- (void)actionCallBack:(NSString *)string{
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSettingDepartmentCallback:)]) {
        [self.delegate actionSettingDepartmentCallback:string];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionTapGesture:(UITapGestureRecognizer *)tap{
    HMEditView *editView = [[HMEditView alloc] initWithTitle:@"输入科室" info:nil placeholder:@"请输入您的科室" idx:0];
    editView.delegate = self;
    [kAppWindow addSubview:editView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MyTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.arrayData[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:Ratio14];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *string = self.arrayData[indexPath.row];
    [self actionCallBack:string];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return Ratio55;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.directionView;
}

- (RightDirectionView *)directionView{
    if(!_directionView) {
        _directionView = [[RightDirectionView alloc] initWithTitle:@"其他"];
        _directionView.backgroundColor = WHITECOLOR;
        _directionView.labelName.font = [UIFont systemFontOfSize:Ratio14];
        
        _directionView.labelName.textColor = UIColor.blackColor;
        _directionView.labelInfo.text = @"请选择您的部门(科室)";
        _directionView.labelInfo.textColor = MainNormal;
        [_directionView reloadView];
        _directionView.userInteractionEnabled = YES;
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
        [_directionView addGestureRecognizer:tapGesture];
    }
    return _directionView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)initView{
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight, screenW, screenH - kNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = WHITECOLOR;
    }
    return _tableView;
}




@end
