//
//  GPAppDelegate.m
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/25/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//


#import <CoreServices/CoreServices.h>
#import "GPAppDelegate.h"
#import "iTunes.h"

@implementation GPAppDelegate

OSStatus keystrokeActivated(EventHandlerCallRef nextHandler, EventRef event, void* userData);

#pragma mark - OS


OSStatus keystrokeActivated(EventHandlerCallRef nextHandler, EventRef
                            event, void *userData) {
        
    if (GetEventClass(event) != kEventClassKeyboard) {
        NSLog(@"Not a Key Event");
    }
    
    switch(GetEventKind(event)) {
        case kEventHotKeyPressed: {
            NSRunningApplication *currentApplication = [NSRunningApplication currentApplication];
            if ([currentApplication isActive]) {
                [currentApplication hide];
            }
            [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];

            
        } break;
        default:
            break;
    }
    
    return CallNextEventHandler(nextHandler, event);
}

#pragma - NSApplicationDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self.window setHidesOnDeactivate:YES];
    [self.window becomeKeyWindow];
    [self.window becomeMainWindow];
    
    //Add in a global handler
    EventTypeSpec keyboardEventSpec[1];
    EventHotKeyID hotKeyID;
    
    keyboardEventSpec[0].eventClass = kEventClassKeyboard;
    keyboardEventSpec[0].eventKind = kEventHotKeyPressed;
    
    InstallApplicationEventHandler(&keystrokeActivated, 1, keyboardEventSpec, NULL, NULL);
    
    hotKeyID.signature = 'htk1';
    hotKeyID.id = 1;

    RegisterEventHotKey(0x2e, cmdKey+optionKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
}

-(void)applicationWillResignActive:(NSNotification *)notification {
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    RemoveEventHandler(trackKeyKeyboard);
    RemoveEventHandler(trackKeyTextInput);
}

#pragma Implementation

- (void)dealloc {
    [super dealloc];
}

@end