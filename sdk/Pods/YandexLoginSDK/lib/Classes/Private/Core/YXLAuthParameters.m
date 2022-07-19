#import "YXLAuthParameters.h"

@implementation YXLAuthParameters

- (instancetype)initWithAppId:(NSString *)appId
                        state:(NSString *)state
                         pkce:(NSString *)pkce
                          uid:(long long)uid
                        login:(NSString *)login
{
    self = [super init];
    if (self != nil) {
        _appId = [appId copy];
        _state = [state copy];
        _pkce = [pkce copy];
        _uid = uid;
        _login = [login copy];
    }
    return self;
}

@end
