#import "YXLHostProvider.h"
#import "YXLSdk+Protected.h"

static NSString *const kYXLDefaultLanguage = @"en";

@implementation YXLHostProvider

+ (NSString *)oauthHost
{
    return self.oauthHosts[self.currentLanguage] ?: self.oauthHosts[[self follbackLanguageForLanguage:self.currentLanguage]];
}

+ (NSString *)universalLinksHost
{
    return self.universalLinksHosts[self.currentLanguage] ?: self.universalLinksHosts[[self follbackLanguageForLanguage:self.currentLanguage]];
}

+ (NSDictionary<NSString *, NSString *> *)oauthHosts
{
    if (YXLSdk.shared.shouldUseTestEnvironment) {
        return @{@"ru": @"oauth-test.yandex.ru",
                 @"en": @"oauth-test.yandex.ru",
                 @"tr": @"oauth-test.yandex.ru"};
    } else {
        return @{@"ru": @"oauth.yandex.ru",
                 @"en": @"oauth.yandex.ru",
                 @"tr": @"oauth.yandex.ru"};
    }
}

+ (NSDictionary<NSString *, NSString *> *)universalLinksHosts
{
    if (YXLSdk.shared.shouldUseTestEnvironment) {
        return @{@"ru": @"passport-rc.yandex.ru",
                 @"en": @"passport-rc.yandex.ru",
                 @"tr": @"passport-rc.yandex.ru"};
    } else {
        return @{@"ru": @"passport.yandex.ru",
                 @"en": @"passport.yandex.ru",
                 @"tr": @"passport.yandex.ru"};
    }
}

+ (NSString *)follbackLanguageForLanguage:(NSString *)language
{
    NSParameterAssert(language);
    NSString *ruLanguage = @"ru";
    NSArray<NSString *> *ruLanguages = @[@"az", @"be", @"et", @"hy", @"ka", @"kk", @"ky",
                                         @"lt", @"lv", @"ru", @"tg", @"tk", @"uz", @"uk"];
    return [ruLanguages containsObject:language] ? ruLanguage : kYXLDefaultLanguage;
}

+ (NSString *)currentLanguage
{
    NSString *language = NSLocale.preferredLanguages.firstObject;
    NSString *countryCode = [NSLocale.currentLocale objectForKey:NSLocaleCountryCode];
    if (language != nil && countryCode != nil) {
        NSString *suffix = [@"-" stringByAppendingString:countryCode];
        if ([language hasSuffix:suffix]) {
            language = [language substringToIndex:language.length - suffix.length];
        }
    }
    return (language.length > 0) ? language : kYXLDefaultLanguage;
}

@end
