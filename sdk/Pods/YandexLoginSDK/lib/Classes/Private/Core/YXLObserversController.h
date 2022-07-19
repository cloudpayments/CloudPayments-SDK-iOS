#import <Foundation/Foundation.h>

@protocol YXLLoginResult;
@protocol YXLObserver;

@interface YXLObserversController : NSObject

- (void)addObserver:(id<YXLObserver>)observer;
- (void)removeObserver:(id<YXLObserver>)observer;

- (void)notifyLoginDidFinishWithResult:(id<YXLLoginResult>)result;
- (void)notifyLoginDidFinishWithError:(NSError *)error;

@end
