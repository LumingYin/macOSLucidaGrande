//
//  AppDelegate.m
//  macOSLucidaGrande
//
//  Created by Bright on 9/10/16.
//  Copyright © 2016 Kay. All rights reserved.
//

#import "AppDelegate.h"
#import "NSWindow+AccessoryView.h"
#import "NSData+MD5.h"


@interface AppDelegate () {
    int versionNumber;
    BOOL latestPatchPresent;
    NSString *sierraPatchPath;
    NSString *elCapitanPatchPath;
    NSString *yosemitePatchPath;
    NSString *hashSum;
    BOOL alreadyCheckedUpdate;
}
@property (weak) IBOutlet NSView *_mainView;
@property (weak) IBOutlet NSTextField *currentFontHeading;
@property (weak) IBOutlet NSTextField *currentFontName;
@property (weak) IBOutlet NSButton *callToActionBtn;
@property (weak) IBOutlet NSTextField *systemFontChangedLabel;
@property (weak) IBOutlet NSTextField *previewParagraph;
@property (weak) IBOutlet NSVisualEffectView *visualEffectView;
@end

@implementation AppDelegate
@synthesize window;

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    sierraPatchPath = @"/Library/Fonts/LGUI_Regular_mod.TTF";
    elCapitanPatchPath = @"/Library/Fonts/LucidaGrande_modsysfontelc.ttc";
    yosemitePatchPath = @"/Library/Fonts/LucidaGrande_modsysfontyos.ttc";
    
    [self.window.contentView setWantsLayer:YES];
    self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    self.window.titlebarAppearsTransparent = YES;
    
    NSData *nsData = [NSData dataWithContentsOfFile:sierraPatchPath];
    hashSum = [nsData MD5];
    
    //  Checks if system version is newer than macOS 10.12. If not, alerts the user about incompatibility and exits.
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSString* minor = [NSString stringWithFormat:@"%ld", (long)version.minorVersion];
    versionNumber = [minor intValue];
    if (versionNumber > 10) {
        [_currentFontHeading setFont:[NSFont systemFontOfSize:33 weight:NSFontWeightBlack]];
    }
    _currentFontHeading.hidden = NO;
    if (versionNumber > 12) {
        // Alerts user about incompatibility
        _currentFontName.stringValue = @"Unavailable";
        _currentFontName.hidden = NO;
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Check for Updates"];
        [alert setMessageText:@"Incompatible with your macOS installation."];
        [alert setInformativeText:@"This version of LucidaGrandeSierra only supports macOS Sierra, OS X El Capitan and OS X Yosemite."];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        // Checks for update
        [self checkForUpdates];
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
    } else {
        [self refreshStatus];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self checkForUpdates];
    alreadyCheckedUpdate = YES;
}


- (void)refreshStatus{
    if (versionNumber == 12){
        latestPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:sierraPatchPath];
        if (latestPatchPresent) {
            _currentFontName.stringValue = @"Lucida Grande";
            _callToActionBtn.title = @"Switch to San Francisco";
        } else {
            _currentFontName.stringValue = @"San Francisco";
            _callToActionBtn.title = @"Switch to Lucida Grande";
        }
        _callToActionBtn.enabled = YES;
    }
    else if (versionNumber == 11){
        latestPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:elCapitanPatchPath];
        if (latestPatchPresent) {
            _currentFontName.stringValue = @"Lucida Grande";
            _callToActionBtn.title = @"Switch to San Francisco";
        } else {
            _currentFontName.stringValue = @"San Francisco";
            _callToActionBtn.title = @"Switch to Lucida Grande";
        }
        _callToActionBtn.enabled = YES;
    }
    else if (versionNumber == 10){
        latestPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:yosemitePatchPath];
        if (latestPatchPresent) {
            _currentFontName.stringValue = @"Lucida Grande";
            _callToActionBtn.title = @"Switch to Helvetica Neue";
        } else {
            _currentFontName.stringValue = @"Helvetica Neue";
            _callToActionBtn.title = @"Switch to Lucida Grande";
        }
        _callToActionBtn.enabled = YES;
    }
    [self cleanOldPatch];
    _currentFontName.hidden = NO;
    _callToActionBtn.hidden = NO;
}

- (void)cleanOldPatch{
    BOOL sierraPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:sierraPatchPath];
    BOOL elCapitanPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:elCapitanPatchPath];
    BOOL yosemitePatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:yosemitePatchPath];
    if (versionNumber == 12){
        if (sierraPatchPresent && ![hashSum isEqual: @"aeb6c59d1c4847f1bea4172fe5f93f14"]) {
            [[NSFileManager defaultManager] removeItemAtPath:sierraPatchPath error:nil];
            NSString *nameOfPatchFile = [NSString stringWithFormat:@"applyDiff_10_%d", versionNumber];
            NSString *diffPath = [[NSBundle mainBundle] pathForResource:nameOfPatchFile ofType:@"patch"];
            // Copies the Lucida Grande font over to the desired installation location
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/bin/bspatch";
            task.arguments = @[@"/System/Library/Fonts/LucidaGrande.ttc", sierraPatchPath, diffPath];
            [task launch];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"A newer version of Lucida Grande has been applied."];
            [alert setInformativeText:@"A newer version of Lucida Grande has been applied to your Mac. Bold system font should also be in Lucida Grande now."];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert runModal];

        }
        if (elCapitanPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:elCapitanPatchPath error:nil];
        }
        if (yosemitePatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:yosemitePatchPath error:nil];
        }
    }
    else if (versionNumber == 11) {
        if (sierraPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:sierraPatchPath error:nil];
        }
        if (yosemitePatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:yosemitePatchPath error:nil];
        }
    }
    else if (versionNumber == 10) {
        if (sierraPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:sierraPatchPath error:nil];
        }
        if (elCapitanPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:elCapitanPatchPath error:nil];
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}


- (IBAction)useFont:(id)sender {
    if (latestPatchPresent) {
        if (versionNumber == 12) {
            // Removes the Lucida Grande font that poses as San Francisco
            [[NSFileManager defaultManager] removeItemAtPath:sierraPatchPath error:nil];
            // Refresh main UI to reflect current system typeface setting
            [self refreshStatus];
            // [_currentFontName setFont:[NSFont fontWithName:@".SFNSText-Medium" size:19]];
            // [_previewParagraph setFont:[NSFont fontWithName:@".SFNSText-Medium" size:13]];
            // [_systemFontChangedLabel setFont:[NSFont fontWithName:@".SFNSText-Medium" size:11]];
            _systemFontChangedLabel.hidden = NO;
            _callToActionBtn.hidden = YES;
            
            // Present an alert informing user to log off their Mac
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"System font set to San Francisco."];
            [alert setInformativeText:@"San Francisco will appear as the UI font in newly-opened applications. For San Francisco to be used system-wide, please restart your Mac."];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert runModal];
        } else if (versionNumber == 11) {
            [[NSFileManager defaultManager] removeItemAtPath:elCapitanPatchPath error:nil];
            // Refresh main UI to reflect current system typeface setting
            [self refreshStatus];
            _systemFontChangedLabel.hidden = NO;
            _callToActionBtn.hidden = YES;
            // Present an alert informing user to log off their Mac
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"System font set to San Francisco."];
            [alert setInformativeText:@"San Francisco will appear as the UI font in newly-opened applications. For San Francisco to be used system-wide, please restart your Mac."];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert runModal];
        } else if (versionNumber == 10) {
            // Removes the Lucida Grande font that poses as Helvetica Neue
            [[NSFileManager defaultManager] removeItemAtPath:yosemitePatchPath error:nil];
            
            // Refresh main UI to reflect current system typeface setting
            [self refreshStatus];
            _systemFontChangedLabel.hidden = NO;
            _callToActionBtn.hidden = YES;
            
            // Present an alert informing user to log off their Mac
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"System font set to Helvetica Neue."];
            [alert setInformativeText:@"Helvetica Neue will appear as the UI font in newly-opened applications. For Helvetica Neue to be used system-wide, please restart your Mac."];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert runModal];
        }
    }
    
    else {
        // Fetches the URL of Lucida Grande font that poses San Francisco
        NSString *nameOfPatchFile = [NSString stringWithFormat:@"applyDiff_10_%d", versionNumber];
        NSString *diffPath = [[NSBundle mainBundle] pathForResource:nameOfPatchFile ofType:@"patch"];
        // Copies the Lucida Grande font over to the desired installation location
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/bspatch";
        if (versionNumber == 12) {
        task.arguments = @[@"/System/Library/Fonts/LucidaGrande.ttc", sierraPatchPath, diffPath];
        } else if (versionNumber == 11) {
        task.arguments = @[@"/System/Library/Fonts/LucidaGrande.ttc", elCapitanPatchPath, diffPath];
        } else if (versionNumber == 10) {
        task.arguments = @[@"/System/Library/Fonts/LucidaGrande.ttc", yosemitePatchPath, diffPath];
        }
        [task launch];
        
        // Refresh main UI to reflect current system typeface setting
        // We do not use [self refreshStatus]; in this case because unless sleep is used, [self refreshStatus]; executes before the bash task completes, meaning the status won't be correctly refreshed
        
        _currentFontName.stringValue = @"Lucida Grande";
        [_currentFontName setFont:[NSFont fontWithName:@".Lucida Grande UI" size:19]];
        [_previewParagraph setFont:[NSFont fontWithName:@".Lucida Grande UI" size:13]];
        [_systemFontChangedLabel setFont:[NSFont fontWithName:@".Lucida Grande UI" size:11]];
        _systemFontChangedLabel.hidden = NO;
        _callToActionBtn.hidden = YES;
        
        // Present an alert informing user to restart their Mac
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"System font is set to Lucida Grande."];
        [alert setInformativeText:@"Lucida Grande will appear as the UI font in newly-opened applications. For Lucida Grande to be used system-wide, please restart your Mac."];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];

    }
}

- (IBAction)checkForUpdates:(id)sender {
    [self checkForUpdates];
}
- (IBAction)menuCheckForUpdates:(id)sender {
    [self checkForUpdates];
}

- (void)checkForUpdates {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURL *URL = [NSURL URLWithString:@"https://hikay.github.io/app/lucidagrande/latestBuild.txt"];
    NSError *error;
    NSString *latestBuildNumberRaw = [[NSString alloc]
                                      initWithContentsOfURL:URL
                                      encoding:NSUTF8StringEncoding
                                      error:&error];
    NSString *latestBuildNumber = [latestBuildNumberRaw stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *currentBuildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if ([latestBuildNumber compare:currentBuildNumber options:NSNumericSearch] == NSOrderedDescending) {        
        if (!alreadyCheckedUpdate) {
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 115, 5)];
        [button setBezelStyle:NSBezelStyleRoundRect];
            
        button.title = @"Update Available";
        [button setAction:@selector(checkForUpdates:)];
            
        [self.window addViewToTitleBar:button atXPosition:self.window.frame.size.width - button.frame.size.width - 10];
        }
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Download Update"];
        [alert setMessageText:@"Update Available"];
        NSString *messageText = [NSString stringWithFormat:@"You are currently running macOSLucidaGrande Version %@, and the latest version is Version %@.", currentBuildNumber, latestBuildNumber];
        [alert setInformativeText:messageText];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://hikay.github.io/app/lucidagrande/index.html"]];
    } else if (alreadyCheckedUpdate) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"No Update Available"];
        NSString *messageText = [NSString stringWithFormat:@"macOSLucidaGrande Version %@ is the latest version.", currentBuildNumber];
        [alert setInformativeText:messageText];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];

    }
}

@end
