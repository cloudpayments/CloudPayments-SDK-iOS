#import <Foundation/Foundation.h>

@interface YXLPkce : NSObject

@property (nonatomic, copy, readonly) NSString *codeChallenge;
@property (nonatomic, copy, readonly) NSString *codeVerifier;
@property (nonatomic, copy, readonly) NSDictionary *dictionaryRepresentation;

+ (instancetype)modelWithDictionaryRepresentation:(NSDictionary *)dictionary;

@end
