#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YXLLoginResult <NSObject>

/** String token for use in request parameters */
@property (nonatomic, copy, readonly) NSString *token;

/** Signed JSON Web Token */
@property (nonatomic, copy, readonly) NSString *jwt;

@end

NS_ASSUME_NONNULL_END
