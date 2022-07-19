#import "YXLHTTPClient.h"
#import "YXLDefinitions.h"
#import "YXLErrorUtils.h"
#import "YXLHTTPOperation.h"
#import "YXLMainQueueAsyncExecutor.h"
#import "YXLQueryUtils.h"
#import "YXLRequestParams.h"
#import "YXLResponseParser.h"
#import "YXLResponseParserFactory.h"

@interface YXLHTTPClient ()

@property (nonatomic, strong, readonly) NSMutableArray<YXLHTTPOperation *> *operations;

@end

@implementation YXLHTTPClient

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _operations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)executeRequestWithParameters:(id<YXLRequestParams>)parameters
                             success:(YXLHTTPClientSuccessBlock)success
                             failure:(YXLHTTPClientFailureBlock)failure
{
    NSParameterAssert(parameters);
    NSParameterAssert(success);
    NSParameterAssert(failure);
    NSAssert(NSThread.isMainThread, @"execute should be called from the main thread");

    NSURLRequest *request = [self urlRequestWithParameters:parameters];
    if (request == nil) {
        failure([YXLErrorUtils errorWithCode:YXLErrorCodeRequestError]);
        return;
    }
    YXLHTTPOperationChallengeBlock processChallenge = ^(NSURLAuthenticationChallenge *challenge, YXLDataTaskChallengeCompletionBlock completionHandler) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    };

    WEAKIFY_SELF;
    YXLHTTPOperationSuccessBlock operationSuccess = ^(YXLHTTPOperation *operation, NSURLResponse *response, NSData *data) {
        STRONGIFY_SELF;
        NSAssert(NSThread.isMainThread, @"success should be called from the main thread");
        [self operationWithParameters:parameters didFinishWithResponse:response data:data success:success failure:failure];
        [self.operations removeObject:operation];
    };

    YXLHTTPOperationFailureBlock operationFailure = ^(YXLHTTPOperation *operation, NSError *error) {
        STRONGIFY_SELF;
        NSAssert(NSThread.isMainThread, @"failure should be called from the main thread");
        failure([YXLErrorUtils errorFromNetworkError:error]);
        [self.operations removeObject:operation];
    };

    YXLHTTPOperation *operation = [[YXLHTTPOperation alloc] initWithRequest:request
                                                                   executor:[[YXLMainQueueAsyncExecutor alloc] init]
                                                           processChallenge:processChallenge
                                                                    success:operationSuccess
                                                                    failure:operationFailure];
    [self.operations addObject:operation];
    [operation start];
}

- (void)cancelAllRequests
{
    NSAssert(NSThread.isMainThread, @"cancel should be called from the main thread");
    [self.operations makeObjectsPerformSelector:@selector(cancel)];
    [self.operations removeAllObjects];
}

#pragma mark - Private

- (void)operationWithParameters:(id<YXLRequestParams>)parameters
          didFinishWithResponse:(NSURLResponse *)response
                           data:(NSData *)data
                        success:(YXLHTTPClientSuccessBlock)success
                        failure:(YXLHTTPClientFailureBlock)failure
{
    NSError *error = [self checkResponse:response];
    id parseResult = nil;
    if (error == nil) {
        error = [self checkData:data];
    }
    if (error == nil) {
        parseResult = [self parseData:data parameters:parameters error:&error];
    }
    if (error == nil) {
        success(parseResult);
    }
    else {
        failure(error);
    }
}

- (id)parseData:(NSData *)data parameters:(id<YXLRequestParams>)parameters error:(NSError * __autoreleasing *)error
{
    id<YXLResponseParser> parser = [YXLResponseParserFactory parserForRequestParams:parameters];
    if (parser == nil && error != NULL) {
        *error = [YXLErrorUtils errorWithCode:YXLErrorCodeRequestJwtInternalError];
    }
    return [parser parseData:data error:error];
}

- (NSError *)checkData:(NSData *)data
{
    if (data.length == 0) {
        return [YXLErrorUtils errorWithCode:YXLErrorCodeRequestEmptyDataError];
    }
    return nil;
}

- (NSError *)checkResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]] == NO) {
        return [YXLErrorUtils errorWithCode:YXLErrorCodeRequestResponseError];
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
        return [YXLErrorUtils errorWithCode:YXLErrorCodeRequestResponseError
                                     reason:[NSString stringWithFormat:@"Bad status code %ld", (long)httpResponse.statusCode]];
    }
    return nil;
}

- (NSURLRequest *)urlRequestWithParameters:(id<YXLRequestParams>)requestParameters
{
    if (requestParameters.path == nil) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:requestParameters.path];
    if (url == nil) {
        return nil;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    if (requestParameters.params != nil) {
        NSData *httpBody = [[YXLQueryUtils queryStringFromParameters:requestParameters.params] dataUsingEncoding:NSUTF8StringEncoding];
        if (httpBody == nil) {
            return nil;
        }
        request.HTTPBody = httpBody;
    }
    return [request copy];
}

@end
