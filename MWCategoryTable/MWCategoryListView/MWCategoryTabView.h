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

@class MWCategoryTabView;

@protocol MWCategoryTabViewDelegate <NSObject>

- (void)tabView:(MWCategoryTabView *)tabView didSelectIndex:(NSInteger)index;

@end

@interface MWCategoryTabView : UIScrollView

@property (nonatomic, weak) id<MWCategoryTabViewDelegate> tabDelegate;
@property (nonatomic, strong) NSArray<id<MWCategoryItemProtocol>> *categories;
@property (nonatomic, assign, readonly) NSInteger selectIndex; // 默认0

- (void)scrollAndSelectIndex:(NSInteger)index
                    animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
