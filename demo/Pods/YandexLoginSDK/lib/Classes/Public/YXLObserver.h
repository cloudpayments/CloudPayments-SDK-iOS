NS_ASSUME_NONNULL_BEGIN

@protocol YXLLoginResult;

@protocol YXLObserver <NSObject>

/** Called when login was finished successfully.
 @param result Success result with the token. */
- (void)loginDidFinishWithResult:(id<YXLLoginResult>)result;

/** Called when error occurred.
 @param error Contains an NSError with domain kYXLErrorDomain and code YXLErrorCode. */
- (void)loginDidFinishWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
