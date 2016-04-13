//
//  main.m
//  LockTest
//
//  Created by Sunny on 16/4/11.
//  Copyright © 2016年 Sunny. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import <objc/objc-runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>
#import <pthread.h>

#define ITERATIONS   (1024 * 1024 * 32)

int main(int argc, char * argv[])
{
    
    double then, now;
    unsigned int i;
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    
    pthread_cond_t condition = PTHREAD_COND_INITIALIZER;
    
    OSSpinLock spinlock = OS_SPINLOCK_INIT;
    
    
    @autoreleasepool
    {
        NSLock *lock = [NSLock new];
        then = CFAbsoluteTimeGetCurrent();
        for(i=0;i<ITERATIONS;++i)
        {
            [lock lock];
            [lock unlock];
        }
        now = CFAbsoluteTimeGetCurrent();
        printf("NSLock: %f sec\n", now-then);
        
        
        then = CFAbsoluteTimeGetCurrent();
        IMP lockLock = [lock methodForSelector:@selector(lock)];
        IMP unlockLock = [lock methodForSelector:@selector(unlock)];
        for(i=0;i<ITERATIONS;++i)
        {
        //TODO: ARC下 IMP使用需要转换      MRC下 可以直接使用
//            lockLock(lock,@selector(lock));
//            unlockLock(lock,@selector(unlock));
            void (*funcLock)(id , SEL) = (void *)lockLock;
            funcLock(lock , @selector(lock));
            
            void (*funcUnLock)(id , SEL) = (void *)unlockLock;
            funcUnLock(lock , @selector(unlock));
        }
        now = CFAbsoluteTimeGetCurrent();
        printf("NSLock+IMP Cache: %f sec\n", now-then);
        
        
        then = CFAbsoluteTimeGetCurrent();
        NSRecursiveLock * recursiveLock = [NSRecursiveLock new];
        for (i = 0 ; i < ITERATIONS ; ++i)
        {
            [recursiveLock lock];
            [recursiveLock unlock];
        }
        now = CFAbsoluteTimeGetCurrent();
        printf("NSRecursiveLock Cache: %f sec\n", now-then);
        
        
        then = CFAbsoluteTimeGetCurrent();
        NSConditionLock * conditionLock = [[NSConditionLock alloc] initWithCondition:0x1];
        for (i = 0 ; i < ITERATIONS ; ++i)
        {
            [conditionLock lockWhenCondition:0x1];
//            [conditionLock unlockWithCondition:0x1];
            [conditionLock unlock];
        }
        now = CFAbsoluteTimeGetCurrent();
        printf("NSConditionLock Cache: %f sec\n", now-then);
        
        
        
        then = CFAbsoluteTimeGetCurrent();
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0x1);
        
        for (i = 0 ; i < ITERATIONS ; ++i)
        {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(semaphore);
        }
        now = CFAbsoluteTimeGetCurrent();
        printf("dispatch_semaphore Cache: %f sec\n", now-then);
        
        
        then = CFAbsoluteTimeGetCurrent();
        for(i=0;i<ITERATIONS;++i)
        {
            pthread_mutex_lock(&mutex);
            
//            pthread_cond_wait(&condition, &mutex);
//            pthread_cond_signal(&condition);
            
            pthread_mutex_unlock(&mutex);
//            pthread_cond_signal(&condition);
        }
        pthread_mutex_destroy(&mutex);
        pthread_cond_destroy(&condition);
        
        now = CFAbsoluteTimeGetCurrent();
        printf("pthread_mutex: %f sec\n", now-then);
        
        
        
        then = CFAbsoluteTimeGetCurrent();
        for(i=0;i<ITERATIONS;++i)
        {
            OSSpinLockLock(&spinlock);
            OSSpinLockUnlock(&spinlock);
        }
        now = CFAbsoluteTimeGetCurrent();
        printf("OSSpinlock: %f sec\n", now-then);
        
        
        id obj = [NSObject new];
        
        then = CFAbsoluteTimeGetCurrent();
        for(i=0;i<ITERATIONS;++i)
        {
            @synchronized(obj)
            {
            }
        }
        now = CFAbsoluteTimeGetCurrent();
        printf("@synchronized: %f sec\n", now-then);
    }

    
    return 0;

//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
}
