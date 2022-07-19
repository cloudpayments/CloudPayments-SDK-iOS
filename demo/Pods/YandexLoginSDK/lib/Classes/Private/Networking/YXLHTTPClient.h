#import <Foundation/Foundation.h>

@protocol YXLRequestParams;

typedef void(^YXLHTTPClientSuccessBlock)(id);
typedef void(^YXLHTTPClientFailureBlock)(NSError *);

@interface YXLHTTPClient : NSObject

- (void)executeRequestWithParameters:(id<YXLRequestParams>)parameters
                             success:(YXLHTTPClientSuccessBlock)success
                             failure:(YXLHTTPClientFailureBlock)failure;
- (void)cancelAllRequests;

@end
