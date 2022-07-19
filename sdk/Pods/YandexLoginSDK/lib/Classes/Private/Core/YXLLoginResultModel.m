#import "YXLLoginResultModel.h"

static NSString *const kYXLLoginResultModelTokenKey = @"token";
static NSString *const kYXLLoginResultModelJwtKey = @"jwt";

@implementation YXLLoginResultModel

- (instancetype)initWithToken:(NSString *)token jwt:(NSString *)jwt
{
    NSParameterAssert(token);
    NSParameterAssert(jwt);
    self = [super init];
    if (self != nil) {
        _token = [token copy];
        _jwt = [jwt copy];
    }
    return self;
}

+ (instancetype)modelWithDictionaryRepresentation:(NSDictionary *)dictionary
{
    YXLLoginResultModel *model = nil;
    if (dictionary[kYXLLoginResultModelTokenKey] != nil && dictionary[kYXLLoginResultModelJwtKey] != nil) {
        model = [[YXLLoginResultModel alloc] initWithToken:dictionary[kYXLLoginResultModelTokenKey]
                                                       jwt:dictionary[kYXLLoginResultModelJwtKey]];
    }
    return model;
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{ kYXLLoginResultModelTokenKey : self.token, kYXLLoginResultModelJwtKey : self.jwt };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@, jwt: %@>", NSStringFromClass([self class]), self.token, self.jwt];
}

@end
