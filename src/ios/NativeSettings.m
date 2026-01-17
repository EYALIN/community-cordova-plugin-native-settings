#import "NativeSettings.h"
#import <UIKit/UIKit.h>

@implementation NativeSettings

- (void)open:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSString* setting = [command.arguments objectAtIndex:0];
    
    if (!setting) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Setting name is required"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSURL* url = [self getSettingsURL:setting];
    if (!url) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid setting"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    NSString* urlString = [url absoluteString];
    NSLog(@"NativeSettings: attempting to open settings URL: %@", urlString);
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            CDVPluginResult* result = nil;
            if (success) {
                // Return the actual URL that was opened for debugging
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:urlString];
            } else {
                NSString* msg = [NSString stringWithFormat:@"Failed to open settings: %@", urlString];
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
            }
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    } else {
        BOOL success = [[UIApplication sharedApplication] openURL:url];
        if (success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:urlString];
        } else {
            NSString* msg = [NSString stringWithFormat:@"Failed to open settings: %@", urlString];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)isAvailable:(CDVInvokedUrlCommand*)command {
    NSString* setting = [command.arguments objectAtIndex:0];
    BOOL isAvailable = NO;
    
    if (setting) {
        NSURL* url = [self getSettingsURL:setting];
        if (url) {
            if (@available(iOS 10.0, *)) {
                isAvailable = [[UIApplication sharedApplication] canOpenURL:url];
            } else {
                isAvailable = YES; // Assume available on older iOS versions
            }
        }
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isAvailable];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSURL*)getSettingsURL:(NSString*)setting {
    // iOS settings mappings (App-Prefs:root=...) - many of these URL schemes are unofficial
    // and may not work on all iOS versions. We fall back to UIApplicationOpenSettingsURLString
    // (app-specific settings) where appropriate.
    // Helper to prefer App-Prefs URLs when the system allows them, otherwise fallback
    // to the official UIApplicationOpenSettingsURLString which opens the app's settings.
    NSURL* (^prefURLIfAvailable)(NSString*) = ^NSURL*(NSString* urlString) {
        // On iOS 13+, try to use the official Settings URLs first
        if (@available(iOS 13.0, *)) {
                // There's no public UIApplication method `settingsURLString:` — construct the URL
                // from the provided App-Prefs string and verify it can be opened when possible.
                NSURL* url = [NSURL URLWithString:urlString];
                if (@available(iOS 10.0, *)) {
                    if (![[UIApplication sharedApplication] canOpenURL:url]) {
                        return nil;
                    }
                }
                return url;
        }
        
        // On older iOS, try App-Prefs scheme
        NSURL* url = [NSURL URLWithString:urlString];
        if (@available(iOS 10.0, *)) {
            // If we can't open App-Prefs URL, return nil to show "not available"
            // instead of falling back to app settings
            if (![[UIApplication sharedApplication] canOpenURL:url]) {
                return nil;
            }
        }
        return url;
    };
    if ([setting isEqualToString:@"about"]) {
        return [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    }
    else if ([setting isEqualToString:@"accessibility"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=ACCESSIBILITY");
    }
    else if ([setting isEqualToString:@"account"]) {
        return prefURLIfAvailable(@"App-Prefs:root=ACCOUNT_SETTINGS");
    }
    else if ([setting isEqualToString:@"airplane_mode"]) {
        return prefURLIfAvailable(@"App-Prefs:root=AIRPLANE_MODE");
    }
    else if ([setting isEqualToString:@"autolock"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=AUTOLOCK");
    }
    else if ([setting isEqualToString:@"battery"]) {
        return prefURLIfAvailable(@"App-Prefs:root=BATTERY_USAGE");
    }
    else if ([setting isEqualToString:@"bluetooth"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Bluetooth");
    }
    else if ([setting isEqualToString:@"browser"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Safari");
    }
    else if ([setting isEqualToString:@"cellular"] || [setting isEqualToString:@"cellular_usage"]) {
        return prefURLIfAvailable(@"App-Prefs:root=MOBILE_DATA_SETTINGS_ID");
    }
    else if ([setting isEqualToString:@"date"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=DATE_AND_TIME");
    }
    else if ([setting isEqualToString:@"facetime"]) {
        return prefURLIfAvailable(@"App-Prefs:root=FACETIME");
    }
    else if ([setting isEqualToString:@"keyboard"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=Keyboard");
    }
    else if ([setting isEqualToString:@"language"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=LANGUAGE_AND_REGION");
    }
    else if ([setting isEqualToString:@"location"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Privacy&path=LOCATION");
    }
    else if ([setting isEqualToString:@"music"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Music");
    }
    else if ([setting isEqualToString:@"network"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=Network");
    }
    else if ([setting isEqualToString:@"notification_id"] || [setting isEqualToString:@"notifications"]) {
        // iOS provides app-specific notification settings via the app settings page
        return [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    }
    else if ([setting isEqualToString:@"phone"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Phone");
    }
    else if ([setting isEqualToString:@"photos"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Photos");
    }
    else if ([setting isEqualToString:@"privacy"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Privacy");
    }
    else if ([setting isEqualToString:@"reset"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=Reset");
    }
    else if ([setting isEqualToString:@"ringtone"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Sounds&path=Ringtone");
    }
    else if ([setting isEqualToString:@"root"]) {
        return prefURLIfAvailable(@"App-Prefs:root");
    }
    else if ([setting isEqualToString:@"safari"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Safari");
    }
    else if ([setting isEqualToString:@"sound"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Sounds");
    }
    else if ([setting isEqualToString:@"software_update"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=SOFTWARE_UPDATE_LINK");
    }
    else if ([setting isEqualToString:@"storage"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=STORAGE");
    }
    else if ([setting isEqualToString:@"vpn"]) {
        return prefURLIfAvailable(@"App-Prefs:root=General&path=VPN");
    }
    else if ([setting isEqualToString:@"wallpaper"]) {
        return prefURLIfAvailable(@"App-Prefs:root=Wallpaper");
    }
    else if ([setting isEqualToString:@"wifi"]) {
        return prefURLIfAvailable(@"App-Prefs:root=WIFI");
    }
    else if ([setting isEqualToString:@"store"]) {
        // App Store cannot be opened to app-specific settings via App-Prefs; open app settings instead
        return [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    }
    // If nothing matches, return nil to indicate not supported
    
    return nil;
}

@end