#import "SuperEasyInAppPurchasePlugin.h"
#if __has_include(<super_easy_in_app_purchase/super_easy_in_app_purchase-Swift.h>)
#import <super_easy_in_app_purchase/super_easy_in_app_purchase-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "super_easy_in_app_purchase-Swift.h"
#endif

@implementation SuperEasyInAppPurchasePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSuperEasyInAppPurchasePlugin registerWithRegistrar:registrar];
}
@end
