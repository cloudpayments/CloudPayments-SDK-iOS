#import "YXLQueryUtils.h"

@implementation YXLQueryUtils

+ (NSString *)queryStringFromParameters:(NSDictionary *)params
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:params.count];
    for (NSString *key in params) {
        id value = params[key];
        NSString *stringValue = [value isKindOfClass:[NSString class]] ? value : [value description];
        [array addObject:[NSString stringWithFormat:@"%@=%@", [self escapeString:key], [self escapeString:stringValue]]];
    }
    return [array componentsJoinedByString:@"&"];
}

+ (NSDictionary<NSString *, NSString *> *)parametersFromQueryString:(NSString *)queryString
{
    NSArray<NSString *> *keyValuePairs = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    for (NSString *keyValueString in keyValuePairs) {
        NSUInteger equalLocation = [keyValueString rangeOfString:@"="].location;
        if (equalLocation != NSNotFound) {
            NSString *name = [keyValueString substringToIndex:equalLocation].stringByRemovingPercentEncoding;
            NSString *value = [keyValueString substringFromIndex:equalLocation + 1].stringByRemovingPercentEncoding;
            parameters[name] = value;
        }
    }
    return [parameters copy];
}

+ (NSString *)escapeString:(NSString *)value
{
    return [value stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
}

@end
