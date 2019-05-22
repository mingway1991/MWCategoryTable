//
//  MWNetwork+Category.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/22.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWNetwork+Category.h"
#import "MWNewsModel.h"
#import "MWWebApi.h"

@implementation MWNetwork (Category)

- (void)loadNewsWithCategoryType:(NSString *)categoryType
                    maxBehotTime:(NSNumber *)maxBehotTime
                    successBlock:(void(^)(NSArray<MWNewsModel *> *newsModels, BOOL hasMore, NSNumber *maxBehotTime))successBlock
                    failureBlock:(void(^)(NSString *msg))failureBlock {
    [self requestGetUrl:kCategoryNewsApi Parameters:@{@"category": categoryType, @"max_behot_time": maxBehotTime} Success:^(id result) {
        NSString *message = result[@"message"];
        if ([message isEqualToString:@"success"]) {
            BOOL hasMore = [result[@"has_more"] boolValue];
            NSNumber *maxBehotTime = result[@"bext"][@"max_behot_time"];
            successBlock([NSArray modelArrayWithClass:[MWNewsModel class] json:result[@"data"]], hasMore, maxBehotTime);
        } else {
            failureBlock(message);
        }
    } Failed:^(NSString *errorMsg) {
        failureBlock(errorMsg);
    }];
}

@end
