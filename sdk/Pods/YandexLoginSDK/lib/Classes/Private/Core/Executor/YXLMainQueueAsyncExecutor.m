#import "YXLMainQueueAsyncExecutor.h"

@implementation YXLMainQueueAsyncExecutor

- (void)execute:(dispatch_block_t)block
{
    if (block != nil) {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
