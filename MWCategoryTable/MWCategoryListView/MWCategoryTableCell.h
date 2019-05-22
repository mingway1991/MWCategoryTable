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

@class MWCategoryTableCell;

NS_ASSUME_NONNULL_BEGIN

@protocol MWCategoryTableCellDelegate <NSObject>

- (void)tableCellUpdateOffsetY:(MWCategoryTableCell *)tableCell
                      category:(id<MWCategoryItemProtocol>)category
                    newOffsetY:(CGFloat)offsetnewOffsetY;

@end

@interface MWCategoryTableCell : UICollectionViewCell

@property (nonatomic, weak) id<MWCategoryTableCellDelegate> delegate;
@property (nonatomic, strong) id<MWCategoryItemProtocol> category;
@property (nonatomic, assign) UIEdgeInsets parentInset; // 父视图的inset

- (void)updateOffsetY:(CGFloat)offsetY;

@end

NS_ASSUME_NONNULL_END
