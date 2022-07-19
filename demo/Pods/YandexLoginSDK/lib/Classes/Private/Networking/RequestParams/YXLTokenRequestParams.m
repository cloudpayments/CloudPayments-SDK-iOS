#import "YXLTokenRequestParams.h"
#import "YXLHostProvider.h"

@interface YXLTokenRequestParams ()

@property (nonatomic, copy, readonly) NSString *code;
@property (nonatomic, copy, readonly) NSString *codeVerifier;
@property (nonatomic, copy, readonly) NSString *appId;

@end

@implementation YXLTokenRequestParams

- (instancetype)initWithCode:(NSString *)code codeVerifier:(NSString *)codeVerifier appId:(NSString *)appId
{
    NSParameterAssert(code);
    NSParameterAssert(codeVerifier);
    NSParameterAssert(appId);
    self = [super init];
    if (self != nil) {
        _code = [code copy];
        _codeVerifier = [codeVerifier copy];
        _appId = [appId copy];
    }
    return self;
}

- (NSString *)path
{
    return [NSString stringWithFormat:@"https://%@/token", YXLHostProvider.oauthHost];
}

- (NSDictionary<NSString *, NSString *> *)params
{
    return @{
             @"code" : self.code,
             @"code_verifier" : self.codeVerifier,
             @"client_id" : self.appId,
             @"grant_type" : @"authorization_code",
             };
}

@end
