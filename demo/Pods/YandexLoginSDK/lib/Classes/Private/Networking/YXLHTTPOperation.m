#import "YXLHTTPOperation.h"
#import "YXLExecuting.h"
#import "YXLSessionManager.h"

@interface YXLHTTPOperation () <YXLDataTaskDelegate>

@property (nonatomic, copy, readonly) NSURLRequest *request;
@property (nonatomic, copy, readonly) YXLHTTPOperationChallengeBlock processChallenge;
@property (nonatomic, copy, readonly) YXLHTTPOperationSuccessBlock success;
@property (nonatomic, copy, readonly) YXLHTTPOperationFailureBlock failure;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong, readonly) id<YXLExecuting> executor;

@end

@implementation YXLHTTPOperation

- (instancetype)initWithRequest:(NSURLRequest *)request
                       executor:(id<YXLExecuting>)executor
               processChallenge:(YXLHTTPOperationChallengeBlock)processChallenge
                        success:(YXLHTTPOperationSuccessBlock)success
                        failure:(YXLHTTPOperationFailureBlock)failure
{
    NSParameterAssert(request);
    NSParameterAssert(processChallenge);
    NSParameterAssert(success);
    NSParameterAssert(failure);
    self = [super init];
    if (self != nil) {
        _request = [request copy];
        _processChallenge = [processChallenge copy];
        _success = [success copy];
        _failure = [failure copy];
        _executor = executor;
    }
    return self;
}

- (void)start
{
    [self.executor execute:^{
        NSAssert(self.task == nil, @"Can't start twice");
        self.responseData = [[NSMutableData alloc] init];
        self.task = [YXLSessionManager.shared dataTaskWithRequest:self.request delegate:self];
        [self.task resume];
    }];
}

- (void)cancel
{
    [self.executor execute:^{
        [self.task cancel];
    }];
}

#pragma mark - YXLDataTaskDelegate

- (void)dataTaskDidReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
                  completionHandler:(YXLDataTaskChallengeCompletionBlock)completionHandler
{
    self.processChallenge(challenge, completionHandler);
}

- (void)dataTaskDidReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}

- (void)dataTaskDidReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)dataTaskDidCompleteWithError:(NSError *)error
{
    [self.executor execute:^{
        if (error == nil) {
            self.success(self, self.response, self.responseData);
        }
        else {
            self.failure(self, error);
        }
        self.task = nil;
    }];
}

@end
