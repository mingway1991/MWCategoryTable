//
//  MWCategoryTabView.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWCategoryTabView.h"

// 字体大小
#define kMWCategoryTabButtonNormalFont [UIFont systemFontOfSize:18.f]
#define kMWCategoryTabButtonSelectedFont [UIFont boldSystemFontOfSize:18.f]
// 字间距
#define kMWCategoryTabButtonKern @(1.0f)

#pragma mark - MWCategoryTabButton

@interface MWCategoryTabButton ()

@property (nonatomic, assign) BOOL isSelect;

@end

@implementation MWCategoryTabButton

// 段落格式
+ (NSParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return paragraphStyle;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    NSString *displayStr = self.category.categoryName;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:displayStr];
    [attr addAttribute:NSParagraphStyleAttributeName value:[[self class] paragraphStyle] range:NSMakeRange(0, displayStr.length)];
    [attr addAttribute:NSKernAttributeName value:kMWCategoryTabButtonKern range:NSMakeRange(0, displayStr.length)];
    UIFont *font;
    if (self.isSelect) {
        font = kMWCategoryTabButtonSelectedFont;
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, displayStr.length)];
    } else {
        font = kMWCategoryTabButtonNormalFont;
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, displayStr.length)];
    }
    [attr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, displayStr.length)];
    
    CGFloat fontHeight = font.pointSize;
    CGFloat yOffset = (rect.size.height - fontHeight) / 2.0;
    CGRect textRect = CGRectMake(0, yOffset, rect.size.width, rect.size.height-yOffset);
    [attr drawInRect:textRect];
}

- (void)updateUIWithCategory:(id<MWCategoryItemProtocol>)category
                    isSelect:(BOOL)isSelect {
    self.category = category;
    self.isSelect = isSelect;
    [self setNeedsDisplay];
}

+ (CGFloat)WidthForCategory:(id<MWCategoryItemProtocol>)category {
    NSString *categoryName = category.categoryName;
    
    CGFloat maxWidth = 100.f;
    CGFloat categoryNameWidth = [categoryName boundingRectWithSize:CGSizeMake(maxWidth, 30.f) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: kMWCategoryTabButtonSelectedFont, NSParagraphStyleAttributeName: [[self class] paragraphStyle], NSKernAttributeName: kMWCategoryTabButtonKern} context:nil].size.width;
    return categoryNameWidth+20.f;
}

@end

#pragma mark - MWCategoryTabView

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
}

#pragma mark - Setter
- (void)setCategories:(NSArray<id<MWCategoryItemProtocol>> *)categories {
    if (categories == _categories) { return; }
    
    _selectIndex = -1;
    _categories = categories;
    [self _updateFrame];
    [self _updateButtonsUI];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (selectIndex == _selectIndex) { return; }
    
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
    if (index == self.selectIndex || index < 0 || index >= self.categories.count) { return; }
    
    self.selectIndex = index;
    [self _adjustScrollPositionForSelectCategory:animated];
}

#pragma mark - Action
- (void)clickCategoryButton:(MWCategoryTabButton *)sender {
    NSInteger newSelectedIndex = [self.categories indexOfObject:sender.category];
    if (newSelectedIndex == self.selectIndex) { return; }
    
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
    if (width==0 || self.contentSize.width < width) { return; }
    
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
