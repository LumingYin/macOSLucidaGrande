//
//  AppDelegate.h
//  macOSLucidaGrande
//
//  Created by Bright on 9/10/16.
//  Copyright © 2016 Kay. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject <NSApplicationDelegate> {
    __unsafe_unretained NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;


@end

