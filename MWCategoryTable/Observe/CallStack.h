//
//  CallStack.h
//  Lvmm
//
//  Created by 石茗伟 on 2019/5/20.
//  Copyright © 2019 Lvmama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallStackItem : NSObject

@property (nonatomic, copy) NSString *fname;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *sname;
@property (nonatomic, copy) NSString *offset;

@end

@interface CallStackInfo : NSObject

@property (nonatomic, assign) thread_t thread;
@property (nonatomic, strong) NSArray<CallStackItem *> *items;

@end

@interface CallStack : NSObject

- (CallStackInfo *)getCallStackInfo:(NSThread *)nsthread;

@end

NS_ASSUME_NONNULL_END
