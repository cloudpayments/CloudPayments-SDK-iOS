#import <Foundation/Foundation.h>

@protocol YXLExecuting <NSObject>

- (void)execute:(dispatch_block_t)block;

@end
