//
//  MWNetwork.m
//  MWCategoryTable
//
//  Created by 石茗伟 on 2019/5/22.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "MWNetwork.h"
#import "MWWebApi.h"

@import AFNetworking;

@interface MWNetwork ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation MWNetwork

- (void)requestGetUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self.sessionManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

- (void)requestPostUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self.sessionManager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",parameters);
        NSLog(@"%@",responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

- (void)requestPutUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self.sessionManager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",parameters);
        NSLog(@"%@",responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

- (void)requestDeleteUrl:(NSString*)url Parameters:(NSDictionary* _Nullable)parameters Success:(void (^)(id result))success Failed:(void(^)(NSString *errorMsg))failed {
    [self.sessionManager DELETE:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",url);
        NSLog(@"%@",parameters);
        NSLog(@"%@",responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(error.localizedDescription);
    }];
}

#pragma mark - LazyLoad
- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        self.sessionManager =  [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:kToutiaoHost]]; ;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
        _sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sessionManager.requestSerializer.timeoutInterval = 20;
        _sessionManager.securityPolicy.validatesDomainName = NO;
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [_sessionManager setSecurityPolicy:securityPolicy];
    }
    return _sessionManager;
}

@end
