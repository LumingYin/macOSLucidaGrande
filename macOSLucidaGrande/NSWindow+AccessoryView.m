//
//  NSWindow+AccessoryView.m
//  macOSLucidaGrande
//
//  Created by Bright on 9/10/16.
//  Copyright © 2016 Kay. All rights reserved.
//

#import "NSWindow+AccessoryView.h"

@implementation NSWindow (NSWindow_AccessoryView)

-(void)addViewToTitleBar:(NSView*)viewToAdd atXPosition:(CGFloat)x
{
   viewToAdd.frame = NSMakeRect(x, [[self contentView] frame].size.height, viewToAdd.frame.size.width, [self heightOfTitleBar]);
   
   NSUInteger mask = 0;
   if( x > self.frame.size.width / 2.0 )
   {
      mask |= NSViewMinXMargin;
   }
   else
   {
      mask |= NSViewMaxXMargin;
   }
   [viewToAdd setAutoresizingMask:mask | NSViewMinYMargin];
   
   [[[self contentView] superview] addSubview:viewToAdd];
}

-(CGFloat)heightOfTitleBar
{
   NSRect outerFrame = [[[self contentView] superview] frame];
   NSRect innerFrame = [[self contentView] frame];
   
   return outerFrame.size.height - innerFrame.size.height;
}

@end
