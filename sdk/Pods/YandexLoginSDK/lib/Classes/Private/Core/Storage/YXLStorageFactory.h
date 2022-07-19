#import <Foundation/Foundation.h>

@protocol YXLStorage;

@interface YXLStorageFactory : NSObject

@property (class, strong, readonly) id<YXLStorage> loginResultStorage;
@property (class, strong, readonly) id<YXLStorage> pkceStorage;
@property (class, strong, readonly) id<YXLStorage> statesStorage;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
