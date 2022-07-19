#import <Foundation/Foundation.h>

@interface YXLActivationValidator : NSObject

+ (NSError *)validateActivationWithAppId:(NSString *)appId;

@end
