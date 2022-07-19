#import "YXLHostProvider.h"

static NSString *const kYXLDefaultLanguage = @"en";

@implementation YXLHostProvider

+ (NSString *)oauthHost
{
    return self.oauthHosts[self.currentLanguage] ?: self.oauthHosts[[self follbackLanguageForLanguage:self.currentLanguage]];
}

+ (NSDictionary<NSString *, NSString *> *)oauthHosts
{
    return @{@"ru": @"oauth.yandex.ru",
             @"en": @"oauth.yandex.com",
             @"tr": @"oauth.yandex.com.tr"};
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
