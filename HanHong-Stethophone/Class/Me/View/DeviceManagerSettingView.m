//
//  DeviceManagerSettingView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/19.
//

#import "DeviceManagerSettingView.h"
#import "ItemSwitchCell.h"
#import "UserInfoTwoCell.h"
#import "HHPopEditView.h"
#import "RecordSequenceVC.h"

@interface DeviceManagerSettingView()<UITableViewDelegate, UITableViewDataSource, ItemSwitchCellDelegaete,TTActionSheetDelegate, HHPopEditViewDelegate>

@property (retain, nonatomic) NSString          *filePath;


@end

@implementation DeviceManagerSettingView

- (void)actionSwitchChangeCallback:(Boolean)value cell:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSInteger row = indexPath.row;
    if (row == 0) {
        [self.settingData setObject:[@(value) stringValue] forKey:@"auto_connect_echometer"];
    } else if(row == 9) {
       if (self.recordingState == recordingState_ing || self.bStandart) {
            [kAppWindow makeToast:@"正在录音中，修改不能马上生效" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            ItemSwitchCell *switchCell = (ItemSwitchCell *)cell;
            switchCell.switchButton.on = NO;
            return;
        }
        [self.settingData setObject:[@(value) stringValue] forKey:@"auscultation_sequence"];
    } else if (row == 7) {
        if (self.recordingState == recordingState_ing || self.bStandart) {
             [kAppWindow makeToast:@"正在录音中，修改不能马上生效" duration:showToastViewWarmingTime position:CSToastPositionCenter];
             ItemSwitchCell *switchCell = (ItemSwitchCell *)cell;
             switchCell.switchButton.on = NO;
             return;
         }
        [self.settingData setObject:[@(value) stringValue] forKey:@"is_filtration_record"];
    }
    [self.settingData writeToFile:self.filePath atomically:YES];
    
}


- (void)actionClickCommnitCallback:(NSInteger)time tag:(NSInteger)tag{
    NSString *value = @"";
    Boolean saveDictionary = NO;
    if (tag == 4) {
        if(time<1 || time>30000000){
            [kAppWindow makeToast:@"范围值为：0-30000000" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        value = [NSString stringWithFormat:@"%li分钟", time];
        [[HHBlueToothManager shareManager] setAutoOffTime:(int)time];
        saveDictionary = NO;
    } else if(tag == 8) {
        
        value = [NSString stringWithFormat:@"%li秒", time];
        if (time < record_time_minimum || time > record_time_maximum) {
            NSString *message = [NSString stringWithFormat:@"录音时长为%i-%i秒", record_time_minimum, record_time_maximum];
            [kAppWindow makeToast:message duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        [self.settingData setObject:[@(time) stringValue] forKey:@"record_duration"];
        saveDictionary = YES;
    } else if(tag == 11) {
        value = [NSString stringWithFormat:@"%li秒", time];
        if (time < record_time_minimum || time > record_time_maximum) {
            NSString *message = [NSString stringWithFormat:@"录音时长为%i-%i秒", record_time_minimum, record_time_maximum];
            [kAppWindow makeToast:message duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        [self.settingData setObject:[@(time) stringValue] forKey:@"remote_record_duration"];
        saveDictionary = YES;
    }
    [self.arrayValue replaceObjectAtIndex:tag withObject:value];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (saveDictionary) {
        [self.settingData writeToFile:self.filePath atomically:YES];
    }
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    Boolean saveDictionary = NO;
    NSString *value =@"";
    if (tag == 1) {
        Boolean result = (index == 0) ? YES : NO;
        value = index == 0 ? @"开" : @"关";
        [[HHBlueToothManager shareManager] setAdvStartState:result];
        saveDictionary = NO;
    } else if(tag == 2) {
        NSArray *positionModeSeqArray = [[Constant shareManager] positionModeSeqArray];
        value = [positionModeSeqArray objectAtIndex:index];
        [[HHBlueToothManager shareManager] setModeSeq:(int)(index+1)];
        saveDictionary = NO;
    } else if(tag == 3) {
        NSArray *positionVolumesArray = [[Constant shareManager] positionVolumesArray];
        value = [positionVolumesArray objectAtIndex:index];
        [[HHBlueToothManager shareManager] setDefaultVolume:(int)(index + 1)];
        saveDictionary = NO;
    } else if(tag == 5) {
        value = (index == 0) ? @"干电池" : @"充电电池";
        NSInteger result = (index == 1) ? 0 : 1;
        [self.settingData setObject:[@(result) stringValue] forKey:@"battery_version"];
        saveDictionary = YES;
    } else if(tag == 6) {
        value = (index == 0) ? @"心音" : @"肺音";
        saveDictionary = YES;
        [self.settingData setObject:[@(index + 1) stringValue] forKey:@"quick_record_default_type"];
    }
    [self.arrayValue replaceObjectAtIndex:tag withObject:value];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if(saveDictionary) {
        [self.settingData writeToFile:self.filePath atomically:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (row == 1) {
        TTActionSheet *sheet = [TTActionSheet showActionSheet:@[@"开", @"关"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        sheet.tag = row;
        sheet.delegate = self;
        [sheet showInView:kAppWindow];
    } else if(row == 2) {
        TTActionSheet *sheet = [TTActionSheet showActionSheet:[[Constant shareManager] positionModeSeqArray] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        sheet.tag = row;
        sheet.delegate = self;
        [sheet showInView:kAppWindow];
    } else if(row == 3) {
        TTActionSheet *sheet = [TTActionSheet showActionSheet:[[Constant shareManager] positionVolumesArray] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        sheet.tag = row;
        sheet.delegate = self;
        [sheet showInView:kAppWindow];
    } else if(row == 4) {
        UserInfoTwoCell *cell = (UserInfoTwoCell *)[tableView cellForRowAtIndexPath:indexPath];
        HHPopEditView *editView = [[HHPopEditView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        editView.unit = @"分钟";
        editView.delegate = self;
        editView.tag = row;
        editView.defaultNumber = [self getNumberFromStr:cell.info];
        [kAppWindow addSubview:editView];
    } else if(row == 5) {
        TTActionSheet *sheet = [TTActionSheet showActionSheet:@[@"干电池", @"充电电池"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        sheet.tag = row;
        sheet.delegate = self;
        [sheet showInView:kAppWindow];
    } else if(row == 6) {
        TTActionSheet *sheet = [TTActionSheet showActionSheet:@[@"心音", @"肺音"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        sheet.tag = row;
        sheet.delegate = self;
        [sheet showInView:kAppWindow];
    } else if(row == 8) {
        if (self.recordingState == recordingState_ing) {
            [kAppWindow makeToast:@"正在录音中，不可以修改" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        HHPopEditView *editView = [[HHPopEditView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        editView.unit = @"秒";
        editView.tag = row;
        editView.delegate = self;
        UserInfoTwoCell *cell = (UserInfoTwoCell *)[tableView cellForRowAtIndexPath:indexPath];
        editView.defaultNumber = [self getNumberFromStr:cell.info];
        [kAppWindow addSubview:editView];
    } else if(row == 11) {
        HHPopEditView *editView = [[HHPopEditView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        editView.unit = @"秒";
        editView.tag = row;
        editView.delegate = self;
        UserInfoTwoCell *cell = (UserInfoTwoCell *)[tableView cellForRowAtIndexPath:indexPath];
        editView.defaultNumber = [self getNumberFromStr:cell.info];
        [kAppWindow addSubview:editView];
    } else if(row == 10){
        RecordSequenceVC *recordOrder = [[RecordSequenceVC alloc] init];
        recordOrder.settingData = self.settingData;
        UIViewController *currentVC = [Tools currentViewController];
        [currentVC.navigationController pushViewController:recordOrder animated:YES];
    }
}

- (NSString *)getNumberFromStr:(NSString *)str{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return[[str componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSString *type = self.arrayType[row];
    NSString *title = self.arrayTitle[row];
    NSString *value = self.arrayValue[row];
    if([type isEqualToString:@"0"]) {
        ItemSwitchCell *cell = (ItemSwitchCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ItemSwitchCell class])];
        cell.title = title;
        cell.value = value;
        cell.delegate = self;
        return cell;
    } else {
        UserInfoTwoCell *cell = (UserInfoTwoCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UserInfoTwoCell class])];
        cell.title = title;
        cell.info = value;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio50;;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = WHITECOLOR;
        self.filePath =  [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[ItemSwitchCell class] forCellReuseIdentifier:NSStringFromClass([ItemSwitchCell class])];
    [self registerClass:[UserInfoTwoCell class] forCellReuseIdentifier:NSStringFromClass([UserInfoTwoCell class])];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}





@end
