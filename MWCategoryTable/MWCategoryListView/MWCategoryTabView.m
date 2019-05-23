//
//  MWCategoryTabView.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryTabView.h"
#import "MWCategoryTabButton.h"

@interface MWCategoryTabView ()

@property (nonatomic, strong) NSMutableArray<MWCategoryTabButton *> *categoryButtons;
@property (nonatomic, assign, readwrite) NSInteger selectIndex;

@end

@implementation MWCategoryTabView

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

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.pagingEnabled = NO;
    self.selectIndex = 0;
}

#pragma mark - Setter
- (void)setCategories:(NSArray<id<MWCategoryItemProtocol>> *)categories {
    _categories = categories;
    [self _updateFrame];
    [self _updateButtonsUI];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    [self _updateButtonsUI];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self _updateFrame];
}

#pragma mark - Public
- (void)scrollAndSelectIndex:(NSInteger)index
                    animated:(BOOL)animated {
    if (index == self.selectIndex) {
        return;
    }
    
    // 调用willDisappear回调
    id<MWCategoryTableManagerProtocol> tableManager = [self.categories[self.selectIndex] tableManager];
    if ([tableManager respondsToSelector:@selector(willDisappear)]) {
        [tableManager willDisappear];
    }
    
    self.selectIndex = index;
    [self _adjustScrollPositionForSelectCategory:animated];
}

#pragma mark - Action
- (void)clickCategoryButton:(MWCategoryTabButton *)sender {
    NSInteger newSelectedIndex = [self.categories indexOfObject:sender.category];
    if (newSelectedIndex == self.selectIndex) {
        return;
    }
    
    if ([self.tabDelegate respondsToSelector:@selector(tabView:willSelectIndex:)]) {
        [self.tabDelegate tabView:self willSelectIndex:newSelectedIndex];
    }
    
    [self scrollAndSelectIndex:newSelectedIndex animated:YES];
    
    if ([self.tabDelegate respondsToSelector:@selector(tabView:didSelectIndex:)]) {
        [self.tabDelegate tabView:self didSelectIndex:newSelectedIndex];
    }
}

#pragma mark - Private
- (void)_updateFrame {
    NSInteger categoryCount = self.categories.count;
    NSInteger categoryButtonCount = self.categoryButtons.count;
    CGFloat maxWidth = 0.f;
    
    for (NSInteger i=0; i < MIN(categoryCount, categoryButtonCount); i++) {
        // 复用已经创建的categoryButton
        MWCategoryTabButton *button = self.categoryButtons[i];
        [self _updateButtonFrameWithButton:button category:self.categories[i] index:i];
        button.hidden = NO;
        maxWidth = CGRectGetMaxX(button.frame);
    }
    
    if (categoryCount > categoryButtonCount) {
        // 创建不足的categoryButton
        for (NSInteger i=categoryButtonCount; i< categoryCount; i++) {
            MWCategoryTabButton *button = [MWCategoryTabButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(clickCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
            [self _updateButtonFrameWithButton:button category:self.categories[i] index:i];
            [self addSubview:button];
            maxWidth = CGRectGetMaxX(button.frame);
            [self.categoryButtons addObject:button];
        }
    } else if (categoryCount < categoryButtonCount) {
        // 隐藏多余的categoryButton
        for (NSInteger i=categoryCount; i < categoryButtonCount; i++) {
            MWCategoryTabButton *button = self.categoryButtons[i];
            button.hidden = YES;
        }
    }
    self.contentSize = CGSizeMake(maxWidth, CGRectGetHeight(self.bounds));
}

// 更新分类button frame
- (void)_updateButtonFrameWithButton:(MWCategoryTabButton *)button
                            category:(id<MWCategoryItemProtocol>)category
                               index:(NSInteger)index {
    CGFloat minX = 0;
    CGFloat buttonHeight = CGRectGetHeight(self.bounds);
    if (index > 0) {
        MWCategoryTabButton *previousButton = self.categoryButtons[index-1];
        minX = CGRectGetMaxX(previousButton.frame);
    }
    button.frame = CGRectMake(minX, 0, [MWCategoryTabButton WidthForCategory:category], buttonHeight);
}

// 更新所有button显示
- (void)_updateButtonsUI {
    NSInteger categoryCount = self.categories.count;
    for (NSInteger i=0; i<categoryCount; i++) {
        MWCategoryTabButton *button = self.categoryButtons[i];
        [button updateUIWithCategory:self.categories[i] isSelect:self.selectIndex == i];
    }
}

// 调整offset将选中的分类置为当中显示
- (void)_adjustScrollPositionForSelectCategory:(BOOL)animated {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (width==0 || self.contentSize.width < width) {
        return;
    }
    MWCategoryTabButton *categoryButton = self.categoryButtons[self.selectIndex];
    CGFloat newOffsetX = CGRectGetMinX(categoryButton.frame)+CGRectGetWidth(categoryButton.frame)/2.f-width/2.f;
    CGFloat minOffsetX = 0.f;
    CGFloat maxOffsetX = self.contentSize.width-width;
    if (newOffsetX < minOffsetX) {
        newOffsetX = minOffsetX;
    } else if (newOffsetX > maxOffsetX) {
        newOffsetX = maxOffsetX;
    }
    [self setContentOffset:CGPointMake(newOffsetX, self.contentOffset.y) animated:animated];
}

#pragma mark - LazyLoad
- (NSMutableArray<MWCategoryTabButton *> *)categoryButtons {
    if (!_categoryButtons) {
        self.categoryButtons = [NSMutableArray array];
    }
    return _categoryButtons;
}

@end
