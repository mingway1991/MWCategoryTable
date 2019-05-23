//
//  MWCategoryTableManager.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/21.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWCategoryModel.h"
#import "MWCategoryTableManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWCategoryTableManager : NSObject <MWCategoryTableManagerProtocol>

@property (nonatomic, weak) MWCategoryModel *parentCategoryModel;

@end

NS_ASSUME_NONNULL_END
