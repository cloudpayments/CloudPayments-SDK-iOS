#import "YXLError.h"

@interface YXLErrorUtils : NSObject

+ (NSError *)errorWithCode:(YXLErrorCode)code;
+ (NSError *)errorWithCode:(YXLErrorCode)code reason:(NSString *)reason;
+ (NSError *)errorFromNetworkError:(NSError *)error;

@end
