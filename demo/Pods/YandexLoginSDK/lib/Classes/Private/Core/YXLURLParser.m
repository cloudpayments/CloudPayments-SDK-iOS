#import "YXLURLParser.h"
#import "YXLAuthParameters.h"
#import "YXLError.h"
#import "YXLHostProvider.h"
#import "YXLQueryUtils.h"
#import "YXLStatisticsDataProvider.h"

static NSString *const kYXLURLOAuthPathFormat = @"https://%@/authorize";
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
        statisticsParameters:YXLStatisticsDataProvider.statisticsParameters];
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
                                                                             pkce:nil
                                                                              uid:0
                                                                            login:nil];
    return [self urlWithPath:components.URL.absoluteString parameters:queryParameters statisticsParameters:nil];
}

+ (NSURL *)urlWithPath:(NSString *)path
            parameters:(YXLAuthParameters *)parameters
  statisticsParameters:(NSDictionary *)statisticsParameters
{
    NSMutableDictionary *queryParameters = [statisticsParameters ?: @{} mutableCopy];
    queryParameters[kYXLURLResponseTypeKey] = (parameters.pkce != nil) ? kYXLURLResponseTypeCode : kYXLURLResponseTypeToken;
    queryParameters[kYXLURLForceConfirmKey] = kYXLURLForceConfirmYes;
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
    if (parameters.uid > 0) {
        queryParameters[kYXLURLUidKey] = [NSString stringWithFormat:@"%lld", parameters.uid];
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
    components.host = [NSString stringWithFormat:kYXLURLRedirectUriForUniversalLinkHostFormat, appId];
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
