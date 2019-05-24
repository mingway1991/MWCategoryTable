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

static NSString *kCategoryTableContentOffsetKeyPath = @"contentOffset";
static NSString *kCategoryTableContentInsetKeyPath = @"contentInset";

@interface MWCategoryListView () <UICollectionViewDelegateFlowLayout,
                                UICollectionViewDataSource,
                                UICollectionViewDelegate,
                                UIScrollViewDelegate,
                                MWCategoryTabViewDelegate>

@property (nonatomic, strong) MWCategoryTabView *tabView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UICollectionView *listCollectionView;
@property (nonatomic, strong) NSMutableArray<NSValue *> * tableInsets; // 各列表contentInset记录值
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
    self.tableInsets = [NSMutableArray array];
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
    for (id<MWCategoryItemProtocol> category in _categories) {
        // 移除监听contentInset和contentOffset变化
        [category.tableManager.contentTableView removeObserver:self forKeyPath:kCategoryTableContentInsetKeyPath];
        [category.tableManager.contentTableView removeObserver:self forKeyPath:kCategoryTableContentOffsetKeyPath];
    }
    _categories = categories;
    [self _generateTableInsets];
    [self _generateTableOffsets];
    self.tabView.categories = categories;
    if (categories.count > 0) {
        // 添加监听contentInset和contentOffset变化
        NSInteger index = 0;
        for (id<MWCategoryItemProtocol> category in categories) {
            [category.tableManager.contentTableView addObserver:self forKeyPath:kCategoryTableContentInsetKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void *)@(index)];
            [category.tableManager.contentTableView addObserver:self forKeyPath:kCategoryTableContentOffsetKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void *)@(index)];
            index++;
        }
        // 设定默认选中索引
        [self.tabView scrollAndSelectIndex:0 animated:NO];
        // 回调将要显示tableManager
        id<MWCategoryTableManagerProtocol> tableManager = [self.categories[0] tableManager];
        if ([tableManager respondsToSelector:@selector(didAppear)]) {
            [tableManager didAppear];
        }
    }
}

- (void)setTopInset:(CGFloat)topInset {
    _topInset = topInset;
    [self _generateTableInsets];
    [self _generateTableOffsets];
    [self setNeedsLayout];
}

- (void)setBottomInset:(CGFloat)bottomInset {
    _bottomInset = bottomInset;
    [self _generateTableInsets];
    [self _generateTableOffsets];
    [self setNeedsLayout];
}

- (void)setTabViewHeight:(CGFloat)tabViewHeight {
    _tabViewHeight = tabViewHeight;
    [self _generateTableInsets];
    [self _generateTableOffsets];
    [self setNeedsLayout];
}

#pragma mark - Private
// 生成默认tableInset数组，用于初始化tableView的inset
- (void)_generateTableInsets {
    [self.tableInsets removeAllObjects];
    for (NSInteger i=0; i<self.categories.count; i++) {
        id<MWCategoryTableManagerProtocol> manager = [self.categories[i] tableManager];
        UIEdgeInsets insets = UIEdgeInsetsMake(manager.inset.top+self.topInset+self.tabViewHeight, manager.inset.left, manager.inset.bottom+self.bottomInset, manager.inset.right);
        [self.tableInsets addObject:[NSValue valueWithUIEdgeInsets:insets]];
    }
}
// 生成默认tableOffset数组，用于初始化tableView的offset
- (void)_generateTableOffsets {
    [self.tableOffsets removeAllObjects];
    for (NSInteger i=0; i<self.categories.count; i++) {
        [self.tableOffsets addObject:@(0)];
    }
}

#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kCategoryTableContentInsetKeyPath]) {
        // 更新保存contentInset
        UIScrollView *scrollView = (UIScrollView *)object;
        UIEdgeInsets newInset = scrollView.contentInset;
        NSInteger index = [(__bridge NSNumber *)context integerValue];
        UIEdgeInsets oldInset = [self.tableInsets[index] UIEdgeInsetsValue];
        if (UIEdgeInsetsEqualToEdgeInsets(oldInset, newInset)) {
            [self.tableInsets replaceObjectAtIndex:index withObject:[NSValue valueWithUIEdgeInsets:newInset]];
        }
    } else if ([keyPath isEqualToString:kCategoryTableContentOffsetKeyPath]) {
        // 更新保存contentOffset
        UIScrollView *scrollView = (UIScrollView *)object;
        CGFloat newOffsetY = scrollView.contentOffset.y+scrollView.contentInset.top;
        if (newOffsetY < 0) {
            newOffsetY = 0;
        }
        NSInteger index = [(__bridge NSNumber *)context integerValue];
        CGFloat oldOffsetY = [self.tableOffsets[index] floatValue];
        if (newOffsetY != oldOffsetY) {
            [self.tableOffsets replaceObjectAtIndex:index withObject:@(newOffsetY)];
        }
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
    cell.category = self.categories[indexPath.row];
    [cell updateInset:[self.tableInsets[indexPath.row] UIEdgeInsetsValue]];
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
    NSInteger newIndex = self.listCollectionView.contentOffset.x/CGRectGetWidth(self.bounds);
    if (newIndex != self.tabView.selectIndex) {
        id<MWCategoryTableManagerProtocol> oldTableManager = [self.categories[self.tabView.selectIndex] tableManager];
        if ([oldTableManager respondsToSelector:@selector(didDisappear)]) {
            [oldTableManager didDisappear];
        }
        [self.tabView scrollAndSelectIndex:newIndex animated:YES];
        id<MWCategoryTableManagerProtocol> newTableManager = [self.categories[newIndex] tableManager];
        if ([newTableManager respondsToSelector:@selector(didAppear)]) {
            [newTableManager didAppear];
        }
    }
}

#pragma mark - MWCategoryTabViewDelegate
- (void)tabView:(MWCategoryTabView *)tabView
willSelectIndex:(NSInteger)index {
    id<MWCategoryTableManagerProtocol> tableManager = [self.categories[self.tabView.selectIndex] tableManager];
    if ([tableManager respondsToSelector:@selector(didDisappear)]) {
        [tableManager didDisappear];
    }
    [self.listCollectionView setContentOffset:CGPointMake(index*CGRectGetWidth(self.bounds), self.listCollectionView.contentOffset.y)];
}

- (void)tabView:(MWCategoryTabView *)tabView
 didSelectIndex:(NSInteger)index {
    id<MWCategoryTableManagerProtocol> tableManager = [self.categories[index] tableManager];
    if ([tableManager respondsToSelector:@selector(didAppear)]) {
        [tableManager didAppear];
    }
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
        _listCollectionView.showsHorizontalScrollIndicator = NO;
        _listCollectionView.showsVerticalScrollIndicator = NO;
        
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
