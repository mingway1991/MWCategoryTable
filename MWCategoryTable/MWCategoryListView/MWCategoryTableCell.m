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

- (void)dealloc {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _category = nil;
}

#pragma mark - Setter
- (void)setParentInset:(UIEdgeInsets)parentInset {
    _parentInset = parentInset;
    [self _updateContentInset];
}

- (void)setCategory:(id<MWCategoryItemProtocol>)category {
    _category = category;
    _manager = [category tableManager];
    if (self.tableView) {
        [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
        [self.tableView removeFromSuperview];
    }
    self.tableView = _manager.contentTableView;
    self.tableView.frame = self.bounds;
    [self.contentView addSubview:self.tableView];
    [self _updateContentInset];
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (self.category && [self.delegate respondsToSelector:@selector(tableCellUpdateOffsetY:category:newOffsetY:)]) {
            [self.delegate tableCellUpdateOffsetY:self category:self.category newOffsetY:self.tableView.contentOffset.y];
        }
    }
}

#pragma mark - Public
- (void)updateOffsetY:(CGFloat)offsetY {
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, offsetY)];
}

#pragma mark - Private
- (void)_updateContentInset {
    if ([_manager respondsToSelector:@selector(inset)]) {
        self.tableView.contentInset = UIEdgeInsetsMake(_manager.inset.top+self.parentInset.top, _manager.inset.left+self.parentInset.left, _manager.inset.bottom+self.parentInset.bottom, _manager.inset.right+self.parentInset.right);
    } else {
        self.tableView.contentInset = self.parentInset;
    }
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    NSLog(@"%@", [NSValue valueWithUIEdgeInsets:self.tableView.contentInset]);
}

@end
