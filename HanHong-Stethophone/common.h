//
//  common.h
//  HuiGaiChe
//
//  Created by Zhilun on 2020/4/24.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#ifndef common_h
#define common_h

#import <YYText.h>
#import <SDAutoLayout.h>
#import <SDWebImage.h>
#import <AFNetworking.h>
//#import "MJRefresh.h"
#import <YYModel.h>
#import <Toast.h>
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>
#import "AFNetRequestManager.h"
#import "TTRequestManager.h"
#import "Tools.h"
#import "HHLoginManager.h"
#import "Reachability.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
//#import <GKNavigationBarViewController/GKNavigationBarViewController.h>
#import <Photos/Photos.h>
#import "ReactiveObjC.h"
#import <FMDB.h>
#import "MLAlertView.h"
#import "TTActionSheet.h"
#import "UIButton+ImagePosition.h"
#import "HHFileLocationHelper.h"
#import "HHBlueToothManager.h"
#import "Constant.h"
#import "RecordModel.h"
#import "HHBluetoothButton.h"
#import "HHDBHelper.h"
#import "NoDataView.h"
#import "MeetingRoom.h"
#import "MBProgressHUD.h"
#ifdef DEBUG
static DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static DDLogLevel ddLogLevel = DDLogLevelOff;
#endif

#ifdef DEBUG
#define DLog(format, ...) DDLogError((@"[函数名:%s]" "[行号:%d]-------" format), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...);
#endif


#endif /* common_h */
