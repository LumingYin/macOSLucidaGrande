//
//  MainWindowController.m
//  rClickrmacOS
//
//  Created by Numeric on 10/29/17.
//  Copyright © 2017 cocappathon. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


@end
