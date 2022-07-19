#import <CommonCrypto/CommonDigest.h>
#import "YXLPkce.h"

static NSString *const kYXLPkceModelKey = @"code";
static NSInteger const kYALPkceLengthMin = 43;
static NSInteger const kYALPkceLengthMax = 128;

@implementation YXLPkce

- (instancetype)init
{
    return [self initWithCodeVerifier:[YXLPkce generatePkce]];
}

- (instancetype)initWithCodeVerifier:(NSString *)codeVerifier
{
    NSParameterAssert(codeVerifier);
    self = [super init];
    if (self != nil) {
        _codeVerifier = [codeVerifier copy];
    }
    return self;
}

+ (instancetype)modelWithDictionaryRepresentation:(NSDictionary *)dictionary
{
    YXLPkce *model = nil;
    if (dictionary[kYXLPkceModelKey] != nil) {
        model = [[YXLPkce alloc] initWithCodeVerifier:dictionary[kYXLPkceModelKey]];
    }
    return model;
}

- (NSString *)codeChallenge
{
    return [self decryptPkce:self.codeVerifier];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{ kYXLPkceModelKey : self.codeVerifier };
}

+ (NSString *)generatePkce
{
    NSString *pkce = @"";
    while (pkce.length < kYALPkceLengthMin) {
        pkce = [pkce stringByAppendingString:[NSProcessInfo processInfo].globallyUniqueString];
    }
    if (pkce.length > kYALPkceLengthMax) {
        pkce = [pkce substringToIndex:kYALPkceLengthMax];
    }
    return pkce;
}

- (NSString *)decryptPkce:(NSString *)pkce
{
    NSData *pkceData = [pkce dataUsingEncoding:NSUTF8StringEncoding];
    return [self base64URLSafeStringFromData:[self sha256:pkceData]];
}

- (NSData *)sha256:(NSData *)data
{
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    NSData *sha256 = nil;
    if (CC_SHA256(data.bytes, (CC_LONG)data.length, hash)) {
        sha256 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
    }
    return sha256;
}

- (NSString *)base64URLSafeStringFromData:(NSData *)data
{
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return base64String;
}

@end
