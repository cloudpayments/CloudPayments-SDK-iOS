#import "YXLLoginResult.h"

__attribute__((objc_subclassing_restricted))
@interface YXLLoginResultModel : NSObject <YXLLoginResult>

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, copy, readonly) NSString *jwt;
@property (nonatomic, copy, readonly) NSDictionary *dictionaryRepresentation;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithToken:(NSString *)token jwt:(NSString *)jwt;
+ (instancetype)modelWithDictionaryRepresentation:(NSDictionary *)dictionary;

@end
