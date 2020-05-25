//
//  AppDelegate.m
//  NClipboardLauncher
//
//  Created by poor branson on 2020/5/2.
//  Copyright © 2020 poor-branson. All rights reserved.
//

#import "AppDelegate.h"
#import "../N Clipboard/Constants.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    BOOL isMainBundleRunning = false;
    NSArray<NSRunningApplication *>* runningApps = [[NSWorkspace sharedWorkspace]runningApplications];
    for (NSRunningApplication* app in runningApps) {
        if ([app bundleIdentifier] == Constants.MainBundleName) {
            isMainBundleRunning = true;
            break;
        }
    }
    
    if (!isMainBundleRunning) {
        [[NSDistributedNotificationCenter defaultCenter]addObserver:NSApp selector:@selector(terminate) name:@"killLauncher" object:Constants.MainBundleName];
        
        NSString* path = [[NSBundle mainBundle]bundlePath];
        NSArray<NSString *>* components = [path pathComponents];
        components = [components subarrayWithRange: NSMakeRange(0, [components count] - 3)];
        components = [components arrayByAddingObjectsFromArray:@[@"MacOS", @"N Clipboard"]];
        
        NSString* locationOfMainBundle = [NSString pathWithComponents:components];
        [[NSWorkspace sharedWorkspace]launchApplication:locationOfMainBundle];
    } else {
        [NSApp terminate:self];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
