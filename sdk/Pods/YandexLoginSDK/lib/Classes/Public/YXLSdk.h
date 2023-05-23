#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YXLObserver;

@interface YXLSdk : NSObject

/** Shared instance of YXLSdk. */
@property (class, strong, readonly) YXLSdk *shared;

/** Retrieve the current iOS SDK version. */
@property (class, copy, readonly) NSString *sdkVersion;

/** Forces to show scopes confirmation dialog

 @discussion Scopes dialog always shown when user doesn't confirmed it yet.
 When user already confirmed this dialog before, this screen can be missed.
 Set to YES if you need to show this dialog everytime during authentication dialog.

 */
@property (nonatomic, assign) BOOL forceConfirmationDialog;

/** Forces to use fullscreen dialogs

 @discussion All screens for choosing user and confirming scopes will be fullscreen.
 It works only for Yandex apps and doesn't affect opening LoginSDK dialog in browser.

 */
@property (nonatomic, assign) BOOL forceFullscreenDialogs;

/** Array of non-optional scope to request during authorization

 @discussion if set, only scopes from array will be requested from user
 If not set, default scopes for application will be requested
 Check for available scopes in OAuth documentation
 */
@property (nonatomic, copy, nullable) NSArray <NSString *>*scopes;

/** Array of optional scope to request during authorization

 @discussion if set, optional scopes will be requested from user during authorization
 If not set, default scopes will be requested
 Check for available scopes in OAuth documentation
 */
@property (nonatomic, copy, nullable) NSArray <NSString *>*optionalScopes;


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/** Activates SDK. YXLSdk can be used only after activation.

 @discussion Typically YXLSdk should be activated in applicationDidFinishLaunching method of App delegate.
 
 @param error If an error occurs, contains an NSError with kYXLActivationErrorDomain domain and
 YXLActivationErrorCode code object that describes the problem.
 
 @return YES if activation was successful, error is nil in this case
 */
- (BOOL)activateWithAppId:(NSString *)appId error:(NSError *__autoreleasing *)error;

/**
 Checks passed user activity for access token.

 @param userActivity user activity from external application
 @return YES If parsed successfully
 
 @discussion Should be called from [UIApplication application:continueUserActivity:restorationHandler:]
 @code
     @available(iOS 8.0, *)
     func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
         YXLSdk.shared.processUserActivity(userActivity)
         return true
     }
 */
- (BOOL)processUserActivity:(NSUserActivity *)userActivity NS_AVAILABLE_IOS(8_0);

/** Checks passed url for authentication code.

 @param url The URL as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 @param sourceApplication The sourceApplication as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 @return YES if the url was intended for the YandexLoginSDK, NO if not.

 @discussion Should be called from [UIApplicationDelegate application:openURL:sourceApplication:annotation:] method
 of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction
 with the browser or SafariViewController.
 @code
      func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
           return YXLSdk.shared.handleOpen(url, sourceApplication: sourceApplication)
      }

      @available(iOS 9.0, *)
      func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
           return YXLSdk.shared.handleOpen(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String)
      }
 */
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

/** Returning YES if url is related to YandexLoginSDK.

 @param url The URL as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 @return YES for YandexLoginSDK related urls.
 */
- (BOOL)isUrlRelatedToSdk:(NSURL *)url;

/** Adds an observer.

 @param observer Observer to be notified with YXLObserver specific events.
 @warning YXLSdk doesn't keep strong reference to observers.
 */
- (void)addObserver:(id<YXLObserver>)observer NS_SWIFT_NAME(add(observer:));

/** Removes an observer.

 @param observer Observer which adopts YXLObserver protocol, previosuly added with addObserver: method.
 @warning YXLSdk doesn't keep strong reference to observers.
 */
- (void)removeObserver:(id<YXLObserver>)observer NS_SWIFT_NAME(remove(observer:));

/**
 Starts authorization process to retrieve token. Opens Yandex application or browser for access request.

 @discussion Notifies observers if authorization is finished with success or error.
 If YXLSdk is not activated, notifies observers with error YXLErrorCodeNotActivated.
 Caches success authorization result and uses it in the next calls.
 */
- (void)authorize;

/**
 Starts authorization process to retrieve token. Opens Yandex application or browser for access request.

 @param uid expected uid or zero if there is no specified uid.
 @param login predefined value for login input field.
 @discussion Notifies observers if authorization is finished with success or error.
 If YXLSdk is not activated, notifies observers with error YXLErrorCodeNotActivated.
 Caches success authorization result and uses it in the next calls.
 */
- (void)authorizeWithUid:(long long)uid login:(nullable NSString *)login;


/**
 Starts authorization process to retrieve token. Opens Yandex application or browser for access request.

 @param uid expected uid or zero if there is no specified uid.
 @param login predefined value for login input field.
 @param phone predefined value for phone number input field
 @param firstName predefined value for first name input field in registration screen
 @param lastName predefined value for last name input field in registration screen
 @discussion Notifies observers if authorization is finished with success or error.
 If YXLSdk is not activated, notifies observers with error YXLErrorCodeNotActivated.
 Caches success authorization result and uses it in the next calls.
 */
- (void)authorizeWithUid:(long long)uid login:(nullable NSString *)login phone:(nullable NSString *)phone firstName:(nullable NSString *)firstName lastName:(nullable NSString *)lastName;

/**
 Starts authorization process to retrieve token. Opens Yandex application or browser for access request.

 @param uid expected uid or zero if there is no specified uid.
 @param login predefined value for login input field.
 @param phone predefined value for phone number input field
 @param firstName predefined value for first name input field in registration screen
 @param lastName predefined value for last name input field in registration screen
 @param customValues custom values
 @discussion Notifies observers if authorization is finished with success or error.
 If YXLSdk is not activated, notifies observers with error YXLErrorCodeNotActivated.
 Caches success authorization result and uses it in the next calls.
 */
- (void)authorizeWithUid:(long long)uid login:(nullable NSString *)login phone:(nullable NSString *)phone firstName:(nullable NSString *)firstName lastName:(nullable NSString *)lastName customValues:(nullable NSDictionary<NSString *, NSString *> *)customValues;

/**
 Starts authorization process to retrieve token. Opens Yandex application or browser for access request.

 @param uid expected uid or zero if there is no specified uid.
 @param login predefined value for login input field.
 @param phone predefined value for phone number input field
 @param firstName predefined value for first name input field in registration screen
 @param lastName predefined value for last name input field in registration screen
 @param customValues custom values
 @param parentController UIViewController that will present authorization dialog
 @discussion Notifies observers if authorization is finished with success or error.
 If YXLSdk is not activated, notifies observers with error YXLErrorCodeNotActivated.
 Caches success authorization result and uses it in the next calls.
 */
- (void)authorizeWithUid:(long long)uid
                   login:(nullable NSString *)login
                   phone:(nullable NSString *)phone
               firstName:(nullable NSString *)firstName
                lastName:(nullable NSString *)lastName
            customValues:(nullable NSDictionary<NSString *, NSString *> *)customValues
        parentController:(nullable UIViewController*)parentController;

/** Clears all saved data. */
- (void)logout;

@end

NS_ASSUME_NONNULL_END
