#import "YXLURLParser.h"
#import "YXLAuthParameters.h"
#import "YXLError.h"
#import "YXLHostProvider.h"
#import "YXLQueryUtils.h"
#import "YXLStatisticsDataProvider.h"
#import "YXLSdk+Protected.h"

static NSString *const kYXLURLOAuthPathFormat = @"https://%@/authorize";
static NSString *const kYXLURLOAuthPathNewFormat = @"https://%@/am/pssp/loginsdk";
static NSString *const kYXLURLModernOpenUrlScheme = @"yandexauth4";
static NSString *const kYXLURLOpenUrlScheme = @"yandexauth2";
static NSString *const kYXLURLOpenUrlSchemeUniversalLink = @"yandexauth";
static NSString *const kYXLURLOpenUrlHost = @"authorize";
static NSString *const kYXLURLResponseTypeKey = @"response_type";
static NSString *const kYXLURLResponseTypeToken = @"token";
static NSString *const kYXLURLResponseTypeCode = @"code";
static NSString *const kYXLURLClientIdKey = @"client_id";
static NSString *const kYXLURLForceConfirmKey = @"force_confirm";
static NSString *const kYXLURLForceConfirmYes = @"yes";
static NSString *const kYXLURLOriginKey = @"origin";
static NSString *const kYXLURLOriginIos = @"yandex_auth_sdk_ios";
static NSString *const kYXLURLRedirectUriKey = @"redirect_uri";
static NSString *const kYXLURLRedirectUriSchemeFormat = @"yx%@";
static NSString *const kYXLURLRedirectUriForUniversalLinkScheme = @"https";
static NSString *const kYXLURLRedirectUriForUniversalLinkTestHostFormat = @"yx%@.oauth-test.yandex.ru";
static NSString *const kYXLURLRedirectUriForUniversalLinkHostFormat = @"yx%@.oauth.yandex.ru";
static NSString *const kYXLURLRedirectUriHost = @"";
static NSString *const kYXLURLRedirectUriPath = @"/auth/finish";
static NSString *const kYXLURLRedirectUriQuery = @"platform=ios";
static NSString *const kYXLURLStateKey = @"state";
static NSString *const kYXLURLPkceKey = @"code_challenge";
static NSString *const kYXLURLPkceMethodKey = @"code_challenge_method";
static NSString *const kYXLURLPkceMethodSha = @"S256";
static NSString *const kYXLURLUidKey = @"uid";
static NSString *const kYXLURLLoginKey = @"login_hint";
static NSString *const kYXLURLPhoneKey = @"phone_hint";
static NSString *const kYXLURLFirstNameKey = @"first_name_hint";
static NSString *const kYXLURLLastNameKey = @"last_name_hint";
static NSString *const kYXLURLForceFullscreenKey = @"force_fullscreen";
static NSString *const kYXLURLCustomValues = @"custom_values";
static NSString *const kYXLURLScopesValues = @"scope";
static NSString *const kYXLURLOptionalScopesValues = @"optional_scope";

static NSString *const kYXLURLErrorKey = @"error";
static NSString *const kYXLURLTokenKey = @"access_token";
static NSString *const kYXLURLCodeKey = @"code";

struct {
    __unsafe_unretained NSString *const accessDenied;
    __unsafe_unretained NSString *const invalidScope;
    __unsafe_unretained NSString *const invalidClient;
} static const YXLURLParserErrorValues = {
    .accessDenied = @"access_denied",
    .invalidScope = @"invalid_scope",
    .invalidClient = @"invalid_client",
};

@implementation YXLURLParser

+ (NSString *)modernOpenURLScheme
{
    return kYXLURLModernOpenUrlScheme;
}

+ (NSString *)openURLScheme
{
    return kYXLURLOpenUrlScheme;
}

+ (NSString *)openURLSchemeUniversalLink
{
    return kYXLURLOpenUrlSchemeUniversalLink;
}

+ (NSString *)redirectURLSchemeWithAppId:(NSString *)appId
{
    return [NSString stringWithFormat:kYXLURLRedirectUriSchemeFormat, appId];
}

+ (NSURL *)authorizationURLWithParameters:(YXLAuthParameters *)parameters
{
    NSParameterAssert(parameters);
    return [self urlWithPath:[NSString stringWithFormat:kYXLURLOAuthPathFormat, YXLHostProvider.oauthHost]
                  parameters:parameters
        statisticsParameters:YXLStatisticsDataProvider.statisticsParameters
                    isForWeb:YES];
}

+ (NSURL *)authorizationUniversalLinkWithParameters:(YXLAuthParameters *)parameters
{
    NSParameterAssert(parameters);
    return [self urlWithPath:[NSString stringWithFormat:kYXLURLOAuthPathNewFormat, YXLHostProvider.universalLinksHost]
                  parameters:parameters
        statisticsParameters:YXLStatisticsDataProvider.statisticsParameters
                    isForWeb:YES];
}

+ (NSURL *)modernOpenURLWithParameters:(YXLAuthParameters *)parameters
{
    NSParameterAssert(parameters);
  NSURLComponents *components = [[NSURLComponents alloc] init];
  components.scheme = self.modernOpenURLScheme;
  components.host = kYXLURLOpenUrlHost;
  return [self urlWithPath:components.URL.absoluteString parameters:parameters statisticsParameters:nil];
}

+ (NSURL *)openURLWithParameters:(YXLAuthParameters *)parameters
{
    NSParameterAssert(parameters);
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = self.openURLScheme;
    components.host = kYXLURLOpenUrlHost;
    return [self urlWithPath:components.URL.absoluteString parameters:parameters statisticsParameters:nil];
}

+ (NSURL *)openURLUniversalLinkWithParameters:(YXLAuthParameters *)parameters
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = self.openURLSchemeUniversalLink;
    components.host = kYXLURLOpenUrlHost;
    YXLAuthParameters *queryParameters = [[YXLAuthParameters alloc] initWithAppId:parameters.appId
                                                                            state:parameters.state
                                                                             pkce:parameters.pkce
                                                                              uid:parameters.uid
                                                                            login:parameters.login
                                                                            phone:parameters.phone
                                                                        firstName:parameters.firstName
                                                                         lastName:parameters.lastName
                                                                       fullscreen:parameters.forceFullscreen
                                                                     customValues:parameters.customValues];
    return [self urlWithPath:components.URL.absoluteString parameters:queryParameters statisticsParameters:nil];
}

+ (NSURL *)urlWithPath:(NSString *)path
          parameters:(YXLAuthParameters *)parameters
statisticsParameters:(NSDictionary *)statisticsParameters
{
    return [self urlWithPath:path parameters:parameters statisticsParameters:statisticsParameters isForWeb:NO];
}

+ (NSURL *)urlWithPath:(NSString *)path
            parameters:(YXLAuthParameters *)parameters
  statisticsParameters:(NSDictionary *)statisticsParameters
              isForWeb:(BOOL)forWeb
{
    NSMutableDictionary *queryParameters = [statisticsParameters ?: @{} mutableCopy];
    queryParameters[kYXLURLResponseTypeKey] = (parameters.pkce != nil) ? kYXLURLResponseTypeCode : kYXLURLResponseTypeToken;
    if (YXLSdk.shared.forceConfirmationDialog == YES || forWeb == YES) {
        queryParameters[kYXLURLForceConfirmKey] = kYXLURLForceConfirmYes;
    }
    queryParameters[kYXLURLOriginKey] = kYXLURLOriginIos;
    queryParameters[kYXLURLClientIdKey] = parameters.appId;
    queryParameters[kYXLURLStateKey] = parameters.state;
    if (parameters.pkce != nil) {
        queryParameters[kYXLURLPkceKey] = parameters.pkce;
        queryParameters[kYXLURLPkceMethodKey] = kYXLURLPkceMethodSha;
        queryParameters[kYXLURLRedirectUriKey] = [self redirectURIWithAppId:parameters.appId];
    }
    else {
        queryParameters[kYXLURLRedirectUriKey] = [self redirectURIForUniversalLinkWithAppId:parameters.appId];
    }
    queryParameters[kYXLURLLoginKey] = parameters.login;
    queryParameters[kYXLURLPhoneKey] = parameters.phone;
    queryParameters[kYXLURLFirstNameKey] = parameters.firstName;
    queryParameters[kYXLURLLastNameKey] = parameters.lastName;
    if (parameters.uid > 0) {
        queryParameters[kYXLURLUidKey] = [NSString stringWithFormat:@"%lld", parameters.uid];
    }
    if (parameters.forceFullscreen == YES) {
        queryParameters[kYXLURLForceFullscreenKey] = @(1);
    }
    if (parameters.customValues) {
        queryParameters[kYXLURLCustomValues] = parameters.customValues;
    }
    if (parameters.scopes) {
        queryParameters[kYXLURLScopesValues] = parameters.scopes;
    }
    if (parameters.optionalScopes) {
        queryParameters[kYXLURLOptionalScopesValues] = parameters.optionalScopes;
    }
    NSString *query = [YXLQueryUtils queryStringFromParameters:queryParameters];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", path, query]];
}

+ (NSString *)redirectURIWithAppId:(NSString *)appId
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = [self redirectURLSchemeWithAppId:appId];
    components.host = kYXLURLRedirectUriHost;
    components.path = kYXLURLRedirectUriPath;
    components.query = kYXLURLRedirectUriQuery;
    return components.URL.absoluteString;
}

+ (NSString *)redirectURIForUniversalLinkWithAppId:(NSString *)appId
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kYXLURLRedirectUriForUniversalLinkScheme;
    if (YXLSdk.shared.shouldUseTestEnvironment) {
        components.host = [NSString stringWithFormat:kYXLURLRedirectUriForUniversalLinkTestHostFormat, appId];
    } else {
        components.host = [NSString stringWithFormat:kYXLURLRedirectUriForUniversalLinkHostFormat, appId];
    }
    components.path = kYXLURLRedirectUriPath;
    components.query = kYXLURLRedirectUriQuery;
    return components.URL.absoluteString;
}

+ (NSError *)errorFromURL:(NSURL *)url
{
    NSString *errorValue = [self parametersFromURL:url][kYXLURLErrorKey];
    return (errorValue != nil) ? [NSError errorWithDomain:kYXLErrorDomain
                                                     code:[self errorCodeFromValue:errorValue]
                                                 userInfo:@{ NSLocalizedFailureReasonErrorKey: errorValue }] : nil;
}

+ (NSString *)codeFromURL:(NSURL *)url
{
    return [self parametersFromURL:url][kYXLURLCodeKey];
}

+ (NSString *)stateFromURL:(NSURL *)url
{
    return [self parametersFromURL:url][kYXLURLStateKey];
}

+ (NSString *)uidFromURL:(NSURL *)url
{
    return [self parametersFromURL:url][kYXLURLUidKey];
}

+ (NSError *)errorFromUniversalLinkURL:(NSURL *)url
{
    NSString *errorValue = [self parametersFromFragmentOfURL:url][kYXLURLErrorKey];
    return (errorValue != nil) ? [NSError errorWithDomain:kYXLErrorDomain
                                                     code:[self errorCodeFromValue:errorValue]
                                                 userInfo:@{ NSLocalizedFailureReasonErrorKey: errorValue }] : nil;
}

+ (NSString *)tokenFromUniversalLinkURL:(NSURL *)url
{
    return [self parametersFromFragmentOfURL:url][kYXLURLTokenKey];
}

+ (NSString *)stateFromUniversalLinkURL:(NSURL *)url
{
    return [self parametersFromFragmentOfURL:url][kYXLURLStateKey];
}

+ (BOOL)isOpenURL:(NSURL *)url appId:(NSString *)appId
{
    return [url.scheme isEqualToString:[self redirectURLSchemeWithAppId:appId]];
}

+ (NSDictionary<NSString *, NSString *> *)parametersFromURL:(NSURL *)url
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    return [YXLQueryUtils parametersFromQueryString:components.query];
}

+ (NSDictionary<NSString *, NSString *> *)parametersFromFragmentOfURL:(NSURL *)url
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    return [YXLQueryUtils parametersFromQueryString:components.fragment];
}

+ (YXLErrorCode)errorCodeFromValue:(NSString *)value
{
    NSParameterAssert(value);
    YXLErrorCode code = YXLErrorCodeOther;
    if ([value isEqualToString:YXLURLParserErrorValues.accessDenied]) {
        code = YXLErrorCodeDenied;
    }
    else if ([value isEqualToString:YXLURLParserErrorValues.invalidClient]) {
        code = YXLErrorCodeInvalidClient;
    }
    else if ([value isEqualToString:YXLURLParserErrorValues.invalidScope]) {
        code = YXLErrorCodeInvalidScope;
    }
    return code;
}

@end
