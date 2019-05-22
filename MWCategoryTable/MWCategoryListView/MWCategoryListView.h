//
//  MWCategoryListView.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWCategoryItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWCategoryListView : UIView

@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat bottomInset;
@property (nonatomic, assign) CGFloat tabViewHeight; // 默认40
@property (nonatomic, strong) NSArray<id<MWCategoryItemProtocol>> *categories;

- (instancetype)initWithCategories:(NSArray<id<MWCategoryItemProtocol>> *)categories;
- (instancetype)initWithFrame:(CGRect)frame
                   categories:(NSArray<id<MWCategoryItemProtocol>> *)categories;

@end

NS_ASSUME_NONNULL_END
