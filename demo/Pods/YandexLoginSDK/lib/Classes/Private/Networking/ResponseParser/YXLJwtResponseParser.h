#import "YXLResponseParser.h"

@interface YXLJwtResponseParser : NSObject <YXLResponseParser>

- (NSString *)parseData:(NSData *)data error:(NSError * __autoreleasing *)error;

@end
