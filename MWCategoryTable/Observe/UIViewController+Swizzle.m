//
//  UIViewController+Swizzle.m
//  Lvmm
//
//  Created by 石茗伟 on 2019/4/29.
//  Copyright © 2019 Lvmama. All rights reserved.
//

#import "UIViewController+Swizzle.h"
#import <objc/runtime.h>
#import <objc/objc.h>

#define GET_ARRAY_LEN(array,len){len = (sizeof(array) / sizeof(array[0]));}

static NSString *isFirstLoadKey = @"isFirstLoadKey";
static NSString *beginTimeKey = @"beginTimeKey";
static NSString *endTimeKey = @"endTimeKey";

const NSString* excludeClassNames[2] = {
    @"UISystemKeyboardDockController",
    @"UICompatibilityInputViewController"
};

@implementation UIViewController (Swizzle)

+ (void)load {
    // 交换方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethodWithOriginalSelector:@selector(viewDidLoad) swizzledSelector:@selector(lv_viewDidload)];
        [self swizzleMethodWithOriginalSelector:@selector(viewWillAppear:) swizzledSelector:@selector(lv_viewWillAppear:)];
        [self swizzleMethodWithOriginalSelector:@selector(viewDidAppear:) swizzledSelector:@selector(lv_viewDidAppear:)];
        [self swizzleMethodWithOriginalSelector:@selector(viewWillDisappear:) swizzledSelector:@selector(lv_viewWillDisappear:)];
        [self swizzleMethodWithOriginalSelector:@selector(viewDidDisappear:) swizzledSelector:@selector(lv_viewDidDisappear:)];
    });
}

+ (void)swizzleMethodWithOriginalSelector:(SEL)originalSelector
                         swizzledSelector:(SEL)swizzledSelector {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (BOOL)_checkNeedRecord {
    // 排除不需要的类
    int len;
    GET_ARRAY_LEN(excludeClassNames, len);
    for (int i=0; i<len; i++) {
        NSString *excludeClassName = [NSString stringWithFormat:@"%@", excludeClassNames[i]];
        if ([excludeClassName isEqualToString:NSStringFromClass([self class])]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -
#pragma mark Methods
- (void)lv_viewWillAppear:(BOOL)animated {
    [self lv_viewWillAppear:animated];
    
    if (![self _checkNeedRecord]) return;
    
    // 处理
    if ([self isFirstLoad]) {
        [self setBeginTime:[NSDate date]];
    }
}

- (void)lv_viewDidAppear:(BOOL)animated {
    [self lv_viewDidAppear:animated];
    
    if (![self _checkNeedRecord]) return;
    
    // 处理
    if ([self isFirstLoad]) {
        [self setEndTime:[NSDate date]];
        NSLog(@"##<%@>## %@:%f", self.title ?: @"未命名", NSStringFromClass([self class]), [[self endTime] timeIntervalSinceDate:[self beginTime]]);
        [self setIsFirstLoad:NO];
    }
}

- (void)lv_viewWillDisappear:(BOOL)animated {
    [self lv_viewWillDisappear:animated];
    
    if (![self _checkNeedRecord]) return;
}

- (void)lv_viewDidDisappear:(BOOL)animated {
    [self lv_viewDidDisappear:animated];
    
    if (![self _checkNeedRecord]) return;
}

- (void)lv_viewDidload {
    [self lv_viewDidload];
    
    if (![self _checkNeedRecord]) return;
    
    // 处理
    [self setIsFirstLoad:YES];
}

#pragma mark -
#pragma mark Property
- (void)setBeginTime:(NSDate *)beginTime {
    objc_setAssociatedObject(self, &beginTimeKey, beginTime, OBJC_ASSOCIATION_RETAIN);
}

- (NSDate *)beginTime {
    return objc_getAssociatedObject(self, &beginTimeKey);
}

- (void)setEndTime:(NSDate *)endTime {
    objc_setAssociatedObject(self, &endTimeKey, endTime, OBJC_ASSOCIATION_RETAIN);
}

- (NSDate *)endTime {
    return objc_getAssociatedObject(self, &endTimeKey);
}

- (void)setIsFirstLoad:(BOOL)isFirstLoad {
    objc_setAssociatedObject(self, &isFirstLoadKey, @(isFirstLoad), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isFirstLoad {
    return [objc_getAssociatedObject(self, &isFirstLoadKey) boolValue];
}

@end
