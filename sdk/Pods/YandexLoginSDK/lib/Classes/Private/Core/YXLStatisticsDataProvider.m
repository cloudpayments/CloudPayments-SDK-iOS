#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import "YXLStatisticsDataProvider.h"

NSString *const kYXLStatisticsParameterIfv = @"ifv";
NSString *const kYXLStatisticsParameterAppID = @"app_id";
NSString *const kYXLStatisticsParameterPlatform = @"app_platform";
NSString *const kYXLStatisticsParameterManufacturer = @"manufacturer";
NSString *const kYXLStatisticsParameterManufacturerValue = @"Apple";
NSString *const kYXLStatisticsParameterModel = @"model";
NSString *const kYALStatisticsParameterAppVersion = @"app_version_name";
NSString *const kYALStatisticsParameterDeviceName = @"device_name";

@implementation YXLStatisticsDataProvider

+ (NSDictionary<NSString *, NSString *> *)statisticsParameters
{
    NSMutableDictionary<NSString *, NSString *> *parameters = [NSMutableDictionary dictionary];
    parameters[kYXLStatisticsParameterIfv] = UIDevice.currentDevice.identifierForVendor.UUIDString;
    parameters[kYXLStatisticsParameterAppID] = [NSBundle mainBundle].bundleIdentifier;
    parameters[kYXLStatisticsParameterPlatform] = UIDevice.currentDevice.model;
    parameters[kYXLStatisticsParameterManufacturer] = kYXLStatisticsParameterManufacturerValue;
    parameters[kYXLStatisticsParameterModel] = self.model;
    parameters[kYALStatisticsParameterAppVersion] = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    parameters[kYALStatisticsParameterDeviceName] = UIDevice.currentDevice.name;
    return [parameters copy];
}

+ (NSString *)model
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end
