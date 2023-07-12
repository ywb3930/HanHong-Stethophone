//
//  RecordSequenceVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/28.
//

#import "RecordSequenceVC.h"
#import "AuscultatoryAreaVC.h"
#import "JXCategoryView.h"

@interface RecordSequenceVC ()<JXCategoryViewDelegate>

@property (retain, nonatomic) AuscultatoryAreaVC     *heartAreaVC;
@property (retain, nonatomic) AuscultatoryAreaVC     *lungAreaVC;

@property (retain, nonatomic) JXCategoryTitleView           *categoryView;
@property (nonatomic, strong) UIScrollView                  *scrollView;
@property (retain, nonatomic) NSArray                       *titles;
@property (retain, nonatomic) NSArray                       *childVCs;
@property (assign, nonatomic) NSInteger                     selectIndex;
@property (retain, nonatomic) UIButton                      *buttonCommit;

@end

@implementation RecordSequenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"录音顺序";
    self.view.backgroundColor = WHITECOLOR;
    
    self.selectIndex = 0;
    [self setupView];
}

- (void)actionToCommit:(UIButton *)button{
    NSMutableArray *arrayHeartSequence = [NSMutableArray array];
    if (self.heartAreaVC.arraySelectButtons.count > 0){
        for (UIButton *button in self.heartAreaVC.arraySelectButtons) {
            [arrayHeartSequence addObject:@{@"id": [@(button.tag-1) stringValue], @"name": button.titleLabel.text}];
        }
    }
    NSMutableArray *arrayLungSequence = [NSMutableArray array];
    if (self.lungAreaVC.arraySelectButtons.count > 0){
        for (UIButton *button in self.lungAreaVC.arraySelectButtons) {
            [arrayLungSequence addObject:@{@"id": [@(button.tag-1) stringValue], @"name": button.titleLabel.text}];
        }
    }
    NSString *filePath =  [[Constant shareManager] getPlistFilepathByName:@"deviceManager.plist"];
    [self.settingData setObject:arrayHeartSequence forKey:@"heartReorcSequence"];//录音顺序 心音顺序
    [self.settingData setObject:arrayLungSequence forKey:@"lungReorcSequence"];//录音顺序 肺音顺序
    [self.settingData writeToFile:filePath atomically:YES];
   
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionToReset:(UIButton *)button{
    if (self.selectIndex == 0) {
        [self.heartAreaVC resetView];
    } else if (self.selectIndex == 1) {
        [self.lungAreaVC resetView];
    }
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index{
    self.selectIndex = index;
}

- (void)setupView{
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;

    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reset"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItems = @[item0,item2];
    item2.action = @selector(actionToReset:);
    
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.scrollView];
    
    [self.view addSubview:self.buttonCommit];
    self.buttonCommit.sd_layout.centerXEqualToView(self.view).bottomSpaceToView(self.view, kBottomSafeHeight + Ratio22).heightIs(Ratio33).widthIs(Ratio66);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight, screenW, Ratio44)];
        _categoryView.backgroundColor = WHITECOLOR;
        _categoryView.titles = self.titles;
        _categoryView.delegate = self;
        _categoryView.titleColor = MainNormal;//[UIColor blackColor];
        _categoryView.titleSelectedColor = MainBlack;//GKColorRGB(0, 0, 0);
        _categoryView.titleFont = Font15;
        _categoryView.titleSelectedFont = Font15;
    
        
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
        CGFloat scrollH = screenH - kNavBarAndStatusBarHeight - Ratio44 - kBottomSafeHeight - Ratio55;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, Ratio44 + kNavBarAndStatusBarHeight , scrollW, scrollH)];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = UIColor.redColor;
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
        self.heartAreaVC = [[AuscultatoryAreaVC alloc] init];
        self.heartAreaVC.settingData = self.settingData;
        self.heartAreaVC.idx = 0;
        self.lungAreaVC = [[AuscultatoryAreaVC alloc] init];
        self.lungAreaVC.idx = 1;
        self.lungAreaVC.settingData = self.settingData;
        _childVCs = @[self.heartAreaVC, self.lungAreaVC];
    }
    return _childVCs;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"心音顺序", @"肺音顺序"];
    }
    return _titles;
}


- (UIButton *)buttonCommit{
    if (!_buttonCommit) {
        _buttonCommit = [[UIButton alloc] init];
        [_buttonCommit setTitle:@"确定" forState:UIControlStateNormal];
        [_buttonCommit setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        _buttonCommit.backgroundColor = MainColor;
        _buttonCommit.layer.cornerRadius = Ratio5;
        _buttonCommit.titleLabel.font = Font13;
        [_buttonCommit addTarget:self action:@selector(actionToCommit:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCommit;
}


@end
