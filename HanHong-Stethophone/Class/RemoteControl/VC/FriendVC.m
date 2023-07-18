//
//  FriendVC.m
//  HanHong-Stethophone
//  亦师亦友界面
//  Created by Hanhong on 2023/6/20.
//

#import "FriendVC.h"
#import "JXCategoryView.h"
#import "FriendBookVC.h"
#import "NewFriendVC.h"
#import "HMEditView.h"
#import "FriendModel.h"


@interface FriendVC ()<JXCategoryViewDelegate, UIScrollViewDelegate, HMEditViewDelegate>

@property (retain, nonatomic) JXCategoryTitleView           *categoryView;
@property (nonatomic, strong) UIScrollView                  *scrollView;
@property (retain, nonatomic) NSArray                       *titles;
@property (retain, nonatomic) NSArray                       *childVCs;
@property (assign, nonatomic) NSInteger                     selectIndex;

@property (retain, nonatomic) FriendBookVC                  *friendBook;
@property (retain, nonatomic) NewFriendVC                   *friendNew;
@property (retain, nonatomic) HMEditView                    *editView;

@end

@implementation FriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"亦师亦友";
    self.view.backgroundColor = WHITECOLOR;
    self.selectIndex = 0;
    
    [self setupView];
}

- (void)actionEditInfoCallback:(NSString *)string idx:(NSInteger)idx{
    if (![Tools IsPhoneNumber:string]) {
        [self.view makeToast:@"请输入正确的手机号" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"phone"] = string;
    [Tools showWithStatus:@"正在搜索"];
    __weak typeof(self) wself = self;
    [TTRequestManager friendSearch:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSArray *data = [NSArray yy_modelArrayWithClass:[FriendModel class] json:responseObject[@"data"]];
            [wself actionToNewFriendVC:data];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}
//
- (void)actionToNewFriendVC:(NSArray *)array{
    NewFriendVC *newFriend = [[NewFriendVC alloc] init];
    newFriend.data = array;
    newFriend.title = @"添加好友";
    [self.navigationController pushViewController:newFriend animated:YES];
}

- (void)actionToAddFriend:(UIBarButtonItem *)item{
    self.editView = [[HMEditView alloc] initWithTitle:@"请输入好友的手机号" info:nil placeholder:@"请输入好友的手机号" idx:0];
    self.editView.delegate = self;
    self.editView.cancelTitle = @"关闭";
    self.editView.okTitle = @"查找";
    self.editView.textField.keyboardType = UIKeyboardTypePhonePad;
    [kAppWindow addSubview:self.editView];
}

- (void)setupView{
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;

    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_friend"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItems = @[item0,item2];
    item2.action = @selector(actionToAddFriend:);
    
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.scrollView];
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
        UIFont *font = [UIFont systemFontOfSize:Ratio17];
        _categoryView.titleFont = font;
        _categoryView.titleSelectedFont = font;
    
        //_categoryView.titleLabelVerticalOffset = kStatusBarHeight - Ratio15;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = MainColor;//indicatorLineViewColor
        lineView.indicatorWidth = Ratio50;//indicatorLineWidth
        lineView.indicatorHeight = Ratio2;
        lineView.verticalMargin = Ratio5;
        
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;//JXCategoryIndicatorLineStyle_JD;
        _categoryView.indicators = @[lineView];
        _categoryView.contentScrollView = self.scrollView;
        
    }
    return _categoryView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGFloat scrollW = screenW;
        CGFloat scrollH = screenH - kNavBarAndStatusBarHeight - Ratio44;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight + Ratio44 , scrollW, scrollH)];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChildViewController:vc];
            [self.scrollView addSubview:vc.view];
            vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
           // self.selectIndex = idx;
        }];
        _scrollView.contentSize = CGSizeMake(scrollW, 0);
    }
    return _scrollView;
}

- (NSArray *)childVCs{
    if (!_childVCs) {
        self.friendBook = [[FriendBookVC alloc] init];
        self.friendNew = [[NewFriendVC alloc] init];
        _childVCs = @[self.friendBook, self.friendNew];
    }
    return _childVCs;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"师友录", @"新师友"];
    }
    return _titles;
}



@end
