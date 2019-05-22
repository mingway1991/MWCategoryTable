//
//  ObserveCaton.h
//  Lvmm
//
//  Created by 石茗伟 on 2019/4/29.
//  Copyright © 2019 Lvmama. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObserveCaton : NSObject

+ (instancetype)shared;

- (void)start;

@end

NS_ASSUME_NONNULL_END
