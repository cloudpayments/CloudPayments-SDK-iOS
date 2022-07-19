#import "YXLActivationValidator.h"
#import "YXLError.h"
#import "YXLURLParser.h"

@implementation YXLActivationValidator

+ (NSError *)validateActivationWithAppId:(NSString *)appId
{
    NSError *error = nil;
    if (appId == nil) {
        error = [self errorWithCode:YXLActivationErrorCodeNoAppId
                        description:@"Empty app id"
                           recovery:@"Call [YXLSdk activateWithAppId:error:] with application ID from https://oauth.yandex.ru/"];
    } else if (NO == [self infoPlistContainsQueriesScheme:YXLURLParser.openURLScheme]) {
        NSString *description = [NSString stringWithFormat:@"No %@ URL scheme in queries schemes", YXLURLParser.openURLScheme];
        NSString *recovery = [NSString stringWithFormat:@"Add %@ to LSApplicationQueriesSchemes in Info.plist", YXLURLParser.openURLScheme];
        error = [self errorWithCode:YXLActivationErrorCodeNoQuerySchemeInInfoPList description:description recovery:recovery];
    } else if (NO == [self infoPlistContainsQueriesScheme:YXLURLParser.openURLSchemeUniversalLink]) {
        NSString *description = [NSString stringWithFormat:@"No %@ URL scheme in queries schemes", YXLURLParser.openURLSchemeUniversalLink];
        NSString *recovery = [NSString stringWithFormat:@"Add %@ to LSApplicationQueriesSchemes in Info.plist", YXLURLParser.openURLSchemeUniversalLink];
        error = [self errorWithCode:YXLActivationErrorCodeNoQuerySchemeInInfoPList description:description recovery:recovery];
    } else if (NO == [self infoPlistContainsScheme:[YXLURLParser redirectURLSchemeWithAppId:appId]]) {
        NSString *scheme = [YXLURLParser redirectURLSchemeWithAppId:appId];
        NSString *description = [NSString stringWithFormat:@"No %@ URL scheme", scheme];
        NSString *recovery = [NSString stringWithFormat:@"Add %@ to CFBundleURLTypes in Info.plist", scheme];
        error = [self errorWithCode:YXLActivationErrorCodeNoSchemeInInfoPList description:description recovery:recovery];
    }
    return error;
}

+ (BOOL)infoPlistContainsQueriesScheme:(NSString *)scheme
{
    NSDictionary *infoDictionary = NSBundle.mainBundle.infoDictionary;
    return [infoDictionary[@"LSApplicationQueriesSchemes"] containsObject:scheme];
}

+ (BOOL)infoPlistContainsScheme:(NSString *)scheme
{
    NSDictionary *infoDictionary = NSBundle.mainBundle.infoDictionary;
    return [infoDictionary[@"CFBundleURLTypes"] ?: @[] indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [item[@"CFBundleURLSchemes"] containsObject:scheme];
    }] != NSNotFound;
}

+ (NSError *)errorWithCode:(YXLActivationErrorCode)code
               description:(NSString *)description
                  recovery:(NSString *)recovery
{
    NSParameterAssert(description);
    NSParameterAssert(recovery);
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey : description,
                               NSLocalizedRecoverySuggestionErrorKey : recovery
                               };
    return [NSError errorWithDomain:kYXLActivationErrorDomain code:code userInfo:userInfo];
}

@end
