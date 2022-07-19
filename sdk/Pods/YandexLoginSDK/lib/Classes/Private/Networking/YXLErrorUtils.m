#import "YXLErrorUtils.h"

@implementation YXLErrorUtils

+ (NSError *)errorWithCode:(YXLErrorCode)code
{
    return [self errorWithCode:code reason:nil];
}

+ (NSError *)errorWithCode:(YXLErrorCode)code reason:(NSString *)reason
{
    NSDictionary *userInfo = (reason != nil) ? @{ NSLocalizedFailureReasonErrorKey : reason } : nil;
    return [NSError errorWithDomain:kYXLErrorDomain code:code userInfo:userInfo];
}

+ (NSError *)errorFromNetworkError:(NSError *)error
{
    YXLErrorCode code = YXLErrorCodeRequestNetworkError;
    if ([self isInternetConnectionError:error]) {
        code = YXLErrorCodeRequestConnectionError;
    }
    else if ([self isUnsafeConnectionError:error]) {
        code = YXLErrorCodeRequestSSLError;
    }
    return [self errorWithCode:code reason:[NSString stringWithFormat:@"Network error: %@", error]];
}

+ (BOOL)isInternetConnectionError:(NSError *)error
{
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorRedirectToNonExistentLocation:
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorResourceUnavailable:
            case NSURLErrorHTTPTooManyRedirects:
            case NSURLErrorDNSLookupFailed:
            case NSURLErrorNetworkConnectionLost:
            case NSURLErrorCannotConnectToHost:
            case NSURLErrorCannotFindHost:
            case NSURLErrorUnsupportedURL:
            case NSURLErrorTimedOut:
            case NSURLErrorInternationalRoamingOff:
            case NSURLErrorCallIsActive:
            case NSURLErrorDataNotAllowed:
                return YES;
            default:
                return NO;
        }
    }
    return NO;
}

+ (BOOL)isUnsafeConnectionError:(NSError *)error
{
    BOOL isNSURLErrorDomain = [error.domain isEqualToString:NSURLErrorDomain];
    BOOL isAuthenticationCancelled = (error.code == NSURLErrorUserCancelledAuthentication);
    BOOL isSSLError = (error.code >= NSURLErrorSecureConnectionFailed && error.code <= NSURLErrorCannotLoadFromNetwork);
    return (isNSURLErrorDomain && (isAuthenticationCancelled || isSSLError));
}

@end
