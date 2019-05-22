//
//  MWNetwork.h
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/22.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MWNetwork : NSObject

- (void)requestGetUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;
- (void)requestPostUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;
- (void)requestPutUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;
- (void)requestDeleteUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void(^)(id result))success Failed:(void(^)(NSString *errorMsg))failed;

@end

NS_ASSUME_NONNULL_END
