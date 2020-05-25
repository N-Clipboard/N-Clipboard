//
//  Constants.m
//  N Clipboard
//
//  Created by poor branson on 2020/5/1.
//  Copyright © 2020 poor-branson. All rights reserved.
//

#import "Constants.h"

static NSString *BundleName = @"poor-branson.N-Clip-Board";

@implementation _UserDefaults

- (NSString *)ActivationHotKeyDict { return @"ActivationHotKeyDict"; }
- (NSString *)LaunchOnStartUp { return @"LaunchOnStartUp"; }
- (NSString *)KeepClipBoardItemUntil { return @"KeepClipBoardItemUntil"; }
- (NSString *)ShowCleanUpMenuItem { return @"ShowCleanUpMenuItem"; }
- (NSString *)PollingInterval { return @"PollingInterval"; }
- (NSString *)ShowPollingIntervalLabel { return @"ShowPollingIntervalLabel"; }
- (NSString *)ExcludedAppDict { return @"ExcludedAppDict"; }
- (NSString *)ShouldStickOnTop { return @"ShouldStickOnTop"; }

@end

@implementation NThemeConfig

@synthesize complementaryColor = _complementaryColor;
@synthesize name = _name;
@synthesize primaryColor = _primaryColor;
@synthesize background = _background;

- (id)init:(NSString *)name primaryColor:(NSColor *)primaryColor background:(NSArray<NSColor *> *)background complementaryColor:(NSColor *)complementaryColor {
    _name = name;
    _primaryColor = primaryColor;
    _background = background;
    _complementaryColor = complementaryColor;
    
    return self;
}

@end

@implementation Constants
+ (NSString *)MainBundleName {
    return BundleName;
}
+ (NSString *)LauncherBundleName {
    return [NSString stringWithFormat: @"N ClipboardLauncher.%@", BundleName];
}
+ (NSDictionary<NSString *,NSNumber *> *)defaultActivationHotKey {
    return @{@"modifier": @1179648, @"keyCode": @9};
}
+ (NSArray<NSPasteboardType> *)supportedPasteboardType {
    return @[NSPasteboardTypeString, NSPasteboardTypePNG, NSPasteboardTypeColor];
}
+ (NSString *)stringTypeRawValue {
    return NSPasteboardTypeString;
}
+ (_UserDefaults *)Userdefaults { return [[_UserDefaults alloc]init]; }
+ (NSArray<NSSortDescriptor *> *)genSortDescriptor {
    return [self genSortDescriptor:false];
}
+ (NSString *)entityDBName {
    return @"entity.db";
}
+ (NSURL *)externalStorageLocation {
    NSArray<NSURL *> *urls = [[NSFileManager defaultManager]URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    return urls[0];
}
+ (NThemeConfig *)themeGolden {
    NSArray<NSColor*> *background = @[[NSColor colorWithCalibratedRed:0.12890625 green:0.14453125 blue:0.14453125 alpha:1], [NSColor colorWithCalibratedRed:0.12890625 green:0.14453125 blue:0.14453125 alpha:1]];
    NSColor* primaryGolden = [NSColor colorWithCalibratedRed:0.984375 green:0.9765625 blue:0.53515625 alpha:1];
    NSColor* complementaryColor = [NSColor colorWithCalibratedRed:0.26953125 green:0.26953125 blue:0.26953125 alpha:1];
    
    return [[NThemeConfig alloc]init:@"golden" primaryColor:primaryGolden background:background complementaryColor:complementaryColor];
}
+ (NSArray<NSSortDescriptor *> *)genSortDescriptor: (BOOL) descending {
    return @[
        [[NSSortDescriptor alloc]initWithKey:@"createdAt" ascending:true comparator:^NSComparisonResult(id  _Nonnull rawLHS, id  _Nonnull rawRHS) {
            NSDate *lhs = ((NSDate *)rawLHS);
            NSDate *rhs = ((NSDate *)rawRHS);
            if (descending) {
                return [lhs compare:rhs];
            }
            return [rhs compare:lhs];
        }]
    ];
}
@end
