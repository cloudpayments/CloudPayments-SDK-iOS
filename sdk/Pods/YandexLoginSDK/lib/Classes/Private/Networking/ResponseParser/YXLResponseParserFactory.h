#import <Foundation/Foundation.h>

@protocol YXLRequestParams;
@protocol YXLResponseParser;

@interface YXLResponseParserFactory : NSObject

+ (id<YXLResponseParser>)parserForRequestParams:(id<YXLRequestParams>)requestParams;

@end
