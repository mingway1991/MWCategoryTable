//
//  ObserveCaton.m
//  Lvmm
//
//  Created by 石茗伟 on 2019/4/29.
//  Copyright © 2019 Lvmama. All rights reserved.
//

#import "ObserveCaton.h"
#import "CallStack.h"

@interface ObserveCaton () {
    CFRunLoopObserverRef _observer;
    dispatch_semaphore_t _semaphore;
    CFRunLoopActivity _activity;
    NSInteger _timeoutCount;
}

@end

@implementation ObserveCaton

+ (instancetype)shared {
    static dispatch_once_t predicate;
    static ObserveCaton * sharedManager;
    dispatch_once(&predicate, ^{
        sharedManager = [[ObserveCaton alloc] init];
    });
    return sharedManager;
}

- (void)start {
    if (_observer) {
        return;
    }
    _semaphore = dispatch_semaphore_create(0);
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    _observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                                            kCFRunLoopAllActivities,
                                                            true,
                                                            0,
                                                            &runLoopObserverCallBack,
                                                            &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    
    // before sources -> before waiting
    // after waiting -> leave runloop
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES) {
            // 假定连续5次超时50ms认为卡顿(当然也包含了单次超时250ms)
            long st = dispatch_semaphore_wait(self->_semaphore, dispatch_time(DISPATCH_TIME_NOW, 50*NSEC_PER_MSEC));
            if (st != 0) {
                if (self->_activity == kCFRunLoopBeforeSources || self->_activity == kCFRunLoopAfterWaiting) {
                    if (++self->_timeoutCount < 5)
                        continue;
                    CallStackInfo *info = [[[CallStack alloc] init] getCallStackInfo:[NSThread mainThread]];
                    // 上传卡顿堆栈信息
                }
            }
            self->_timeoutCount = 0;
        }
    });
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    ObserveCaton *object = (__bridge ObserveCaton *)(info);
    object->_activity = activity;
    dispatch_semaphore_t semaphore = object->_semaphore;
    dispatch_semaphore_signal(semaphore);
}

@end

/*
 Runloop 核心代码简化逻辑
 
 int32_t __CFRunLoopRun(){
 //通知即将进入runloop    __CFRunLoopDoObservers(KCFRunLoopEntry);
 do    {        // 通知将要处理timer和source
 __CFRunLoopDoObservers(kCFRunLoopBeforeTimers);
 __CFRunLoopDoObservers(kCFRunLoopBeforeSources);
 
 __CFRunLoopDoBlocks();  //处理非延迟的主线程调用
 __CFRunLoopDoSource0(); //处理UIEvent事件
 //GCD dispatch main queue
 CheckIfExistMessagesInMainDispatchQueue();
 // 即将进入休眠
 __CFRunLoopDoObservers(kCFRunLoopBeforeWaiting);
 
 // 等待内核mach_msg事件
 mach_port_t wakeUpPort = SleepAndWaitForWakingUpPorts();
 // Zzz...
 
 // 从等待中醒来
 __CFRunLoopDoObservers(kCFRunLoopAfterWaiting);
 
 // 处理因timer的唤醒
 if (wakeUpPort == timerPort)
 __CFRunLoopDoTimers();
 
 // 处理异步方法唤醒,如dispatch_async
 else if (wakeUpPort == mainDispatchQueuePort)
 __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__()
 
 // UI刷新,动画显示
 else
 __CFRunLoopDoSource1();
 
 // 再次确保是否有同步的方法需要调用
 __CFRunLoopDoBlocks();
 } while (!stop && !timeout);
 
 //通知即将退出runloop
 __CFRunLoopDoObservers(CFRunLoopExit);}
 */
