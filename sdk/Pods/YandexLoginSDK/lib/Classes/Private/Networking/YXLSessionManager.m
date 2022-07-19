#import "YXLSessionManager.h"

@interface YXLSessionManager () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, id<YXLDataTaskDelegate>> *taskDelegates;

@end

@implementation YXLSessionManager

+ (YXLSessionManager *)shared
{
    static dispatch_once_t once;
    static YXLSessionManager *sharedManager = nil;

    dispatch_once(&once, ^{
        sharedManager = [[YXLSessionManager alloc] init];
    });

    return sharedManager;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
        _taskDelegates = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<YXLDataTaskDelegate>)delegate
{
    NSParameterAssert(request);
    NSParameterAssert(delegate);

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    [self setDelegate:delegate forTask:dataTask];

    return dataTask;
}

#pragma mark - YXLDataTaskDelegate

- (id<YXLDataTaskDelegate>)delegateForTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);

    @synchronized(self) {
        return self.taskDelegates[@(task.taskIdentifier)];
    }
}

- (void)setDelegate:(id<YXLDataTaskDelegate>)delegate forTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    NSParameterAssert(delegate);

    @synchronized(self) {
        self.taskDelegates[@(task.taskIdentifier)] = delegate;
    }
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);

    @synchronized(self) {
        [self.taskDelegates removeObjectForKey:@(task.taskIdentifier)];
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
        task:(NSURLSessionTask *)task
        didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
        completionHandler:(YXLDataTaskChallengeCompletionBlock)completionHandler
{
    NSAssert([task isKindOfClass:NSURLSessionDataTask.class], @"Should be data task");
    id<YXLDataTaskDelegate> delegate = [self delegateForTask:task];
    if (delegate != nil) {
        [delegate dataTaskDidReceiveChallenge:challenge completionHandler:completionHandler];
    }
    else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    id<YXLDataTaskDelegate> delegate = [self delegateForTask:task];

    if (delegate != nil) {
        [delegate dataTaskDidCompleteWithError:error];
        [self removeDelegateForTask:task];
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
    dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
    completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    id<YXLDataTaskDelegate> delegate = [self delegateForTask:dataTask];
    [delegate dataTaskDidReceiveResponse:response];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    id<YXLDataTaskDelegate> delegate = [self delegateForTask:dataTask];
    [delegate dataTaskDidReceiveData:data];
}

@end
