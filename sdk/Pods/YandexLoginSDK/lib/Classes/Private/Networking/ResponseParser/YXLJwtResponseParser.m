#import "YXLJwtResponseParser.h"
#import "YXLErrorUtils.h"

@implementation YXLJwtResponseParser

- (NSString *)parseData:(NSData *)data error:(NSError * __autoreleasing *)error
{
    NSString *jwt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (jwt == nil) {
        if (error != NULL) {
            *error = [YXLErrorUtils errorWithCode:YXLErrorCodeRequestJwtError];
        }
    }
    return jwt;
}

@end
