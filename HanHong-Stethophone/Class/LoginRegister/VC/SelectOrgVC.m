//
//  SelectOrgVC.m
//  HM-Stethophone
//
//  Created by Eason on 2023/6/14.
//

#import "SelectOrgVC.h"

#import "UITableView+SCIndexView.h"
#import "InteriorCell.h"
#import "InteriorHeaderView.h"

#define HeaderViewHeight Ratio49

@interface SelectOrgVC ()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSMutableArray        *orgArray;
@property (retain, nonatomic) NSMutableArray        *listTitle;
@property (retain, nonatomic) UITableView           *tableView;

@end

@implementation SelectOrgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.org_type == org_type_teaching){
        self.title = @"院校";
    } else {
        self.title = @"医院";
    }
    self.orgArray = [NSMutableArray array];
    self.listTitle = [NSMutableArray array];
    [self initData];
    [self initView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    OrgModel *model = self.orgArray[indexPath.section][indexPath.row];
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSelectItem:)]){
        [self.delegate actionSelectItem:model];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initView{
    [self.view addSubview:self.tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = self.orgArray[section];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSArray *list = self.orgArray[section];
    InteriorCell *cell = (InteriorCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InteriorCell class])];
    cell.model = list[row];
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
    UIView *view = [[UIView alloc] init];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    InteriorHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([InteriorHeaderView class])];
    headerView.title = self.listTitle[section];
    
    return headerView;
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
    NSLog(@"progress = %f", progress);
    [headerView configWithProgress:progress];
}




- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight, screenW, screenH - kNavBarAndStatusBarHeight - kBottomSafeHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = WHITECOLOR;
        _tableView.sectionHeaderTopPadding = 0;
       // _tableView.separatorStyle = UITableViewCellAccessoryNone;
        [_tableView registerClass:[InteriorCell class] forCellReuseIdentifier:NSStringFromClass([InteriorCell class])];
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

- (void)initData{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    __weak typeof(self) wself = self;
    [Tools showWithStatus:nil];
    [TTRequestManager orgList:params success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] intValue] == 0 ) {
            NSArray *data = responseObject[@"data"];
           
            NSSortDescriptor *descri = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:NO];
            NSArray  *a = [data sortedArrayUsingDescriptors:@[descri]];
            NSArray *list = [NSArray yy_modelArrayWithClass:[OrgModel class] json:a];
            
            for(OrgModel *model in list) {
                
                if(model.type != self.org_type) continue;
                NSString *letter = [Tools firstCharactor:model.code];
                if(![wself.listTitle containsObject:letter]) {
                    [wself.listTitle addObject:letter];
                }
            }
            
            for(NSString *title in wself.listTitle) {
                NSMutableArray *item = [NSMutableArray array];
                for(OrgModel *model in list) {
                    if(model.type != self.org_type) continue;
                    NSString *letter = [Tools firstCharactor:model.code];
                    if([title isEqualToString:letter]) {
                        [item addObject:model];
                    }
                }
                [wself.orgArray addObject:item];
                
                NSMutableArray *indexViewDataSource = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
                for (NSString *title in wself.listTitle) {
                    [indexViewDataSource addObject:title];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wself reloadColorForHeaderView];
                });
                wself.tableView.sc_indexViewDataSource = indexViewDataSource;
                wself.tableView.sc_startSection = 0;

            }
            
            
            [wself.tableView reloadData];
            
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
   }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
