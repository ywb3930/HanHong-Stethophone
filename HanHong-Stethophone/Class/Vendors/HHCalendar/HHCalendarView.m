//
//  HHCalendarView.m
//  HanHong-Stethophone
//
//  Created by Hanhong on 2023/6/25.
//

#import "HHCalendarView.h"


@interface HHCalendarView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView                      *calendarCollectionView;
@property (assign, nonatomic) CGFloat                               width;

@end

@implementation HHCalendarView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.width = (screenW-Ratio44)/7;
        [self setupView];
    }
    return self;
}

- (void)setCalendarManager:(HHCalendarManager *)calendarManager{
    _calendarManager = calendarManager;
    [self.calendarCollectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionClickCalendarItemCallback:)]) {
        HHCalendarDayModel *dayModel = self.calendarManager.calendarDate[indexPath.row];
        [self.delegate actionClickCalendarItemCallback:dayModel];
    }
    
}

- (void)reloadCollectView{
    [self.calendarCollectionView reloadData];
}

- (void)setupView{
    UIView *weekView = [self setupWeekHeadViewWithFrame];
    weekView.backgroundColor = ViewBackGroundColor;
    [self addSubview:weekView];
    [self addSubview:self.calendarCollectionView];
    self.calendarCollectionView.sd_layout.leftSpaceToView(self, Ratio22).rightSpaceToView(self, Ratio22).topSpaceToView(weekView, 0).heightIs(6 * self.width);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 42;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HHCalendarCell * cell = (HHCalendarCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HHCalendarCell class]) forIndexPath:indexPath];
    cell.calendarDayModel = self.calendarManager.calendarDate[indexPath.row];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.width, self.width);
}


- (UIView *)setupWeekHeadViewWithFrame{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenH, self.width)];
    view.backgroundColor = [UIColor whiteColor];
    NSArray *weekArray = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    for (int i = 0; i < 7; ++i) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * self.width + Ratio22, 0.0, self.width, self.width)];
        label.backgroundColor = [UIColor clearColor];
        label.text = weekArray[i];
        label.textColor = MainBlack;
        label.font = Font15;
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
    }
    return view;
}

- (UICollectionView *)calendarCollectionView{
    if (!_calendarCollectionView) {
        UICollectionViewFlowLayout * fallsLayout = [[UICollectionViewFlowLayout alloc] init];
        fallsLayout.estimatedItemSize = CGSizeMake(self.width , self.width );
        _calendarCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fallsLayout];
        _calendarCollectionView.backgroundColor = [UIColor clearColor];
        _calendarCollectionView.delegate = self;
        _calendarCollectionView.dataSource = self;
        [_calendarCollectionView registerClass:[HHCalendarCell class] forCellWithReuseIdentifier:NSStringFromClass([HHCalendarCell class])];
        
        SEL sel = NSSelectorFromString(@"_setRowAlignmentsOptions:");
        if ([_calendarCollectionView.collectionViewLayout respondsToSelector:sel]) {
            ((void(*)(id,SEL,NSDictionary*)) objc_msgSend)(_calendarCollectionView.collectionViewLayout, sel, @{@"UIFlowLayoutCommonRowHorizontalAlignmentKey":@(NSTextAlignmentLeft),@"UIFlowLayoutLastRowHorizontalAlignmentKey" : @(NSTextAlignmentLeft), @"UIFlowLayoutRowVerticalAlignmentKey" : @(NSTextAlignmentCenter)});
        }
    }
    return _calendarCollectionView;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

@end
