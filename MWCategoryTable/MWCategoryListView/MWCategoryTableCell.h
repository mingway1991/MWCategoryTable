//
//  MWCategoryTableCell.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWCategoryItemProtocol.h"
#import "MWCategoryTableManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWCategoryTableCell : UICollectionViewCell

@property (nonatomic, strong) id<MWCategoryItemProtocol> category;

- (void)updateInset:(UIEdgeInsets)inset;
- (void)updateOffsetY:(CGFloat)offsetY;

@end

NS_ASSUME_NONNULL_END
