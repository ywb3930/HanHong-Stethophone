//
//  FriendBookVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/21.
//

#import "FriendBookVC.h"
#import "FriendModel.h"
#import "UITableView+SCIndexView.h"
#import "InteriorHeaderView.h"
#import "FriendCell.h"

#define HeaderViewHeight 89.f*screenRatio

@interface FriendBookVC ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (retain, nonatomic) NSMutableArray        *arrayData;
@property (retain, nonatomic) NSMutableArray        *listTitle;
@property (retain, nonatomic) UITableView           *tableView;
@property (retain, nonatomic) NoDataView            *noDataView;

@end

@implementation FriendBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WHITECOLOR;
    if (self.bAdd) {
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
    params[@"friend_id"] = [@(model.id) stringValue];
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
                        if (model1.id == model2.id) {
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
                
                NSMutableArray *indexViewDataSource = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
                for (NSString *title in wself.listTitle) {
                    [indexViewDataSource addObject:title];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wself reloadColorForHeaderView];
                });
                wself.tableView.sc_indexViewDataSource = indexViewDataSource;
                wself.tableView.sc_startSection = 0;
               
                
            }
            
            if(wself.arrayData.count == 0) {
                wself.noDataView.hidden = NO;
            } else {
                wself.noDataView.hidden = YES;
            }
            [wself.tableView reloadData];
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    cell.bShowCheck = self.bAdd;
    cell.friendModel = list[row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Ratio22;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    InteriorHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([InteriorHeaderView class])];
    headerView.title = self.listTitle[section];
    
    return headerView;
}



- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [self actionToDeleteFriend:indexPath];
    }];
    deleteRowAction.title = @"删除";
    deleteRowAction.backgroundColor = [UIColor redColor];



    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
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
    CGFloat headerHeight = HeaderViewHeight;
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
        CGFloat y = 0;
        if (self.bAdd) {
            y = -Ratio18;
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, screenW, screenH - kNavBarAndStatusBarHeight - kBottomSafeHeight - Ratio55 - y)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = WHITECOLOR;
        
        
         _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FriendCell class] forCellReuseIdentifier:NSStringFromClass([FriendCell class])];
        [_tableView registerClass:[InteriorHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([InteriorHeaderView class])];
        
        SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
        configuration.indexItemSelectedBackgroundColor = MainColor;
        configuration.indexItemsSpace = Ratio8;
        configuration.indexItemTextColor = MainGray;
        configuration.indexItemSelectedTextColor = WHITECOLOR;
        _tableView.sc_indexViewConfiguration = configuration;
        
    }
    return _tableView;
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
