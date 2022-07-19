#import "YXLInsecureStorage.h"

@interface YXLInsecureStorage ()

@property (nonatomic, copy, readonly) NSString *filePath;

@end

@implementation YXLInsecureStorage

- (instancetype)initWithKey:(NSString *)key
{
    NSParameterAssert(key);
    self = [super init];
    if (self != nil) {
        NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        [self createPathIfNeeded:paths.firstObject];
        _filePath = [paths.firstObject stringByAppendingPathComponent:key];
        NSAssert(_filePath != nil, @"Path should exist");
    }
    return self;
}

- (void)createPathIfNeeded:(NSString *)path
{
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSDictionary *)storedObject
{
    return [NSDictionary dictionaryWithContentsOfFile:self.filePath];
}

- (void)setStoredObject:(NSDictionary *)storedObject
{
    if (storedObject == nil) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    }
    else {
        [storedObject writeToFile:self.filePath atomically:YES];
    }
}

@end
