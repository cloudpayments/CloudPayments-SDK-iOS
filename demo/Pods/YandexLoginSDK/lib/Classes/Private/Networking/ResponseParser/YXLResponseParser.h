#import <Foundation/Foundation.h>

@protocol YXLResponseParser <NSObject>

- (id)parseData:(NSData *)data error:(NSError * __autoreleasing *)error;

@end
