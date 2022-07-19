#import "YXLResponseParser.h"

@interface YXLTokenResponseParser : NSObject <YXLResponseParser>

- (NSString *)parseData:(NSData *)data error:(NSError * __autoreleasing *)error;

@end
