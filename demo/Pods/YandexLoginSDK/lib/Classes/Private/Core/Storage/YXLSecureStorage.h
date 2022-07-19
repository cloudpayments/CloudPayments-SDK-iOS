#import "YXLStorage.h"

@interface YXLSecureStorage : NSObject <YXLStorage>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithKey:(NSString *)key;

@end
