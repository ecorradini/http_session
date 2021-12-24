#import "HttpSessionPlugin.h"
#if __has_include(<http_session/http_session-Swift.h>)
#import <http_session/http_session-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "http_session-Swift.h"
#endif

@implementation HttpSessionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHttpSessionPlugin registerWithRegistrar:registrar];
}
@end
