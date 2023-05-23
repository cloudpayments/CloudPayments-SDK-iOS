#import "YXLJwtRequestParams.h"
#import "YXLSdk+Protected.h"

@interface YXLJwtRequestParams ()

@property (nonatomic, copy, readonly) NSString *token;

@end

@implementation YXLJwtRequestParams

- (instancetype)initWithToken:(NSString *)token
{
    NSParameterAssert(token);
    self = [super init];
    if (self != nil) {
        _token = [token copy];
    }
    return self;
}

- (NSString *)path
{
    if (YXLSdk.shared.shouldUseTestEnvironment) {
        return @"https://login-test.yandex.ru/info";
    } else {
        return @"https://login.yandex.ru/info";
    }
}

- (NSDictionary<NSString *, NSString *> *)params
{
    return @{
             @"oauth_token" : self.token,
             @"format" : @"jwt",
             };
}

@end
