//
//  MWCategoryNewsCell.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/22.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWNewsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWCategoryNewsCell : UITableViewCell

- (void)updateUIWithNewsModel:(MWNewsModel *)newsModel;
+ (CGFloat)HeightForNewsModel:(MWNewsModel *)newsModel;

@end

NS_ASSUME_NONNULL_END
