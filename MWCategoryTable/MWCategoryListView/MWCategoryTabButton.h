//
//  MWCategoryTabButton.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWCategoryItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWCategoryTabButton : UIButton

@property (nonatomic, strong) id<MWCategoryItemProtocol> category;

- (void)updateUIWithCategory:(id<MWCategoryItemProtocol>)category
                    isSelect:(BOOL)isSelect;
+ (CGFloat)WidthForCategory:(id<MWCategoryItemProtocol>)category;

@end

NS_ASSUME_NONNULL_END
