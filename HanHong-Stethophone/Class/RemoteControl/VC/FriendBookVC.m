//
//  FriendBookVC.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/21.
//

#import "FriendBookVC.h"
#import "FriendModel.h"
#import "UITableView+SCIndexView.h"
#import "InteriorHeaderView.h"
#import "FriendCell.h"

#define HeaderViewHeight 79.f*screenRatio

@interface FriendBookVC ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, TTActionSheetDelegate>

@property (retain, nonatomic) NSMutableArray        *arrayData;
@property (retain, nonatomic) NSMutableArray        *listTitle;
@property (retain, nonatomic) UITableView           *tableView;
@property (retain, nonatomic) NoDataView            *noDataView;
@property (retain, nonatomic) NSIndexPath           *currentIndexPath;

@end

@implementation FriendBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    if (self.bAddFriend) {
        self.title = @"师友录";
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        item0.width = Ratio11;

        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:nil];
        self.navigationItem.rightBarButtonItems = @[item0,item2];
        item2.action = @selector(actionToCommit:);
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initData) name:refresh_friendlist_broadcast object:nil];
    [self initData];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.noDataView];
}

- (void)actionToCommit:(UIBarButtonItem *)item {
    NSMutableArray *array = [NSMutableArray array];
    for (NSArray *a in self.arrayData) {
        for (FriendModel *model in a) {
            if (model.bSelected) {
                [array addObject:model];
            }
        }
    }
    if (array.count > 0 && self.delegate && [self.delegate respondsToSelector:@selector(actionSelectModelCallback:)]) {
        [self.delegate actionSelectModelCallback:array];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)actionToDeleteFriend:(NSIndexPath *)indexPath{
    NSLog(@"删除");
    NSArray *array = self.arrayData[indexPath.section];
    FriendModel *model = array[indexPath.row];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"friend_id"] = [@(model.userId) stringValue];
    [Tools showWithStatus:@"正在删除"];
    __weak typeof(self) wself = self;
    [TTRequestManager friendDelete:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            [wself reloadTableView:indexPath];
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}


- (void)reloadTableView:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSMutableArray *array = self.arrayData[section];
    [array removeObjectAtIndex:indexPath.row];
    if (array.count == 0) {
        [self.arrayData removeObjectAtIndex:section];
        [self.listTitle removeObjectAtIndex:section];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if(self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
    } else {
        self.noDataView.hidden = YES;
    }
    [self reloadRightTableView];
}

- (void)reloadRightTableView{
    NSMutableArray *indexViewDataSource = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    for (NSString *title in self.listTitle) {
        [indexViewDataSource addObject:title];
    }
    [self performSelector:@selector(reloadColorForHeaderView) withObject:nil afterDelay:0.1f];
    self.tableView.sc_indexViewDataSource = indexViewDataSource;
    self.tableView.sc_startSection = 0;
}

- (void)initData{
    self.arrayData = [NSMutableArray array];
    self.listTitle = [NSMutableArray array];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    __weak typeof(self) wself = self;
    [TTRequestManager friendGetFriends:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            NSArray *data = responseObject[@"data"];
            NSSortDescriptor *descri = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
            NSArray  *a = [data sortedArrayUsingDescriptors:@[descri]];
            NSArray *list = [NSArray yy_modelArrayWithClass:[FriendModel class] json:a];
            if (wself.selectModel.count > 0) {
                for (FriendModel *model1 in wself.selectModel) {
                    for (FriendModel *model2 in list) {
                        if (model1.userId == model2.userId) {
                            model2.bSelected = YES;
                        }
                    }
                }
            }
            for(FriendModel *model in list) {
                NSString *letter = [Tools firstCharactor:model.name];
                if(![wself.listTitle containsObject:letter]) {
                    [wself.listTitle addObject:letter];
                }
            }
            
            for(NSString *title in wself.listTitle) {
                NSMutableArray *item = [NSMutableArray array];
                for(FriendModel *model in list) {
                    NSString *letter = [Tools firstCharactor:model.name];
                    if([title isEqualToString:letter]) {
                        [item addObject:model];
                    }
                }
                [wself.arrayData addObject:item];
            }
            if ([NSThread isMainThread]) {
                [self actionRefreshView];
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self actionRefreshView];
                });
            }
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (void)actionRefreshView{
    [self reloadRightTableView];
    if(self.arrayData.count == 0) {
        self.noDataView.hidden = NO;
    } else {
        self.noDataView.hidden = YES;
    }
    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell actionButtonClick:cell.buttonClick];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = self.arrayData[section];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSArray *list = self.arrayData[section];
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FriendCell class])];
    cell.bShowCheck = self.bAddFriend;
    cell.friendModel = list[row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Ratio22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    InteriorHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([InteriorHeaderView class])];
    headerView.title = self.listTitle[section];
    
    return headerView;
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    if (index == 0) {
        [self actionToDeleteFriend:self.currentIndexPath];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self reloadColorForHeaderView];
}

- (void)reloadColorForHeaderView {
    NSArray<NSIndexPath *> *indexPaths = self.tableView.indexPathsForVisibleRows;
    for (NSIndexPath *indexPath in indexPaths) {
        InteriorHeaderView *headerView = (InteriorHeaderView *)[self.tableView headerViewForSection:indexPath.section];
        [self configColorWithHeaderView:headerView];
    }
}

- (void)configColorWithHeaderView:(InteriorHeaderView *)headerView {
    if (!headerView) {
        return;
    }
    
    double diff = fabs(headerView.frame.origin.y - self.tableView.contentOffset.y);
    CGFloat headerHeight = Ratio22;
    double progress;
    if (diff >= headerHeight) {
        progress = 1;
    }
    else {
        progress = diff / headerHeight;
    }
    [headerView configWithProgress:progress];
}



- (UITableView *)tableView{
    if (!_tableView) {
        CGFloat y = self.bAddFriend ? kNavBarAndStatusBarHeight : 0;
        CGFloat height = self.bAddFriend ? screenH - y -kBottomSafeHeight : screenH - Ratio44 - kBottomSafeHeight - y;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, screenW, height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = WHITECOLOR;
        _tableView.sectionHeaderTopPadding = 0;
        
         _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FriendCell class] forCellReuseIdentifier:NSStringFromClass([FriendCell class])];
        [_tableView registerClass:[InteriorHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([InteriorHeaderView class])];
        
        SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
        configuration.indexItemSelectedBackgroundColor = MainColor;
        configuration.indexItemsSpace = Ratio8;
        configuration.indexItemTextColor = MainGray;
        configuration.indexItemSelectedTextColor = WHITECOLOR;
        _tableView.sc_indexViewConfiguration = configuration;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]  initWithTarget:self action:@selector(handleLongPress:)];
        //lpgr.delegate = self;
        lpgr.delaysTouchesBegan = YES;
        [_tableView addGestureRecognizer:lpgr];
        
    }
    return _tableView;
}



-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        self.currentIndexPath = indexPath;
        
        TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[@"删除"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        actionSheet.delegate = self;
        [actionSheet showInView:kAppWindow];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.listTitle.count;
}

- (NoDataView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight + Ratio35, screenW, screenH)];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

@end
