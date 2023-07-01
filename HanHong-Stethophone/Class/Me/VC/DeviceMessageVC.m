//
//  DeviceMessageVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/29.
//

#import "DeviceMessageVC.h"
#import "DeviceMessageCell.h"

@interface DeviceMessageVC ()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UITableView           *tableView;
@property (retain, nonatomic) NSArray               *arrayTitle;
@property (retain, nonatomic) UIView                *viewBattery;
@property (retain, nonatomic) UIImageView           *imageViewBattery;
@property (retain, nonatomic) UILabel               *labelBattery;

@end

@implementation DeviceMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设备信息";
    self.view.backgroundColor = WHITECOLOR;
    self.arrayTitle =  @[@"产品名称：", @"产品型号：", @"产品序列号：", @"设备硬件版本：", @"设备软件版本：", @"生产日期：", @"有效期：", @"注册人地址：", @"售后服务单位：", @"联系电话：", @"网址："];
    [self setupView];
    [self initBatteryInfo];
    
}

- (void)initBatteryInfo{
    NSString *filePath =  [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:filePath];
    //[self.settingData setObject:[@(result) stringValue] forKey:@"battery_version"];
    NSString *batteryVersion = [data objectForKey:@"battery_version"];
    Boolean batteryType = ([batteryVersion integerValue] == 1) ? YES : NO;
    [[HHBlueToothManager shareManager] setBatteryType:batteryType];
    
    double batteryState = [[HHBlueToothManager shareManager] getBatteryState];
    //NSLog(@"batteryState = %f", batteryState);
    double result = ceil(batteryState);
    self.labelBattery.text = [NSString stringWithFormat:@"%i%%", (int)result];
    self.labelBattery.hidden = NO;
}

- (void)setupView{
    [self.view addSubview:self.tableView];
//    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    item0.width = Ratio11;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.viewBattery];
    self.navigationItem.rightBarButtonItem = item1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceMessageCell *cell = (DeviceMessageCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceMessageCell class])];
    NSInteger row = indexPath.row;
    cell.title = self.arrayTitle[row];
    cell.message = self.arrayData[row];
    if (row % 2 == 0) {
        cell.contentView.backgroundColor = ViewBackGroundColor;
    } else {
        cell.contentView.backgroundColor = WHITECOLOR;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *message = self.arrayData[indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:message keyPath:@"message" cellClass:[DeviceMessageCell class] contentViewWidth:screenW];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[DeviceMessageCell class] forCellReuseIdentifier:NSStringFromClass([DeviceMessageCell class])];
    }
    return _tableView;
}

- (UIView *)viewBattery{
    if (!_viewBattery) {
        _viewBattery = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Ratio66, Ratio33)];
        
        [_viewBattery addSubview:self.imageViewBattery];
        [_viewBattery addSubview:self.labelBattery];
    }
    return _viewBattery;
}

- (UIImageView *)imageViewBattery{
    if (!_imageViewBattery) {
        _imageViewBattery = [[UIImageView alloc] initWithFrame:CGRectMake(0, Ratio3, Ratio28, Ratio28)];
        _imageViewBattery.image = [UIImage imageNamed:@"battery"];
    }
    return _imageViewBattery;
}

- (UILabel *)labelBattery{
    if (!_labelBattery) {
        _labelBattery = [[UILabel alloc] initWithFrame:CGRectMake(Ratio33, 0, Ratio44, Ratio33)];
        _labelBattery.hidden = YES;
        _labelBattery.textColor = MainBlack;
        _labelBattery.font =Font13;
    }
    return _labelBattery;
}

@end
