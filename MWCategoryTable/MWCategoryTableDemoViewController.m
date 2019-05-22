//
//  MWCategoryTableDemoViewController.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryTableDemoViewController.h"
#import "MWCategoryListView.h"
#import "MWCategoryModel.h"

@interface MWCategoryTableDemoViewController ()

@property (nonatomic, strong) MWCategoryListView *listView;

@end

@implementation MWCategoryTableDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.listView];
    
    NSMutableArray *categories = [NSMutableArray array];
    for (NSInteger i = 0; i<20; i++) {
        MWCategoryModel *model = [[MWCategoryModel alloc] init];
        [categories addObject:model];
    }
    self.listView.categories = categories;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.listView.frame = self.view.bounds;
}

#pragma mark - LazyLoad
- (MWCategoryListView *)listView {
    if (!_listView) {
        self.listView = [[MWCategoryListView alloc] init];
        _listView.topInset = 88.f;
    }
    return _listView;
}

@end
