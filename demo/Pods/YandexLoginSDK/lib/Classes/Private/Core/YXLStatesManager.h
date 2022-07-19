#import <Foundation/Foundation.h>

@protocol YXLStorage;

@interface YXLStatesManager : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStorage:(id<YXLStorage>)storage;

- (NSString *)generateNewState;
- (BOOL)isValidState:(NSString *)state;
- (void)deleteState:(NSString *)state;
- (void)deleteAllStates;

@end
