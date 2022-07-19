#import <Foundation/Foundation.h>

@interface YXLAuthParameters : NSObject

@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *state;
@property (nonatomic, copy, readonly) NSString *pkce;
@property (nonatomic, assign, readonly) long long uid;
@property (nonatomic, copy, readonly) NSString *login;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppId:(NSString *)appId
                        state:(NSString *)state
                         pkce:(NSString *)pkce
                          uid:(long long)uid
                        login:(NSString *)login;

@end
