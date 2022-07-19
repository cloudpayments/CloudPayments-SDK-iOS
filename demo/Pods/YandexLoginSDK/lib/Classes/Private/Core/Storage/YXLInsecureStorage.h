#import "YXLStorage.h"

@interface YXLInsecureStorage : NSObject <YXLStorage>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithKey:(NSString *)key;

@end
