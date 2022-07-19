#import "YXLSessionManager.h"

@protocol YXLExecuting;
@class YXLHTTPOperation;

typedef void(^YXLHTTPOperationSuccessBlock)(YXLHTTPOperation *, NSURLResponse *, NSData *);
typedef void(^YXLHTTPOperationFailureBlock)(YXLHTTPOperation *, NSError *);
typedef void(^YXLHTTPOperationChallengeBlock)(NSURLAuthenticationChallenge *, YXLDataTaskChallengeCompletionBlock);

@interface YXLHTTPOperation : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRequest:(NSURLRequest *)request
                       executor:(id<YXLExecuting>)executor
               processChallenge:(YXLHTTPOperationChallengeBlock)processChallenge
                        success:(YXLHTTPOperationSuccessBlock)success
                        failure:(YXLHTTPOperationFailureBlock)failure;

- (void)start;
- (void)cancel;

@end
