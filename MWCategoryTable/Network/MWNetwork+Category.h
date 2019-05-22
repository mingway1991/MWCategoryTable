//
//  MWNetwork+Category.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/22.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWNetwork.h"

@class MWNewsModel;

NS_ASSUME_NONNULL_BEGIN

@interface MWNetwork (Category)

- (void)loadNewsWithCategoryType:(NSString *)categoryType
                    maxBehotTime:(NSNumber *)maxBehotTime
                    successBlock:(void(^)(NSArray<MWNewsModel *> *newsModels, BOOL hasMore, NSNumber *maxBehotTime))successBlock
                    failureBlock:(void(^)(NSString *msg))failureBlock;

@end

NS_ASSUME_NONNULL_END
