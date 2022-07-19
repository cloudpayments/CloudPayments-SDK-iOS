#import <Foundation/Foundation.h>

typedef void(^YXLDataTaskChallengeCompletionBlock)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential);

@protocol YXLDataTaskDelegate <NSObject>

- (void)dataTaskDidReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
                  completionHandler:(YXLDataTaskChallengeCompletionBlock)completionHandler;
- (void)dataTaskDidReceiveResponse:(NSURLResponse *)response;
- (void)dataTaskDidReceiveData:(NSData *)data;
- (void)dataTaskDidCompleteWithError:(NSError *)error;

@end

@interface YXLSessionManager : NSObject

@property (class, strong, readonly) YXLSessionManager *shared;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<YXLDataTaskDelegate>)delegate;

@end
