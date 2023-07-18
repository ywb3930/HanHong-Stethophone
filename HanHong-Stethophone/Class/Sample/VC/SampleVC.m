//
//  SampleVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/12.
//

#import "SampleVC.h"
#import "RecordListVC.h"
#import "JXCategoryView.h"

@interface SampleVC ()<JXCategoryViewDelegate,UIScrollViewDelegate, RecordListVCDelegate>

@property (retain, nonatomic) JXCategoryTitleView           *categoryView;
@property (nonatomic, strong) UIScrollView                  *scrollView;
@property (retain, nonatomic) NSArray                       *titles;
@property (retain, nonatomic) NSArray                       *childVCs;
@property (assign, nonatomic) NSInteger                     selectIndex;

@property (retain, nonatomic) RecordListVC                  *localListVC;
@property (retain, nonatomic) RecordListVC                  *cloundListVC;
@property (retain, nonatomic) RecordListVC                  *collectListVC;
@property (retain, nonatomic) HHBluetoothButton             *bluetoothButton;
 //connected
@end

@implementation SampleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = WHITECOLOR;
    self.selectIndex = 0;
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.bluetoothButton];
    self.bluetoothButton.sd_layout.rightSpaceToView(self.view, Ratio11).widthIs(Ratio22).heightIs(Ratio22).topSpaceToView(self.view, kStatusBarHeight + Ratio5);
}

- (void)actionRecordListItemChange:(RecordModel *)model type:(NSInteger)type fromIndex:(NSInteger)fromIndex{
    if (fromIndex == 0 && type == 1) {
        [self.cloundListVC addCouldRecordItem:model];
    }
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index{
    if (index == 1 && !self.cloundListVC.bLoadData) {
        [self.cloundListVC initView];
        [self.cloundListVC initCouldData];
    } else if (index == 2 && !self.collectListVC.bLoadData) {
        [self.collectListVC initView];
        [self.collectListVC initCollectData];
    }
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [self.bluetoothButton star];
//}



- (HHBluetoothButton *)bluetoothButton{
    if(!_bluetoothButton) {
        _bluetoothButton = [[HHBluetoothButton alloc] init];
    }
    return _bluetoothButton;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(Ratio33, 0, screenW - Ratio66, kNavBarAndStatusBarHeight - Ratio4)];
        _categoryView.backgroundColor = WHITECOLOR;
        _categoryView.titles = self.titles;
        _categoryView.delegate = self;
        _categoryView.titleColor = MainNormal;//[UIColor blackColor];
        _categoryView.titleSelectedColor = MainBlack;//GKColorRGB(0, 0, 0);
        _categoryView.titleFont = Font15;
        _categoryView.titleSelectedFont = Font15;
    
        _categoryView.titleLabelVerticalOffset = kStatusBarHeight - Ratio15;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = MainColor;//indicatorLineViewColor
        lineView.indicatorWidth = Ratio55;//indicatorLineWidth
        lineView.indicatorHeight = Ratio2;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;//JXCategoryIndicatorLineStyle_JD;
        _categoryView.indicators = @[lineView];
        _categoryView.contentScrollView = self.scrollView;
        
    }
    return _categoryView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGFloat scrollW = screenW;
        CGFloat scrollH = screenH - kNavBarAndStatusBarHeight;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight , scrollW, scrollH)];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChildViewController:vc];
            [self.scrollView addSubview:vc.view];
            vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
            //self.selectIndex = idx;
        }];
        _scrollView.contentSize = CGSizeMake(self.childVCs.count * scrollW, 0);
    }
    return _scrollView;
}

- (NSArray *)childVCs{
    if (!_childVCs) {
        self.localListVC = [[RecordListVC alloc] init];
        self.localListVC.numberOfPage = 0;
        self.localListVC.string = @"本地录音";
        self.localListVC.delegate = self;
        [self.localListVC initView];
        [self.localListVC initLocalData];
        
        self.cloundListVC = [[RecordListVC alloc] init];
        self.cloundListVC.numberOfPage = 1;
        self.cloundListVC.delegate = self;
        self.cloundListVC.string = @"云标本库";
        
        self.collectListVC = [[RecordListVC alloc] init];
        self.collectListVC.numberOfPage = 2;
        self.collectListVC.delegate = self;
        self.collectListVC.string = @"我的收藏";
        _childVCs = @[self.localListVC, self.cloundListVC, self.collectListVC];
    }
    return _childVCs;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"本地录音", @"云标本库", @"我的收藏"];
    }
    return _titles;
}


@end
