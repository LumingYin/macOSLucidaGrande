//
//  AppDelegate.m
//  macOSLucidaGrande
//
//  Created by Bright on 9/10/16.
//  Copyright © 2016 Kay. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+MD5.h"

typedef NS_ENUM(NSUInteger, FontType) {
    FontTypeLucidaGrande,
    FontTypeSF,
};

@interface AppDelegate () {
    int versionNumber;
    BOOL latestPatchPresent;
    NSString *latestKnownMacOSPatchPath;
    NSString *sierraPatchPath;
    NSString *elCapitanPatchPath;
    NSString *yosemitePatchPath;
    NSString *hashSum;
    NSString *knownLatestPatchableLGFontHashSum;
    NSString *knownSystemWideLGFontPath;
    BOOL alreadyCheckedUpdate;
}
@property (weak) IBOutlet NSView *_mainView;
@property (weak) IBOutlet NSButton *callToActionBtn;
@property (weak) IBOutlet NSBox *systemFontChangedLabel;
@property (weak) IBOutlet NSSegmentedControl *fontSelector;
@property (weak) IBOutlet NSImageView *previewImage;
@property (weak) IBOutlet NSTextField *fontChangedTypeLabel;
@end

@implementation AppDelegate
@synthesize window;

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    latestKnownMacOSPatchPath = @"/Library/Fonts/LucidaGrande_modsysfonths.ttc";
    sierraPatchPath = @"/Library/Fonts/LGUI_Regular_mod.TTF";
    elCapitanPatchPath = @"/Library/Fonts/LucidaGrande_modsysfontelc.ttc";
    yosemitePatchPath = @"/Library/Fonts/LucidaGrande_modsysfontyos.ttc";
    knownSystemWideLGFontPath = @"/System/Library/Fonts/LucidaGrande.ttc";
    knownLatestPatchableLGFontHashSum = @"8fd8b90cfab02bae6f905d2cea334962";
    
    [self.window.contentView setWantsLayer:YES];
    self.window.titlebarAppearsTransparent = YES;
    
    NSData *nsData = [NSData dataWithContentsOfFile:sierraPatchPath];
    hashSum = [nsData MD5];
    
    NSString *calculatedLGFontHashSum = [[NSData dataWithContentsOfFile:knownSystemWideLGFontPath] MD5];
    
    //  Checks if system version is newer than macOS 10.14. If not, alerts the user about incompatibility and exits.
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSString* minor = [NSString stringWithFormat:@"%ld", (long)version.minorVersion];
    versionNumber = [minor intValue];
    if (versionNumber == 10) {
        [self.fontSelector setLabel:@"Helvetica Neue" forSegment:0];
    }
    if (versionNumber > 10) {
        [_fontChangedTypeLabel setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightMedium]];
    }
    if (versionNumber > 14 && ![calculatedLGFontHashSum isEqualToString:knownLatestPatchableLGFontHashSum]) {
        // Alerts user about incompatibility
        self.fontSelector.enabled = NO;
        self.callToActionBtn.enabled = NO;
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Check for Updates"];
        [alert setMessageText:@"Incompatible with your macOS installation."];
        [alert setInformativeText:@"This version of LucidaGrandeSierra only supports macOS Mojave, macOS High Sierra, macOS Sierra, OS X El Capitan and OS X Yosemite."];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        // Checks for update
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://github.com/LumingYin/macOSLucidaGrande/releases"]];
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.5];
    } else {
        [self refreshStatus];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self checkForUpdates];
    alreadyCheckedUpdate = YES;
    [self.window addObserver:self forKeyPath:@"effectiveAppearance" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"effectiveAppearance"] && _fontSelector != nil) {
        [self segmentedControlChanged:_fontSelector];
    }
}


- (void)showLGPreview {
    [_fontSelector setSelected:NO forSegment:0];
    [_fontSelector setSelected:YES forSegment:1];
    [self updatePreviewImage:FontTypeLucidaGrande];
}

- (void)showSFPreview {
    [_fontSelector setSelected:NO forSegment:1];
    [_fontSelector setSelected:YES forSegment:0];
    [self updatePreviewImage:FontTypeSF];
}

- (void)updatePreviewImage:(FontType)fontType {
    if (@available(macOS 10.14, *)) {
        NSAppearanceName name = [self.window.effectiveAppearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
        if (name == NSAppearanceNameDarkAqua) {
            if (fontType == FontTypeLucidaGrande) {
                _previewImage.image = [NSImage imageNamed:@"preview_modern_lg_dark"];
            } else if (fontType == FontTypeSF) {
                _previewImage.image = [NSImage imageNamed:@"preview_modern_sf_dark"];
            }
        } else {
            if (fontType == FontTypeLucidaGrande) {
                _previewImage.image = [NSImage imageNamed:@"preview_modern_lg_light"];
            } else if (fontType == FontTypeSF) {
                _previewImage.image = [NSImage imageNamed:@"preview_modern_sf_light"];
            }
        }
    } else {
        if (fontType == FontTypeLucidaGrande) {
            _previewImage.image = [NSImage imageNamed:@"preview_lg"];
        } else if (fontType == FontTypeSF) {
            _previewImage.image = [NSImage imageNamed:@"preview_sf"];
        }
    }
}

- (void)refreshStatus{
    [self cleanOldPatch];
    
    if (versionNumber >= 13) {
        latestPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:latestKnownMacOSPatchPath];
    } else if (versionNumber == 12) {
        latestPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:sierraPatchPath];
    } else if (versionNumber == 11) {
        latestPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:elCapitanPatchPath];
    } else if (versionNumber == 10) {
        latestPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:yosemitePatchPath];
    }
    
    if (latestPatchPresent) {
        [self showLGPreview];
    } else {
        [self showSFPreview];
    }
    _callToActionBtn.enabled = YES;
}

- (IBAction)segmentedControlChanged:(NSSegmentedControl *)sender {
    if (latestPatchPresent && sender.selectedSegment == 0) {
        [self updatePreviewImage:FontTypeSF];
        _callToActionBtn.hidden = NO;
    } else if (latestPatchPresent && sender.selectedSegment == 1) {
        [self updatePreviewImage:FontTypeLucidaGrande];
        _callToActionBtn.hidden = YES;
    } else if (!latestPatchPresent && sender.selectedSegment == 0) {
        [self updatePreviewImage:FontTypeSF];
        _callToActionBtn.hidden = YES;
    } else if (!latestPatchPresent && sender.selectedSegment == 1) {
        [self updatePreviewImage:FontTypeLucidaGrande];
        _callToActionBtn.hidden = NO;
    }
}


- (void)cleanOldPatch{
    BOOL highSierraPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:latestKnownMacOSPatchPath];
    BOOL sierraPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:sierraPatchPath];
    BOOL elCapitanPatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:elCapitanPatchPath];
    BOOL yosemitePatchPresent = [[NSFileManager defaultManager] fileExistsAtPath:yosemitePatchPath];
    if (versionNumber >= 13){
        if (sierraPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:sierraPatchPath error:nil];
        }
        if (elCapitanPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:elCapitanPatchPath error:nil];
        }
        if (yosemitePatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:yosemitePatchPath error:nil];
        }
    } else if (versionNumber == 12){
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
        if (highSierraPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:latestKnownMacOSPatchPath error:nil];
        }
        if (elCapitanPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:elCapitanPatchPath error:nil];
        }
        if (yosemitePatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:yosemitePatchPath error:nil];
        }
    } else if (versionNumber == 11) {
        if (highSierraPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:latestKnownMacOSPatchPath error:nil];
        }
        if (sierraPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:sierraPatchPath error:nil];
        }
        if (yosemitePatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:yosemitePatchPath error:nil];
        }
    } else if (versionNumber == 10) {
        if (highSierraPatchPresent) {
            [[NSFileManager defaultManager] removeItemAtPath:latestKnownMacOSPatchPath error:nil];
        }
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
        NSString *messageText = @"System font set to San Francisco.";
        NSString *informativeText = @"San Francisco will appear as the UI font in newly-opened applications. For San Francisco to be used system-wide, please restart your Mac.";
        
        if (versionNumber >= 13) {
            [[NSFileManager defaultManager] removeItemAtPath:latestKnownMacOSPatchPath error:nil];
        } else if (versionNumber == 12) {
            [[NSFileManager defaultManager] removeItemAtPath:sierraPatchPath error:nil];
        } else if (versionNumber == 11) {
            [[NSFileManager defaultManager] removeItemAtPath:elCapitanPatchPath error:nil];
        } else if (versionNumber == 10) {
            [[NSFileManager defaultManager] removeItemAtPath:yosemitePatchPath error:nil];
            messageText = @"System font set to Helvetica Neue.";
            informativeText = @"Helvetica Neue will appear as the UI font in newly-opened applications. For Helvetica Neue to be used system-wide, please restart your Mac.";
        }
        
        // Refresh main UI to reflect current system typeface setting
        [self refreshStatus];
        _systemFontChangedLabel.hidden = NO;
        _callToActionBtn.hidden = YES;
        _fontSelector.enabled = NO;
        _callToActionBtn.enabled = NO;
        
        // Present an alert informing user to log off their Mac
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:messageText];
        [alert setInformativeText:informativeText];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];

    }
    
    else {
        // Fetches the URL of Lucida Grande font that poses San Francisco
        NSString *nameOfPatchFile;
        if (versionNumber > 13) {
            nameOfPatchFile = @"applyDiff_modern";
        } else {
            nameOfPatchFile = [NSString stringWithFormat:@"applyDiff_10_%d", versionNumber];
        }
        NSString *diffPath = [[NSBundle mainBundle] pathForResource:nameOfPatchFile ofType:@"patch"];
        // Copies the Lucida Grande font over to the desired installation location
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/bspatch";
        if (versionNumber >= 13) {
            task.arguments = @[@"/System/Library/Fonts/LucidaGrande.ttc", latestKnownMacOSPatchPath, diffPath];
        } else if (versionNumber == 12) {
        task.arguments = @[@"/System/Library/Fonts/LucidaGrande.ttc", sierraPatchPath, diffPath];
        } else if (versionNumber == 11) {
        task.arguments = @[@"/System/Library/Fonts/LucidaGrande.ttc", elCapitanPatchPath, diffPath];
        } else if (versionNumber == 10) {
        task.arguments = @[@"/System/Library/Fonts/LucidaGrande.ttc", yosemitePatchPath, diffPath];
        }
        [task launch];
        
        // Refresh main UI to reflect current system typeface setting
        // We do not use [self refreshStatus]; in this case because unless sleep is used, [self refreshStatus]; executes before the bash task completes, meaning the status won't be correctly refreshed

        _systemFontChangedLabel.hidden = NO;
        _callToActionBtn.hidden = YES;
        _fontSelector.enabled = NO;
        _callToActionBtn.enabled = NO;
        
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
    NSURL *URL = [NSURL URLWithString:@"https://raw.githubusercontent.com/LumingYin/macOSLucidaGrande/master/macOSLucidaGrande/latestBuild.txt"];
    NSError *error;
    NSString *latestBuildNumberRaw = [[NSString alloc]
                                      initWithContentsOfURL:URL
                                      encoding:NSUTF8StringEncoding
                                      error:&error];
    NSString *latestBuildNumber = [latestBuildNumberRaw stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *currentBuildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if ([latestBuildNumber compare:currentBuildNumber options:NSNumericSearch] == NSOrderedDescending) {        
        if (!alreadyCheckedUpdate) {
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(360, 328, 115, 20)];
        [button setBezelStyle:NSBezelStyleRoundRect];
            
        button.title = @"Update Available";
        [button setAction:@selector(checkForUpdates:)];
            
        [self._mainView addSubview:button];
        }
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Download Update"];
        [alert setMessageText:@"Update Available"];
        NSString *messageText = [NSString stringWithFormat:@"You are currently running macOSLucidaGrande Version %@, and the latest version is Version %@.", currentBuildNumber, latestBuildNumber];
        [alert setInformativeText:messageText];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://github.com/LumingYin/macOSLucidaGrande/releases"]];
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
