#import "YXLStatesManager.h"
#import "YXLStorage.h"

static const NSInteger kYXLStatesMaxCount = 50;

@interface YXLStatesManager ()

@property (nonatomic, strong, readonly) id<YXLStorage> storage;

@end

@implementation YXLStatesManager

- (instancetype)initWithStorage:(id<YXLStorage>)storage
{
    NSParameterAssert(storage);
    self = [super init];
    if (self != nil) {
        _storage = storage;
    }
    return self;
}

- (NSString *)generateNewState
{
    NSDictionary *storedObject = self.storage.storedObject;
    NSString *state = [NSProcessInfo processInfo].globallyUniqueString;
    while (storedObject[state] != nil) {
        state = [NSProcessInfo processInfo].globallyUniqueString;
    }
    NSMutableDictionary *mutableStoredObject = [storedObject ?: @{} mutableCopy];
    if (mutableStoredObject.count == kYXLStatesMaxCount) {
        mutableStoredObject[[self oldestStateInStoredObject:mutableStoredObject]] = nil;
    }
    mutableStoredObject[state] = [NSDate date];
    self.storage.storedObject = mutableStoredObject;
    
    return state;
}

- (NSString *)oldestStateInStoredObject:(NSDictionary *)storedObject
{
    NSDate *oldestDate = nil;
    NSString *state = nil;
    for (NSString *key in storedObject) {
        NSDate *date = storedObject[key];
        if (oldestDate == nil || [oldestDate compare:date] == NSOrderedDescending) {
            state = key;
            oldestDate = date;
        }
    }
    return state;
}

- (BOOL)isValidState:(NSString *)state
{
    NSParameterAssert(state);
    return self.storage.storedObject[state] != nil;
}

- (void)deleteState:(NSString *)state
{
    NSParameterAssert(state);
    NSMutableDictionary *mutableStoredObject = [self.storage.storedObject mutableCopy];
    mutableStoredObject[state] = nil;
    self.storage.storedObject = mutableStoredObject;
}

- (void)deleteAllStates
{
    self.storage.storedObject = nil;
}

@end
