#import <Foundation/Foundation.h>

@interface YXLAuthParameters : NSObject

@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *state;
@property (nonatomic, copy, readonly) NSString *pkce;
@property (nonatomic, assign, readonly) long long uid;
@property (nonatomic, copy, readonly) NSString *login;
@property (nonatomic, copy, readonly) NSString *phone;
@property (nonatomic, copy, readonly) NSString *firstName;
@property (nonatomic, copy, readonly) NSString *lastName;
@property (nonatomic, assign, readonly) BOOL forceFullscreen;
@property (nonatomic, copy, readonly) NSString *customValues;
@property (nonatomic, copy, readonly) NSString *scopes;
@property (nonatomic, copy, readonly) NSString *optionalScopes;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppId:(NSString *)appId
                        state:(NSString *)state
                         pkce:(NSString *)pkce
                          uid:(long long)uid
                        login:(NSString *)login
                   fullscreen:(BOOL)fullscreen;

- (instancetype)initWithAppId:(NSString *)appId
                        state:(NSString *)state
                         pkce:(NSString *)pkce
                          uid:(long long)uid
                        login:(NSString *)login
                        phone:(NSString *)phone
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                   fullscreen:(BOOL)fullscreen
                 customValues:(NSString *)customValues;

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
               optionalScopes:(NSString *)optionalScopes;

@end
