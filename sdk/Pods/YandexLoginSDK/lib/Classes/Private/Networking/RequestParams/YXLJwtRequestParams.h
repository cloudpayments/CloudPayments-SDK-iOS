#import "YXLRequestParams.h"

@interface YXLJwtRequestParams : NSObject <YXLRequestParams>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithToken:(NSString *)token;

@end
