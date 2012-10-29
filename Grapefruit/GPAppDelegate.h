//
//  GPAppDelegate.h
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/25/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

enum {
    kLaunchWindowID,
    kLaunchDefaultID,
};

typedef enum {
    GPApplicationStateActive,
    GPApplicationStateInactive,
    GPApplicationStateToggle,
} GPApplicationState;

@class GPMainWindowController;
@interface GPAppDelegate : NSObject <NSApplicationDelegate> {
    EventHandlerRef trackKeyKeyboard;
    EventHandlerRef trackKeyTextInput;
    EventHotKeyRef hotKeyRef;
    
    GPMainWindowController *_mainWindowController;

}

+(BOOL)toggleState:(GPApplicationState)state;

@end
