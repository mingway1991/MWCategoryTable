//
//  MWCategoryTableManager.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryTableManager.h"
#import "MWNetwork+Category.h"
#import "MWNewsModel.h"
#import "MWCategoryNewsCell.h"

@import MJRefresh;

@interface MWCategoryTableManager () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) MWNetwork *network;
@property (nonatomic, strong) NSNumber *maxBehotTime;
@property (nonatomic, strong) NSArray<MWNewsModel *> *newsModels;

@end

@implementation MWCategoryTableManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.contentTableView.mj_header beginRefreshing];
    }
    return self;
}

- (UIEdgeInsets)inset {
    return UIEdgeInsetsZero;
}

#pragma mark - Request
- (void)requestCategoryNewsWithIsRefresh:(BOOL)isRefresh {
    if (isRefresh) {
        self.maxBehotTime = @(0);
    }
    __weak typeof(self) weakSelf = self;
    [self.network loadNewsWithCategoryType:self.parentCategoryModel.categoryType maxBehotTime:self.maxBehotTime successBlock:^(NSArray<MWNewsModel *> * _Nonnull newsModels, BOOL hasMore, NSNumber * _Nonnull maxBehotTime) {
        if (isRefresh) {
            [weakSelf.contentTableView.mj_header endRefreshing];
            weakSelf.newsModels = newsModels;
            
            weakSelf.contentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [weakSelf requestCategoryNewsWithIsRefresh:NO];
            }];
        } else {
            if (hasMore) {
                [weakSelf.contentTableView.mj_footer endRefreshing];
            } else {
                [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
            }
            NSMutableArray *newNewsModels = [NSMutableArray arrayWithArray:weakSelf.newsModels];
            [newNewsModels addObjectsFromArray:newsModels];
            weakSelf.newsModels = newNewsModels;
        }
        [weakSelf.contentTableView reloadData];
    } failureBlock:^(NSString * _Nonnull msg) {
        [weakSelf.contentTableView.mj_header endRefreshing];
        [weakSelf.contentTableView.mj_footer endRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MWCategoryNewsCell HeightForNewsModel:self.newsModels[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MWCategoryNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[MWCategoryNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell updateUIWithNewsModel:self.newsModels[indexPath.row]];
    return cell;
}

#pragma mark - LazyLoad
- (UITableView *)contentTableView {
    if (!_contentTableView) {
        self.contentTableView = [[UITableView alloc] init];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak typeof(self) weakSelf = self;
        _contentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf requestCategoryNewsWithIsRefresh:YES];
        }];
    }
    return _contentTableView;
}

- (MWNetwork *)network {
    if (!_network) {
        self.network = [[MWNetwork alloc] init];
    }
    return _network;
}

- (NSNumber *)maxBehotTime {
    if (!_maxBehotTime) {
        self.maxBehotTime = @(0);
    }
    return _maxBehotTime;
}

@end
