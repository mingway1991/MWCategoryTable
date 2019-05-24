//
//  MWCategoryListViewController.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryListViewController.h"
#import "MWCategoryListView.h"
#import "MWCategoryModel.h"
#import "MWDefines.h"

@interface MWCategoryListViewController ()

@property (nonatomic, strong) MWCategoryListView *listView;

@end

@implementation MWCategoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self _generateCategories];
    [self.view addSubview:self.listView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.listView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
}

#pragma mark - Private
- (void)_generateCategories {
    NSMutableArray *categories = [NSMutableArray array];
    
    MWCategoryModel *all_model = [[MWCategoryModel alloc] init];
    all_model.categoryName = @"推荐";
    all_model.categoryType = @"__all__";
    [categories addObject:all_model];
    
    MWCategoryModel *hot_model = [[MWCategoryModel alloc] init];
    hot_model.categoryName = @"热点";
    hot_model.categoryType = @"news_hot";
    [categories addObject:hot_model];
    
    MWCategoryModel *tech_model = [[MWCategoryModel alloc] init];
    tech_model.categoryName = @"科技";
    tech_model.categoryType = @"news_tech";
    [categories addObject:tech_model];
    
    MWCategoryModel *society_model = [[MWCategoryModel alloc] init];
    society_model.categoryName = @"社会";
    society_model.categoryType = @"news_society";
    [categories addObject:society_model];
    
    MWCategoryModel *entertainment_model = [[MWCategoryModel alloc] init];
    entertainment_model.categoryName = @"娱乐";
    entertainment_model.categoryType = @"news_entertainment";
    [categories addObject:entertainment_model];
    
    MWCategoryModel *game_model = [[MWCategoryModel alloc] init];
    game_model.categoryName = @"游戏";
    game_model.categoryType = @"news_game";
    [categories addObject:game_model];
    
    MWCategoryModel *sports_model = [[MWCategoryModel alloc] init];
    sports_model.categoryName = @"体育";
    sports_model.categoryType = @"news_sports";
    [categories addObject:sports_model];
    
    MWCategoryModel *car_model = [[MWCategoryModel alloc] init];
    car_model.categoryName = @"汽车";
    car_model.categoryType = @"news_car";
    [categories addObject:car_model];
    
    MWCategoryModel *finance_model = [[MWCategoryModel alloc] init];
    finance_model.categoryName = @"财经";
    finance_model.categoryType = @"news_finance";
    [categories addObject:finance_model];
    
    MWCategoryModel *military_model = [[MWCategoryModel alloc] init];
    military_model.categoryName = @"军事";
    military_model.categoryType = @"news_military";
    [categories addObject:military_model];
    
    MWCategoryModel *world_model = [[MWCategoryModel alloc] init];
    world_model.categoryName = @"国际";
    world_model.categoryType = @"news_world";
    [categories addObject:world_model];
    
    MWCategoryModel *fashion_model = [[MWCategoryModel alloc] init];
    fashion_model.categoryName = @"时尚";
    fashion_model.categoryType = @"news_fashion";
    [categories addObject:fashion_model];
    
    MWCategoryModel *travel_model = [[MWCategoryModel alloc] init];
    travel_model.categoryName = @"旅游";
    travel_model.categoryType = @"news_travel";
    [categories addObject:travel_model];
    
    MWCategoryModel *discovery_model = [[MWCategoryModel alloc] init];
    discovery_model.categoryName = @"探索";
    discovery_model.categoryType = @"news_discovery";
    [categories addObject:discovery_model];
    
    MWCategoryModel *baby_model = [[MWCategoryModel alloc] init];
    baby_model.categoryName = @"育儿";
    baby_model.categoryType = @"news_baby";
    [categories addObject:baby_model];
    
    MWCategoryModel *regimen_model = [[MWCategoryModel alloc] init];
    regimen_model.categoryName = @"养生";
    regimen_model.categoryType = @"news_regimen";
    [categories addObject:regimen_model];
    
    MWCategoryModel *essay_model = [[MWCategoryModel alloc] init];
    essay_model.categoryName = @"美文";
    essay_model.categoryType = @"news_essay";
    [categories addObject:essay_model];
    
    MWCategoryModel *history_model = [[MWCategoryModel alloc] init];
    history_model.categoryName = @"历史";
    history_model.categoryType = @"news_history";
    [categories addObject:history_model];
    
    MWCategoryModel *food_model = [[MWCategoryModel alloc] init];
    food_model.categoryName = @"美食";
    food_model.categoryType = @"news_food";
    [categories addObject:food_model];
    
    self.listView.categories = categories;
}

#pragma mark - LazyLoad
- (MWCategoryListView *)listView {
    if (!_listView) {
        self.listView = [[MWCategoryListView alloc] init];
        _listView.topInset = MWTopBarHeight;
        _listView.bottomInset = MWSafeAreaHeight;
    }
    return _listView;
}

@end
