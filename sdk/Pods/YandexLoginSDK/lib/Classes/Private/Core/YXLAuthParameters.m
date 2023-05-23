#import "YXLAuthParameters.h"

@implementation YXLAuthParameters


- (instancetype)initWithAppId:(NSString *)appId
                        state:(NSString *)state
                         pkce:(NSString *)pkce
                          uid:(long long)uid
                        login:(NSString *)login
                   fullscreen:(BOOL)fullscreen
{
    return [self initWithAppId:appId
                         state:state
                          pkce:pkce
                           uid:uid
                         login:login
                         phone:nil
                     firstName:nil
                      lastName:nil
                    fullscreen:fullscreen
                  customValues:nil
    ];
}

- (instancetype)initWithAppId:(NSString *)appId
                        state:(NSString *)state
                         pkce:(NSString *)pkce
                          uid:(long long)uid
                        login:(NSString *)login
                        phone:(NSString *)phone
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                   fullscreen:(BOOL)fullscreen
                 customValues:(NSString *)customValues
{
  return [self initWithAppId:appId
                       state:state
                        pkce:pkce
                         uid:uid
                       login:login
                       phone:phone
                   firstName:firstName
                    lastName:lastName
                  fullscreen:fullscreen
                customValues:customValues
                      scopes:nil
              optionalScopes:nil];
}

- (instancetype)initWithAppId:(NSString *)appId
                        state:(NSString *)state
                         pkce:(NSString *)pkce
                          uid:(long long)uid
                        login:(NSString *)login
                        phone:(NSString *)phone
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                   fullscreen:(BOOL)fullscreen
                 customValues:(NSString *)customValues
                       scopes:(NSString *)scopes
               optionalScopes:(NSString *)optionalScopes
{
    self = [super init];
    if (self != nil) {
        _appId = [appId copy];
        _state = [state copy];
        _pkce = [pkce copy];
        _uid = uid;
        _login = [login copy];
        _phone = [phone copy];
        _firstName = [firstName copy];
        _lastName = [lastName copy];
        _forceFullscreen = fullscreen;
        _customValues = customValues;
        _scopes = scopes;
        _optionalScopes = optionalScopes;
    }
    return self;
}

@end
