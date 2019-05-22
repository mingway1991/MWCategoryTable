//
//  MWCategoryListView.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryListView.h"
#import "MWCategoryTabView.h"
#import "MWCategoryTableCell.h"

@interface MWCategoryListView () <UICollectionViewDelegateFlowLayout,
                                UICollectionViewDataSource,
                                UICollectionViewDelegate,
                                UIScrollViewDelegate,
                                MWCategoryTabViewDelegate,
                                MWCategoryTableCellDelegate>

@property (nonatomic, strong) MWCategoryTabView *tabView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UICollectionView *listCollectionView;
@property (nonatomic, strong) NSMutableArray<NSNumber *> * tableOffsets; // 各列表位移记录值

@end

@implementation MWCategoryListView

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCategories:(NSArray<id<MWCategoryItemProtocol>> *)categories {
    self = [self init];
    self.categories = categories;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                   categories:(NSArray<id<MWCategoryItemProtocol>> *)categories {
    self = [self initWithFrame:frame];
    self.categories = categories;
    return self;
}

- (void)commonInit {
    self.topInset = 0.f;
    self.bottomInset = 0.f;
    self.tabViewHeight = 40.f;
    self.tableOffsets = [NSMutableArray array];
    
    [self addSubview:self.listCollectionView];
    [self addSubview:self.tabView];
    [self addSubview:self.bottomLineView];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.listCollectionView.frame = self.bounds;
    self.tabView.frame = CGRectMake(0, self.topInset, CGRectGetWidth(self.bounds), self.tabViewHeight);
    CGFloat lineHeight = 1.f;
    self.bottomLineView.frame = CGRectMake(0, self.topInset+self.tabViewHeight-lineHeight, CGRectGetWidth(self.bounds), lineHeight);
}

#pragma mark - Setter
- (void)setCategories:(NSArray<id<MWCategoryItemProtocol>> *)categories {
    _categories = categories;
    [self _generateTableOffsets];
    self.tabView.categories = categories;
}

- (void)setTopInset:(CGFloat)topInset {
    _topInset = topInset;
    [self _generateTableOffsets];
    [self setNeedsLayout];
}

- (void)setBottomInset:(CGFloat)bottomInset {
    _bottomInset = bottomInset;
    [self _generateTableOffsets];
    [self setNeedsLayout];
}

- (void)setTabViewHeight:(CGFloat)tabViewHeight {
    _tabViewHeight = tabViewHeight;
    [self _generateTableOffsets];
    [self setNeedsLayout];
}

#pragma mark - Private
- (void)_generateTableOffsets {
    [self.tableOffsets removeAllObjects];
    for (NSInteger i=0; i<self.categories.count; i++) {
        id<MWCategoryTableManagerProtocol> manager = [self.categories[i] tableManager];
        CGFloat initOffset = -(self.topInset+self.tabViewHeight+manager.inset.top);
        [self.tableOffsets addObject:@(initOffset)];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MWCategoryTableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[MWCategoryTableCell alloc] init];
    }
    cell.delegate = self;
    cell.category = self.categories[indexPath.row];
    cell.parentInset = UIEdgeInsetsMake(self.topInset+self.tabViewHeight, 0, self.bottomInset, 0);
    [cell updateOffsetY:[self.tableOffsets[indexPath.row] floatValue]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 根据滚动offset，选中对应的category
    NSInteger newIndex = self.listCollectionView.contentOffset.x/CGRectGetWidth(self.bounds);
    [self.tabView scrollAndSelectIndex:newIndex animated:YES];
}

#pragma mark - MWCategoryTabViewDelegate
- (void)tabView:(MWCategoryTabView *)tabView
 didSelectIndex:(NSInteger)index {
    [self.listCollectionView setContentOffset:CGPointMake(index*CGRectGetWidth(self.bounds), self.listCollectionView.contentOffset.y)];
}

#pragma mark - MWCategoryTableCellDelegate
- (void)tableCellUpdateOffsetY:(MWCategoryTableCell *)tableCell
                      category:(id<MWCategoryItemProtocol>)category
                    newOffsetY:(CGFloat)newOffsetY {
    NSInteger index = [self.categories indexOfObject:category];
    [self.tableOffsets replaceObjectAtIndex:index withObject:@(newOffsetY)];
}

#pragma mark - LazyLoad
- (UICollectionView *)listCollectionView {
    if (!_listCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.f;
        layout.minimumInteritemSpacing = 0.f;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.listCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _listCollectionView.dataSource = self;
        _listCollectionView.delegate = self;
        _listCollectionView.pagingEnabled = YES;
        _listCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_listCollectionView registerClass:[MWCategoryTableCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _listCollectionView;
}

- (MWCategoryTabView *)tabView {
    if (!_tabView) {
        self.tabView = [[MWCategoryTabView alloc] init];
        _tabView.tabDelegate = self;
    }
    return _tabView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        self.bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0];
    }
    return _bottomLineView;
}

@end
