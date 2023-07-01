//
//  TTPopView.m
//  ZuSanJiao
//
//  Created by Zhilun on 2020/8/14.
//  Copyright © 2020 Zhilun. All rights reserved.
//

#import "TTPopView.h"
#import "TTTopCell.h"

@interface TTPopView()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UIView                *viewBg;
@property (retain, nonatomic) UITableView           *tableView;
@property (retain, nonatomic) NSArray               *infoLists;

@end

@implementation TTPopView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setWidth:(CGFloat)width listInfo:(NSArray *)listInfos{
    CGFloat height = listInfos.count*Ratio44 ;
    self.tableView.frame = CGRectMake(0, screenH - height - kBottomSafeHeight, width, height);

    self.infoLists = listInfos;
    [self.tableView reloadData];
    
    

    
}

- (void)setupView{
    [self addSubview:self.viewBg];
    [self addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
     
    TTTopCell *cell = (TTTopCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTTopCell class])];
    
    cell.name = self.infoLists[row];
    if(indexPath.row == self.infoLists.count - 1) {
        cell.color = MainNormal;
    } else {
        cell.color = MainBlack;
    }
   
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSelectedInfoCallBack:row:tag:)]) {
        [self.delegate actionSelectedInfoCallBack:self.infoLists[indexPath.row] row:indexPath.row tag:self.tag];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Ratio44;
}



- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
       // _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TTTopCell class] forCellReuseIdentifier:NSStringFromClass([TTTopCell class])];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorInset = UIEdgeInsetsMake(0, -100, 0, 0);
        //_tableView.layer.cornerRadius = Ratio7;

    }
    return _tableView;
}


- (UIView *)viewBg{
    if (!_viewBg) {
        _viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        _viewBg.backgroundColor = HEXCOLOR(0x333333, 0.5);
        _viewBg.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapView:)];
        [_viewBg addGestureRecognizer:tapGesture];
        
        UISwipeGestureRecognizer *swipteGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapView:)];
        [_viewBg addGestureRecognizer:swipteGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapView:)];
        [_viewBg addGestureRecognizer:panGesture];
    }
    return _viewBg;
}

- (void)actionTapView:(UITapGestureRecognizer *)tap{
    //[self removeFromSuperview];
    self.hidden = YES;
}


@end
