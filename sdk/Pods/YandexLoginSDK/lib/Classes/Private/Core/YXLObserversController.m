#import "YXLObserversController.h"
#import "YXLObserver.h"

@interface YXLObserversController ()

@property (nonatomic, strong, readonly) NSHashTable *hashTable;

@end

@implementation YXLObserversController

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _hashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory | NSPointerFunctionsObjectPointerPersonality];
    }
    return self;
}

- (void)addObserver:(id<YXLObserver>)observer
{
    NSParameterAssert(observer);
    @synchronized(self) {
        [self.hashTable addObject:observer];
    }
}

- (void)removeObserver:(id<YXLObserver>)observer
{
    NSParameterAssert(observer);
    @synchronized(self) {
        [self.hashTable removeObject:observer];
    }
}

- (id<NSFastEnumeration>)observers
{
    @synchronized(self) {
        return [self.hashTable copy];
    }
}

- (void)notifyLoginDidFinishWithResult:(id<YXLLoginResult>)result
{
    id<NSFastEnumeration> observers = self.observers;
    for (id<YXLObserver> observer in observers) {
        [observer loginDidFinishWithResult:result];
    }
}

- (void)notifyLoginDidFinishWithError:(NSError *)error
{
    id<NSFastEnumeration> observers = self.observers;
    for (id<YXLObserver> observer in observers) {
        [observer loginDidFinishWithError:error];
    }
}

@end
