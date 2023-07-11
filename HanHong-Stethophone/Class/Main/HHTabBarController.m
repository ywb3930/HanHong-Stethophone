//
//  TTTabBarController.m
//  HuiGaiChe
//
//  Created by Zhilun on 2020/4/24.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import "HHTabBarController.h"
#import "HHNavigationController.h"
#import "OrgModel.h"

#define TabbarVC    @"vc"
#define TabbarTitle @"title"
#define TabbarImage @"image"
#define TabbarSelectedImage @"selectedImage"
#define TabBarCount 4

typedef NS_ENUM(NSInteger, HHMainTabType){
    HHRecordTabType,//首页
    HHSampleTabType,//购物车
    HHRemoteControlTabType,//订单VC
    HHMeTabType//我的
};

@implementation HHTabBarItem

@end

@interface HHTabBarController ()<UITabBarControllerDelegate>

@property (nonatomic,copy)   NSDictionary           *configs;

@property (assign, nonatomic) NSInteger             login_type;
@property (assign, nonatomic) NSInteger             teaching_role;
@property (retain, nonatomic) NSString              *org;
@property (retain, nonatomic) NSString              *org_name;
@property (retain, nonatomic) NSString              *org_short_name;

@end

@implementation HHTabBarController

+ (instancetype)instance{
    UIViewController *vc = kAppWindow.rootViewController;
    kAppWindow.backgroundColor = WHITECOLOR;
    if([vc isKindOfClass:[HHTabBarController class]]){
        return (HHTabBarController *)vc;
    } else {
        return nil;
    }
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
//    UINavigationController *navCtrl = (UINavigationController *)viewController;
//
//    UIViewController *rootCtrl = navCtrl.topViewController;
//    if ([rootCtrl isKindOfClass:[ShopCartVC class]] || [rootCtrl isKindOfClass:[OrderVC class]]) {
//        if (LoginData) {
//            return YES;
//        } else {
//            [self actionToLoginView];
//            return NO;
//        }
//
//    }
    return YES;
}
//



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        window.backgroundColor = WHITECOLOR;
     } else {
         [UIApplication sharedApplication].keyWindow.backgroundColor = UIColor.whiteColor;
     }
    //self.selectedIndex = tabba
    self.delegate = self;
    [self initData];
    [self initTabBar];
}

- (void)initData{
    self.login_type = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_type"];
    self.teaching_role = [[NSUserDefaults standardUserDefaults] integerForKey:@"teach_role"];
    if (self.login_type == login_type_personal) {
        self.org = @"hanhong";
        self.org_name = @"广东汉泓医疗科技有限公司";
        self.org_short_name = @"汉泓";
    } else {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"orgModelLogin"];
        OrgModel *orgModel = (OrgModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.org = orgModel.code;
        self.org_name = orgModel.name;
        self.org_short_name = orgModel.short_name;

    }
    
}

- (NSArray*)tabbars{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSInteger tabbar = 0; tabbar < TabBarCount; tabbar++) {
        [items addObject:@(tabbar)];
    }
    return items;
}


- (void)initTabBar{
    if (@available(iOS 13.0, *)) {
        [[UITabBar appearance] setBarTintColor:UIColor.systemBackgroundColor];
    } else {
        [[UITabBar appearance] setBarTintColor:UIColor.whiteColor];
    }
    
    [UITabBar appearance].translucent = NO;
    NSMutableArray *vcArray = [[NSMutableArray alloc] init];
    //UIColor *color = [UIColor colorWithRed:0.235f green:0.847f blue:0.941f alpha:1.0f];
    [self.tabbars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * item =[self vcInfoForTabType:[obj integerValue]];
        NSString *vcName = item[TabbarVC];
        NSString *title  = item[TabbarTitle];
        NSString *imageName = item[TabbarImage];
        NSString *imageSelected = item[TabbarSelectedImage];
        Class clazz = NSClassFromString(vcName);
        UIViewController *vc = [[clazz alloc] init];
        vc.hidesBottomBarWhenPushed = NO;
        HHNavigationController *nav = [[HHNavigationController alloc] initWithRootViewController:vc];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:imageSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        nav.tabBarItem.tag = idx;
        
        
        if (@available(iOS 13.0, *))  {
            UIColor *textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if ([traitCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return MainNormal;
                } else {
                    return MainGray;
                }
            }];
            [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:textColor,NSFontAttributeName:Font11} forState:UIControlStateNormal];
        } else {
            [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:MainGray,NSFontAttributeName:Font11} forState:UIControlStateNormal];
        }
        
        [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:MainColor,NSFontAttributeName:Font11} forState:UIControlStateSelected];
        
        [vcArray addObject:nav];
    }];
    
    self.viewControllers = [NSArray arrayWithArray:vcArray];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HEXCOLOR(0xFAFAFA, 1);
    view.frame = CGRectMake(0, 0, screenW, kTabBarHeight + Ratio1);
    [[UITabBar appearance] insertSubview:view atIndex:0];
    
    
}
//RecordVC LungVoiceVC
#pragma mark - VC
- (NSDictionary *)vcInfoForTabType:(HHMainTabType)type{
    if (_configs == nil)
    {
        if (self.login_type == login_type_teaching) {
            if (self.teaching_role == Teacher_role) {
                _configs = @{
                     @(HHRecordTabType) : @{TabbarVC: @"RecordVC",TabbarTitle: @"录音",TabbarImage: @"tab_record_normal",TabbarSelectedImage: @"tab_record_press"},
                     @(HHSampleTabType): @{TabbarVC: @"SampleVC",TabbarTitle: @"标本库",TabbarImage: @"tab_history_normal",TabbarSelectedImage : @"tab_history_press"},
                     @(HHRemoteControlTabType)     : @{TabbarVC: @"RemoteControlTeacherVC",TabbarTitle: @"听诊教学",TabbarImage: @"tab_telemedicine_normal",TabbarSelectedImage :@"tab_telemedicine_press"
                         },
                     @(HHMeTabType)     : @{TabbarVC: @"MeVC",TabbarTitle: @"个人中心",TabbarImage: @"tab_me_normal",TabbarSelectedImage : @"tab_me_press"
                         }
                     };
            } else if (self.teaching_role == Student_role) {
                _configs = @{
                     @(HHRecordTabType) : @{TabbarVC: @"RecordVC",TabbarTitle: @"录音",TabbarImage: @"tab_record_normal",TabbarSelectedImage: @"tab_record_press"},
                     @(HHSampleTabType): @{TabbarVC: @"SampleVC",TabbarTitle: @"标本库",TabbarImage: @"tab_history_normal",TabbarSelectedImage : @"tab_history_press"},
                     @(HHRemoteControlTabType)     : @{TabbarVC: @"RemoteControlStudentVC",TabbarTitle: @"听诊学习",TabbarImage: @"tab_telemedicine_normal",TabbarSelectedImage :@"tab_telemedicine_press"
                         },
                     @(HHMeTabType)     : @{TabbarVC: @"MeVC",TabbarTitle: @"个人中心",TabbarImage: @"tab_me_normal",TabbarSelectedImage : @"tab_me_press"
                         }
                     };
            }
        } else {
            _configs = @{
                 @(HHRecordTabType) : @{TabbarVC: @"RecordVC",TabbarTitle: @"录音",TabbarImage: @"tab_record_normal",TabbarSelectedImage: @"tab_record_press"},
                 @(HHSampleTabType): @{TabbarVC: @"SampleVC",TabbarTitle: @"标本库",TabbarImage: @"tab_history_normal",TabbarSelectedImage : @"tab_history_press"},
                 @(HHRemoteControlTabType)     : @{TabbarVC: @"RemoteControlVC",TabbarTitle: @"远程会诊",TabbarImage: @"tab_telemedicine_normal",TabbarSelectedImage :@"tab_telemedicine_press"
                     },
                 @(HHMeTabType)     : @{TabbarVC: @"MeVC",TabbarTitle: @"个人中心",TabbarImage: @"tab_me_normal",TabbarSelectedImage : @"tab_me_press"
                     }
                 };
        }
        
        
    }
    return _configs[@(type)];
}

@end
