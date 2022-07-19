#import <Foundation/Foundation.h>

@interface YXLStatisticsDataProvider : NSObject

@property (class, copy, readonly) NSDictionary<NSString *, NSString *> *statisticsParameters;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
