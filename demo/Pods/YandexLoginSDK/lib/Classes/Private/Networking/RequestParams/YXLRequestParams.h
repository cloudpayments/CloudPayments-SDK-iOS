#import <Foundation/Foundation.h>

@protocol YXLRequestParams <NSObject>

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *params;

@end
