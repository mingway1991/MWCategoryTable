//
//  MWCategoryModel.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWCategoryItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWCategoryModel : NSObject <MWCategoryItemProtocol>

@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *categoryType;

@end

NS_ASSUME_NONNULL_END
