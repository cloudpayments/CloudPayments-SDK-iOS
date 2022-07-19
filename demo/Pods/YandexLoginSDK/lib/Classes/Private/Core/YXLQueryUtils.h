#import <Foundation/Foundation.h>

@interface YXLQueryUtils : NSObject

+ (NSString *)queryStringFromParameters:(NSDictionary *)params;
+ (NSDictionary<NSString *, NSString *> *)parametersFromQueryString:(NSString *)queryString;

@end
