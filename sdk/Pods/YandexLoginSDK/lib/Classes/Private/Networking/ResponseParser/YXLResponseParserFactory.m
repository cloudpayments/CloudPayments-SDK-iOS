#import "YXLResponseParserFactory.h"
#import "YXLDefinitions.h"
#import "YXLJwtRequestParams.h"
#import "YXLJwtResponseParser.h"
#import "YXLTokenRequestParams.h"
#import "YXLTokenResponseParser.h"

@implementation YXLResponseParserFactory

+ (id<YXLResponseParser>)parserForRequestParams:(id<YXLRequestParams>)requestParams
{
    if ([requestParams isKindOfClass:[YXLJwtRequestParams class]]) {
        return [[YXLJwtResponseParser alloc] init];
    }
    if ([requestParams isKindOfClass:[YXLTokenRequestParams class]]) {
        return [[YXLTokenResponseParser alloc] init];
    }
    return nil;
}

@end
