#import "YXLTokenResponseParser.h"
#import "YXLErrorUtils.h"

@implementation YXLTokenResponseParser

- (NSString *)parseData:(NSData *)data error:(NSError * __autoreleasing *)error
{
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *value = ([result isKindOfClass:[NSDictionary class]]) ? result[@"access_token"] : nil;
    NSString *token = ([value isKindOfClass:[NSString class]]) ? value : nil;
    if (token == nil) {
        if (error != NULL) {
            *error = [YXLErrorUtils errorWithCode:YXLErrorCodeRequestTokenError];
        }
    }
    return token;
}

@end
