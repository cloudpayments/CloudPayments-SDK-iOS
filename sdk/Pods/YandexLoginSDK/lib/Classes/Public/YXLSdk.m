#import "YXLSdk.h"
#import "YXLActivationValidator.h"
#import "YXLAuthParameters.h"
#import "YXLDefinitions.h"
#import "YXLError.h"
#import "YXLJwtRequestParams.h"
#import "YXLHTTPClient.h"
#import "YXLLoginResultModel.h"
#import "YXLObserversController.h"
#import "YXLPkce.h"
#import "YXLStatesManager.h"
#import "YXLStorage.h"
#import "YXLStorageFactory.h"
#import "YXLTokenRequestParams.h"
#import "YXLURLParser.h"
#import "YXLSdk+Protected.h"
#import <SafariServices/SafariServices.h>
#import "YXLErrorUtils.h"
#ifdef __IPHONE_13_0
#import <AuthenticationServices/AuthenticationServices.h>
#endif

#ifdef __IPHONE_13_0
API_AVAILABLE(ios(13.0))
@interface YXLSdk () <SFSafariViewControllerDelegate, ASWebAuthenticationPresentationContextProviding>
#else
@interface YXLSdk () <SFSafariViewControllerDelegate>
#endif


@property (nonatomic, copy) NSString *appId;
@property (nonatomic, strong, readonly) YXLObserversController *observersController;
@property (nonatomic, strong, readonly) YXLHTTPClient *httpClient;
@property (nonatomic, strong, readonly) id<YXLStorage> loginResultStorage;
@property (nonatomic, strong, readonly) id<YXLStorage> pkceStorage;
@property (nonatomic, strong, readonly) YXLStatesManager *statesManager;
@property (nonatomic, strong) id<YXLLoginResult> loginResult;
@property (nonatomic, assign, readonly, getter=isActivated) BOOL activated;
@property (nonatomic, strong) SFSafariViewController *safariViewController;
@property (nonatomic, strong, readonly) UIViewController *presentationController;
#ifdef __IPHONE_13_0
@property (nonatomic, strong) ASWebAuthenticationSession *webAuthSession;
#endif

@end

@implementation YXLSdk

+ (YXLSdk *)shared
{
    static dispatch_once_t once;
    static YXLSdk *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)sdkVersion
{
    return @"2.1.0";
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _observersController = [[YXLObserversController alloc] init];
        _httpClient = [[YXLHTTPClient alloc] init];
        _loginResultStorage = YXLStorageFactory.loginResultStorage;
        _pkceStorage = YXLStorageFactory.pkceStorage;
        _loginResult = [YXLLoginResultModel modelWithDictionaryRepresentation:self.loginResultStorage.storedObject];
        _statesManager = [[YXLStatesManager alloc] initWithStorage:YXLStorageFactory.statesStorage];
    }
    return self;
}

- (BOOL)activateWithAppId:(NSString *)appId error:(NSError *__autoreleasing *)error
{
    NSError *validationError = [YXLActivationValidator validateActivationWithAppId:appId];
    BOOL result = validationError == nil && NO == self.activated;
    if (result) {
        self.appId = appId;
    }
    else if (error != NULL) {
        *error = validationError;
    }
    return result;
}

- (BOOL)processUserActivity:(NSUserActivity *)userActivity
{
    NSParameterAssert(userActivity);
    return (self.activated &&
            [userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] &&
            [self processUniversalLinkURL:userActivity.webpageURL]);
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    NSParameterAssert(url);
    return self.activated && [self isUrlRelatedToSdk:url] && [self processURL:url];
}

- (BOOL)isUrlRelatedToSdk:(NSURL *)url
{
    return self.appId != nil ? [YXLURLParser isOpenURL:url appId:self.appId] : NO;
}

- (void)addObserver:(id<YXLObserver>)observer
{
    NSParameterAssert(observer);
    [self.observersController addObserver:observer];
}

- (void)removeObserver:(id<YXLObserver>)observer
{
    NSParameterAssert(observer);
    [self.observersController removeObserver:observer];
}

- (BOOL)universalLinksAvailable
{
    return UIDevice.currentDevice.systemVersion.floatValue >= 9.f;
}

- (BOOL)shouldUseTestEnvironment
{
    NSDictionary *infoDictionary = NSBundle.mainBundle.infoDictionary;
    return [infoDictionary[kYXLTestEnvironmentKey] boolValue];
}

- (void)authorize
{
    [self authorizeWithUid:0 login:nil];
}

- (void)authorizeWithUid:(long long)uid login:(NSString *)login
{
    [self authorizeWithUid:uid login:login phone:nil firstName:nil lastName:nil];
}

- (void)authorizeWithUid:(long long)uid login:(nullable NSString *)login phone:(nullable NSString *)phone firstName:(nullable NSString *)firstName lastName:(nullable NSString *)lastName
{
    [self authorizeWithUid:uid login:login phone:phone firstName:firstName lastName:lastName customValues:nil];
}

- (void)authorizeWithUid:(long long)uid login:(nullable NSString *)login phone:(nullable NSString *)phone firstName:(nullable NSString *)firstName lastName:(nullable NSString *)lastName customValues:(nullable NSDictionary<NSString *, NSString *> *)customValues
{
    [self authorizeWithUid:uid login:login phone:phone firstName:firstName lastName:lastName customValues:customValues parentController:nil];
}

- (void)authorizeWithUid:(long long)uid
                   login:(nullable NSString *)login
                   phone:(nullable NSString *)phone
               firstName:(nullable NSString *)firstName
                lastName:(nullable NSString *)lastName
            customValues:(nullable NSDictionary<NSString *, NSString *> *)customValues
        parentController:(nullable UIViewController *)parentController
{
    if (NO == self.activated) {
        [self.observersController notifyLoginDidFinishWithError:[self errorWithCode:YXLErrorCodeNotActivated]];
        return;
    }
    if (self.loginResult != nil) {
        [self.observersController notifyLoginDidFinishWithResult:self.loginResult];
        return;
    }
    NSString *state = self.statesManager.generateNewState;
    YXLPkce *pkce = [[YXLPkce alloc] init];
    self.pkceStorage.storedObject = pkce.dictionaryRepresentation;

    NSString *customValuesString = nil;
    if (customValues) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:customValues
                                                           options:0
                                                             error:&error];

        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            customValuesString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
        }
    }

    NSString *scopesString = nil;
    if (self.scopes && self.scopes.count > 0) {
        scopesString = @"";
        for (NSString *scope in self.scopes) {
            scopesString = [scopesString stringByAppendingFormat:@"%@ ", scope];
        }
        scopesString = [scopesString substringToIndex:scopesString.length-1];
    }

    NSString *optionalScopesString = nil;
    if (self.optionalScopes && self.optionalScopes.count > 0) {
        optionalScopesString = @"";
        for (NSString *scope in self.optionalScopes) {
            optionalScopesString = [optionalScopesString stringByAppendingFormat:@"%@ ", scope];
        }
        optionalScopesString = [optionalScopesString substringToIndex:optionalScopesString.length-1];
    }

    YXLAuthParameters *parameters = [[YXLAuthParameters alloc] initWithAppId:self.appId
                                                                       state:state
                                                                        pkce:pkce.codeChallenge
                                                                         uid:uid
                                                                       login:login.length > 0 ? login : nil
                                                                       phone:phone.length > 0 ? phone : nil
                                                                   firstName:firstName.length > 0 ? firstName : nil
                                                                    lastName:lastName.length > 0 ? lastName : nil
                                                                  fullscreen:self.forceFullscreenDialogs
                                                                customValues:customValuesString
                                                                      scopes:scopesString
                                                              optionalScopes:optionalScopesString];

  if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"blockBrowser"] boolValue]) {
    [self tryOpenUrlWithParameters:parameters];
  } else {
    if (parentController != nil) {
        [self tryModernOpenURLWithParameters:parameters parentController:parentController];
    } else {
        [self openBrowserUrlWithParameters:parameters];
    }
  }
}

- (void)tryModernOpenURLWithParameters:(YXLAuthParameters *)parameters parentController:(UIViewController *)parentController
{
    NSURL *openURL = [YXLURLParser modernOpenURLWithParameters:parameters];
    if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
        [self authorizeWithOpenURL:openURL isUniversal:NO completionHandler:^(BOOL success) {
            if (success == NO) {
                NSURL *authURL = [YXLURLParser authorizationURLWithParameters:parameters];
                [self authorizeInSafariViewController:authURL parentController:parentController];
            }
        }];
    } else {
        NSURL *authURL = [YXLURLParser authorizationURLWithParameters:parameters];
        [self authorizeInSafariViewController:authURL parentController:parentController];
    }
}

- (void)tryOpenUrlWithParameters:(YXLAuthParameters *)parameters
{
    if (self.universalLinksAvailable) {
        NSURL *openURL = [YXLURLParser authorizationUniversalLinkWithParameters:parameters];
        [self authorizeWithOpenURL:openURL isUniversal:YES completionHandler:^(BOOL success) {
            if (NO == success) {
                [self tryLegacyOpenUrlFlowWithParameters:parameters];
            }
        }];
        return;
    }
    [self tryLegacyOpenUrlFlowWithParameters:parameters];
}

- (void)tryLegacyOpenUrlFlowWithParameters:(YXLAuthParameters *)parameters {
    NSURL *openURL = [YXLURLParser openURLWithParameters:parameters];
    if ([UIApplication.sharedApplication canOpenURL:openURL]) {
        [self authorizeWithOpenURL:openURL isUniversal:NO completionHandler:^(BOOL success) {
            if (NO == success) {
                [self tryOpenUniversalLinkUrlWithParameters:parameters];
            }
        }];
    }
    else {
        [self tryOpenUniversalLinkUrlWithParameters:parameters];
    }
}

- (void)tryOpenUniversalLinkUrlWithParameters:(YXLAuthParameters *)parameters
{
    NSURL *openURL = [YXLURLParser openURLUniversalLinkWithParameters:parameters];
    if (self.universalLinksAvailable && [UIApplication.sharedApplication canOpenURL:openURL]) {
        [self authorizeWithOpenURL:openURL isUniversal:YES completionHandler:^(BOOL success) {
            if (NO == success) {
                [self openBrowserUrlWithParameters:parameters];
            }
        }];
    }
    else {
        [self openBrowserUrlWithParameters:parameters];
    }
}

- (void)openBrowserUrlWithParameters:(YXLAuthParameters *)parameters
{
    NSURL *url = [YXLURLParser authorizationURLWithParameters:parameters];
    [self authorizeWithOpenURL:url isUniversal:NO completionHandler:nil];
}

- (void)authorizeWithOpenURL:(NSURL *)url isUniversal:(BOOL)isUniversal completionHandler:(void (^)(BOOL success))completion
{
    UIApplication *application = UIApplication.sharedApplication;
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        NSDictionary *options = @{ UIApplicationOpenURLOptionUniversalLinksOnly: @(isUniversal) };
        [application openURL:url options:options completionHandler:completion];
    }
    else {
        if (completion != NULL) {
            completion(NO);
        }
    }
}

- (void)authorizeInSafariViewController:(NSURL *)url parentController:(UIViewController*)parentController
{
#ifdef __IPHONE_13_0
    if (@available(iOS 13_0, *)) {
        _presentationController = parentController;
        _webAuthSession = [[ASWebAuthenticationSession alloc] initWithURL:url
                                                        callbackURLScheme:[YXLURLParser redirectURLSchemeWithAppId:self.appId]
                                                        completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
            if (callbackURL) {
                self.activated && [self isUrlRelatedToSdk:callbackURL] && [self processURL:callbackURL];
            } else {
                if (error != nil) {
                    NSError *sdkError = [YXLErrorUtils errorWithCode:YXLErrorCodeOther reason:error.description];
                    [self.observersController notifyLoginDidFinishWithError:sdkError];
                }
            }
            self -> _presentationController = nil;
            self -> _webAuthSession = nil;
        }];
        self.webAuthSession.presentationContextProvider = self;
        [self.webAuthSession start];
    } else {
#endif
        if (parentController == nil) {
            NSError *error = [YXLErrorUtils errorWithCode:YXLErrorCodeOther reason:@"Passed controller is nil. Use valid UIViewController to present SafariViewController on it"];
            [self.observersController notifyLoginDidFinishWithError:error];
            return;
        }
        _safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        self.safariViewController.delegate = self;
        self.safariViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [parentController presentViewController:self.safariViewController animated:YES completion:nil];
#ifdef __IPHONE_13_0
    }
#endif
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    //  user canceled authorization
    [self.observersController notifyLoginDidFinishWithError:[self errorWithCode:YXLErrorCodeCancelled]];
}

#ifdef __IPHONE_13_0
- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session
  API_AVAILABLE(ios(13.0)) {
    return self.presentationController.view.window;
}
#endif

- (BOOL)isActivated
{
    return self.appId != nil;
}

- (void)logout
{
    self.loginResult = nil;
    self.loginResultStorage.storedObject = nil;
    self.pkceStorage.storedObject = nil;
    [self.statesManager deleteAllStates];
}

- (NSError *)errorWithCode:(YXLErrorCode)code
{
    return [NSError errorWithDomain:kYXLErrorDomain code:code userInfo:nil];
}

- (BOOL)processURL:(NSURL *)URL
{
    BOOL result = NO;
    NSString *code = [YXLURLParser codeFromURL:URL];
    NSString *state = [YXLURLParser stateFromURL:URL];
    NSString *uid = [YXLURLParser uidFromURL:URL];
    BOOL isValidState = (state == nil) ? NO : [self.statesManager isValidState:state];
    if (state != nil) {
        [self.statesManager deleteState:state];
    }
    YXLPkce *pkce = [YXLPkce modelWithDictionaryRepresentation:self.pkceStorage.storedObject];
    if (code != nil && isValidState && pkce != nil) {
        [self requestTokenByCode:code codeVerifier:pkce.codeVerifier];
        result = YES;
        [self notifyMetricsWithUid:uid];
    }
    else {
        NSError *error;
        if (code != nil && NO == isValidState) {
            error = [self errorWithCode:YXLErrorCodeInvalidState];
        }
        else if (pkce == nil) {
            error = [self errorWithCode:YXLErrorCodeInvalidCode];
        }
        else {
            error = [YXLURLParser errorFromURL:URL];
        }
        if (error != nil) {
            [self.observersController notifyLoginDidFinishWithError:error];
            result = YES;
        }
    }
    if (self.safariViewController != nil && result) {
        [self.safariViewController dismissViewControllerAnimated:YES completion:nil];
    }
    return result;
}

- (BOOL)processUniversalLinkURL:(NSURL *)URL
{
    BOOL result = NO;
    NSString *token = [YXLURLParser tokenFromUniversalLinkURL:URL];
    NSString *state = [YXLURLParser stateFromUniversalLinkURL:URL];
    BOOL isValidState = (state == nil) ? NO : [self.statesManager isValidState:state];
    if (state != nil) {
        [self.statesManager deleteState:state];
    }
    if (token != nil && isValidState) {
        [self requestJWTByToken:token];
        result = YES;
    }
    else {
        NSError *error;
        if (token != nil && NO == isValidState) {
            error = [self errorWithCode:YXLErrorCodeInvalidState];
        }
        else {
            error = [YXLURLParser errorFromUniversalLinkURL:URL];
        }
        if (error != nil) {
            [self.observersController notifyLoginDidFinishWithError:error];
            result = YES;
        }
    }
    if (self.safariViewController != nil && result) {
        [self.safariViewController dismissViewControllerAnimated:YES completion:nil];
    }
    return result;
}

- (void)requestJWTByToken:(NSString *)token
{
    NSParameterAssert(token);
    id<YXLRequestParams> requestParams = [[YXLJwtRequestParams alloc] initWithToken:token];
    WEAKIFY_SELF;
    [self.httpClient executeRequestWithParameters:requestParams success:^(NSString *jwt) {
        STRONGIFY_SELF;
        YXLLoginResultModel *result = [[YXLLoginResultModel alloc] initWithToken:token jwt:jwt];
        self.loginResult = result;
        self.loginResultStorage.storedObject = result.dictionaryRepresentation;
        [self.observersController notifyLoginDidFinishWithResult:result];
    } failure:^(NSError *error) {
        STRONGIFY_SELF;
        [self.observersController notifyLoginDidFinishWithError:error];
    }];
}

- (void)requestTokenByCode:(NSString *)code codeVerifier:(NSString *)codeVerifier
{
    NSParameterAssert(code);
    id<YXLRequestParams> requestParams = [[YXLTokenRequestParams alloc] initWithCode:code
                                                                        codeVerifier:codeVerifier
                                                                               appId:self.appId];
    WEAKIFY_SELF;
    [self.httpClient executeRequestWithParameters:requestParams success:^(NSString *token) {
        STRONGIFY_SELF;
        [self requestJWTByToken:token];
    } failure:^(NSError *error) {
        STRONGIFY_SELF;
        [self.observersController notifyLoginDidFinishWithError:error];
    }];
}

- (void)notifyMetricsWithUid:(NSString *)uid
{
    if (uid == nil) {
        return;
    }
    NSDictionary *value = @{ @"login_sdk_context" : uid };
    Class metricaClass = NSClassFromString(@"YMMYandexMetrica");
    if (metricaClass != Nil) {
        SEL sel = NSSelectorFromString(@"reportLoginSDKEvent:");
        if ([metricaClass respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [metricaClass performSelector:sel withObject:value];
#pragma clang diagnostic pop
        }
    }
}

@end
