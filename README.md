# LockTest
ios_lock_Test

关于ios锁的一些测试

NSLock: 1.279376 sec
NSLock+IMP Cache: 1.208117 sec
NSRecursiveLock Cache: 1.825573 sec
NSConditionLock Cache: 3.942814 sec
dispatch_semaphore Cache: 0.642162 sec
pthread_mutex: 0.901667 sec
OSSpinlock: 0.431712 sec
@synchronized: 5.150229 sec

性能上， OSSpinlock 性能最高 ， dispatch_semaphore 与 pthread_mutex 性能都不错。
因为mutex及semaphore都偏向底层C实现，所以性能都很好。

但是因为OSSpinlock 被发现有bug，所以 建议 使用 semaphore 和 mutex。

参考资料：
http://perpendiculo.us/2009/09/synchronized-nslock-pthread-osspinlock-showdown-done-right
http://www.dreamingwish.com/article/the-ios-multithreaded-programming-guide-4-thread-synchronization.html
http://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios
