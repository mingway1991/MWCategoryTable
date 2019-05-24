//
//  MWCategoryTableCell.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryTableCell.h"

@interface MWCategoryTableCell ()

@property (nonatomic, weak) UIScrollView *tableView;
@property (nonatomic, weak) id<MWCategoryTableManagerProtocol> manager;

@end

@implementation MWCategoryTableCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Setter
- (void)setCategory:(id<MWCategoryItemProtocol>)category {
    if (category == _category) { return; }
    
    if (self.tableView) {
        [self.tableView removeFromSuperview];
        self.tableView = nil;
    }
    _category = category;
    _manager = [category tableManager];
    self.tableView = _manager.contentTableView;
    [self.contentView addSubview:self.tableView];
    [self setNeedsLayout];
}

#pragma mark - Public
- (void)updateInset:(UIEdgeInsets)inset {
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (void)updateOffsetY:(CGFloat)offsetY {
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, offsetY-self.tableView.contentInset.top)];
}

@end
