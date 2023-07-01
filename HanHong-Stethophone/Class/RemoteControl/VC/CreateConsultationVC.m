//
//  CreateConsultationVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/6/21.
//

#import "CreateConsultationVC.h"
#import "CreateConsultationCell.h"
#import "CreateConsultationHeaderView.h"
#import "FriendBookVC.h"
#import "BRPickerView.h"

@interface CreateConsultationVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FriendBookVCDelegate, UIGestureRecognizerDelegate, TTActionSheetDelegate, CreateConsultationHeaderViewDelegate>

@property (retain, nonatomic) UICollectionView              *collectionView;
@property (retain, nonatomic) NSMutableArray                *arrayData;
@property (retain, nonatomic) NSIndexPath                   *currentIndexPath;
@property (retain, nonatomic) CreateConsultationHeaderView  *headerView;

@end

@implementation CreateConsultationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.bModify) {
        self.title = @"修改会诊";
    } else {
        self.title = @"新建会诊";
    }
    
    [self initData];
    [self setupView];
}

- (void)initData{
    self.arrayData = [NSMutableArray array];
    if (self.bModify) {
        for (FriendModel *model in self.consultationModel.members) {
            if (model.id == self.consultationModel.collector_id) {
                model.bCollect = YES;
            }
        }
       [self.arrayData addObjectsFromArray:self.consultationModel.members];
    } else {
        FriendModel *model = [[FriendModel alloc] init];
        model.id = LoginData.id;
        model.name = LoginData.name;
        model.phone = LoginData.phone;
        model.avatar = LoginData.avatar;
        model.bCollect = YES;
        [self.arrayData addObject:model];
    }
   
}
//
- (void)actionItemStartTimeClickCallback{
    [self.view endEditing:YES];
    NSDate *minDate = [Tools dateWithYearsBeforeNow:0];
    NSDate *maxDate = [Tools dateWithYearsBeforeNow:-99];
    NSString *showDate = [Tools dateToTimeStringYMDHM:minDate];
    if (self.bModify && self.consultationModel) {
       NSDate *date = [Tools stringToDateYMDHMS:self.consultationModel.begin_time];
        showDate = [Tools dateToTimeStringYMDHM:date];
    }
    [BRDatePickerView showDatePickerWithTitle:@"请选择会诊开始时间" dateType:BRDatePickerModeYMDHM defaultSelValue:showDate minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:MainColor resultBlock:^(NSString *selectValue) {
        //wself.itemViewBirthDay.textFieldInfo.text = selectValue;
        self.headerView.itemTimeView.labelInfo.textColor = MainBlack;
        self.headerView.itemTimeView.labelInfo.text = selectValue;
    } cancelBlock:^{
        
    }];
}

- (void)actionSelectModelCallback:(NSMutableArray *)array{
    for (FriendModel *model2 in array) {
        Boolean bAdd = YES;
        for (FriendModel *model1 in self.arrayData) {
            
            if (model1.id == model2.id) {
                bAdd = NO;
            }
        }
        if (bAdd) {
            [self.arrayData addObject:model2];
        }
            
    }
    [self.collectionView reloadData];
}

- (void)actionToCommit:(UIBarButtonItem *)item{
    NSString *title = self.headerView.itemTitleView.textFieldInfo.text;
    if ([Tools isBlankString:title]) {
        [self.view makeToast:@"请输入会诊标题" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *startTime = self.headerView.itemTimeView.labelInfo.text;
    if ([Tools isBlankString:startTime]) {
        [self.view makeToast:@"请选择会诊开始时间" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSString *duration = self.headerView.itemDurationView.textFieldInfo.text;
    if ([Tools isBlankString:duration]) {
        [self.view makeToast:@"请输入会诊时长" duration:showToastViewWarmingTime position:CSToastPositionCenter];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = LoginData.token;
    params[@"title"] = title;
    params[@"begin"] = startTime;
    NSDate *beginDate = [Tools stringToDateYMDHM:startTime];
    params[@"end"] = [Tools dateAddMinuteYMDHM:beginDate minute:[duration integerValue]];
    NSMutableArray *members = [NSMutableArray array];
    NSString *collector_id = @"";
    //NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (FriendModel *model in self.arrayData) {
        if (model.bCollect) {
            collector_id = [@(model.id) stringValue];
        }
        [members addObject:@{@"id":[@(model.id) stringValue]}];
    }
    params[@"members"] = [Tools convertToJsonData:members];
    params[@"collector_id"] = collector_id;
    NSString *path = @"";
    if (self.bModify) {
        [Tools showWithStatus:@"正在修改会诊室"];
        path = @"meeting/modify_meeting";
        params[@"meetingroom_id"] = [@(self.consultationModel.meetingroom_id) stringValue];
    } else {
        [Tools showWithStatus:@"正在创建会诊室"];
        path = @"meeting/create_meeting";
    }
    
    __weak typeof(self) wself = self;
    [TTRequestManager meetingEditMeeting:params path:path success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"errorCode"] integerValue] == 0) {
            
            if (wself.delegate && [wself.delegate respondsToSelector:@selector(actionCreateConsultationSuccessCallback:)]) {
                [wself.delegate actionCreateConsultationSuccessCallback:wself.bModify];
                [wself.navigationController popViewControllerAnimated:YES];
            }
        }
        [wself.view makeToast:responseObject[@"message"] duration:showToastViewSuccessTime position:CSToastPositionCenter];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)setupView{
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item0.width = Ratio11;

    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItems = @[item0,item2];
    item2.action = @selector(actionToCommit:);
    
    [self.view addSubview:self.collectionView];
    self.collectionView.sd_layout.leftSpaceToView(self.view, 0).rightSpaceToView(self.view, 0).topSpaceToView(self.view, kNavBarAndStatusBarHeight).bottomSpaceToView(self.view, kBottomSafeHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrayData.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CreateConsultationCell *cell = (CreateConsultationCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CreateConsultationCell class]) forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    if (row == self.arrayData.count) {
        cell.image = [UIImage imageNamed:@"add_member"];
    } else {
        cell.model = self.arrayData[row];
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, Ratio11, 0, Ratio11);
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;

    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        self.headerView = (CreateConsultationHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([CreateConsultationHeaderView class]) forIndexPath:indexPath];
        self.headerView.delegate = self;
        if (self.bModify && self.consultationModel) {
            self.headerView.consultationModel = self.consultationModel;
        }
        reusableview = self.headerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return  CGSizeMake(screenW, 196.f*screenRatio);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.arrayData.count) {
        FriendBookVC *friendBook = [[FriendBookVC alloc] init];
        friendBook.selectModel = self.arrayData;
        friendBook.bAdd = YES;
        friendBook.delegate = self;
        [self.navigationController pushViewController:friendBook animated:YES];
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {
        CGFloat width = (screenW - Ratio66)/5;
        UICollectionViewFlowLayout *fallsLayout = [[UICollectionViewFlowLayout alloc] init];
        fallsLayout.estimatedItemSize = CGSizeMake(width , width + Ratio15);
        fallsLayout.minimumInteritemSpacing = Ratio11;
        [fallsLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        fallsLayout.headerReferenceSize = CGSizeMake(screenW, 196.f*screenRatio);
         
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fallsLayout];
        _collectionView.backgroundColor = WHITECOLOR;
        [_collectionView registerClass:[CreateConsultationCell class] forCellWithReuseIdentifier:NSStringFromClass([CreateConsultationCell class])];
         
        [_collectionView registerClass:[CreateConsultationHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([CreateConsultationHeaderView class])];
         
        //collectionView的item只剩下一个时自动左对齐
        SEL sel = NSSelectorFromString(@"_setRowAlignmentsOptions:");
        if ([_collectionView.collectionViewLayout respondsToSelector:sel]) {
            ((void(*)(id,SEL,NSDictionary*)) objc_msgSend)(_collectionView.collectionViewLayout, sel, @{@"UIFlowLayoutCommonRowHorizontalAlignmentKey":@(NSTextAlignmentLeft),@"UIFlowLayoutLastRowHorizontalAlignmentKey" : @(NSTextAlignmentLeft), @"UIFlowLayoutRowVerticalAlignmentKey" : @(NSTextAlignmentCenter)});
        }
         
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]  initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.delegate = self;
        lpgr.delaysTouchesBegan = YES;
        [_collectionView addGestureRecognizer:lpgr];
    }
    return _collectionView;
}



-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];

    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        self.currentIndexPath = indexPath;
        
        TTActionSheet *actionSheet = [TTActionSheet showActionSheet:@[@"设为采集人", @"删除"] cancelTitle:@"取消" andItemColor:MainBlack andItemBackgroundColor:WHITECOLOR andCancelTitleColor:MainNormal andViewBackgroundColor:WHITECOLOR];
        actionSheet.delegate = self;
        [actionSheet showInView:kAppWindow];
        
    }
}

- (void)actionSelectItem:(NSInteger)index tag:(NSInteger)tag{
    FriendModel *model = self.arrayData[self.currentIndexPath.row];
    NSMutableArray *arrayIndexPaths = [NSMutableArray array];
    [arrayIndexPaths addObject:self.currentIndexPath];
    if (index == 0) {
        NSInteger i = 0;
        for (FriendModel *model1 in self.arrayData) {
            if (model1.bCollect) {
                model1.bCollect = NO;
                [arrayIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            i++;
        }
        model.bCollect = YES;
        
        [self.collectionView reloadItemsAtIndexPaths:arrayIndexPaths];
    } else if(index == 1) {
        if (self.currentIndexPath.row == 0) {
            [self.view makeToast:@"不能删除自己" duration:showToastViewWarmingTime position:CSToastPositionCenter];
            return;
        }
        FriendModel *delModel = self.arrayData[self.currentIndexPath.row];
        if (delModel.bCollect) {
            FriendModel *mainModel = self.arrayData[0];
            mainModel.bCollect = YES;
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[path]];
        }
        [self.arrayData removeObjectAtIndex:self.currentIndexPath.row];
        [self.collectionView deleteItemsAtIndexPaths:@[self.currentIndexPath]];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
