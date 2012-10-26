//
//  GPAppDelegate.h
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/25/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface GPAppDelegate : NSObject <NSApplicationDelegate> {
    EventHandlerRef trackKeyGlobal;
}

@property (assign) IBOutlet NSWindow *window;

-(void)becomeActive;

@end
