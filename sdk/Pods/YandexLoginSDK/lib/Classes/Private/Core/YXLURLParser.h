#import <Foundation/Foundation.h>

@class YXLAuthParameters;

@interface YXLURLParser : NSObject

@property (class, copy, readonly) NSString *openURLScheme;
@property (class, copy, readonly) NSString *openURLSchemeUniversalLink;

+ (NSString *)redirectURLSchemeWithAppId:(NSString *)appId;

+ (NSURL *)authorizationURLWithParameters:(YXLAuthParameters *)parameters;
+ (NSURL *)authorizationUniversalLinkWithParameters:(YXLAuthParameters *)parameters;
+ (NSURL *)modernOpenURLWithParameters:(YXLAuthParameters *)parameters;
+ (NSURL *)openURLWithParameters:(YXLAuthParameters *)parameters;
+ (NSURL *)openURLUniversalLinkWithParameters:(YXLAuthParameters *)parameters;

+ (NSError *)errorFromURL:(NSURL *)url;
+ (NSString *)codeFromURL:(NSURL *)url;
+ (NSString *)stateFromURL:(NSURL *)url;
+ (NSString *)uidFromURL:(NSURL *)url;

+ (NSError *)errorFromUniversalLinkURL:(NSURL *)url;
+ (NSString *)tokenFromUniversalLinkURL:(NSURL *)url;
+ (NSString *)stateFromUniversalLinkURL:(NSURL *)url;

+ (BOOL)isOpenURL:(NSURL *)url appId:(NSString *)appId;

@end
