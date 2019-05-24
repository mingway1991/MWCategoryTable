//
//  MWCategoryTabView.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWCategoryItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - MWCategoryTabButton

@interface MWCategoryTabButton : UIButton

@property (nonatomic, strong) id<MWCategoryItemProtocol> category;

- (void)updateUIWithCategory:(id<MWCategoryItemProtocol>)category
                    isSelect:(BOOL)isSelect;
+ (CGFloat)WidthForCategory:(id<MWCategoryItemProtocol>)category;

@end

#pragma mark - MWCategoryTabViewDelegate

@class MWCategoryTabView;
@protocol MWCategoryTabViewDelegate <NSObject>

@optional
// 更新选中索引前的回调
- (void)tabView:(MWCategoryTabView *)tabView willSelectIndex:(NSInteger)index;
// 更新选中索引后的回调
- (void)tabView:(MWCategoryTabView *)tabView didSelectIndex:(NSInteger)index;

@end

#pragma mark - MWCategoryTabView

@interface MWCategoryTabView : UIScrollView

@property (nonatomic, weak) id<MWCategoryTabViewDelegate> tabDelegate;
@property (nonatomic, strong) NSArray<id<MWCategoryItemProtocol>> *categories;
@property (nonatomic, assign, readonly) NSInteger selectIndex; // 默认-1

- (void)scrollAndSelectIndex:(NSInteger)index
                    animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
