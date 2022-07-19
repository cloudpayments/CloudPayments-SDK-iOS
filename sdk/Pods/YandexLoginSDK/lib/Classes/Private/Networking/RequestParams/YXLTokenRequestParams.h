#import "YXLRequestParams.h"

@interface YXLTokenRequestParams : NSObject <YXLRequestParams>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCode:(NSString *)code codeVerifier:(NSString *)codeVerifier appId:(NSString *)appId;

@end
