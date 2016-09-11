//
//  NSWindow+AccessoryView.h
//  macOSLucidaGrande
//
//  Created by Bright on 9/10/16.
//  Copyright © 2016 Kay. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSWindow (NSWindow_AccessoryView)

-(void)addViewToTitleBar:(NSView*)viewToAdd atXPosition:(CGFloat)x;
-(CGFloat)heightOfTitleBar;

@end
