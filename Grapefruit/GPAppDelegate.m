//
//  GPAppDelegate.m
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/25/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//


#import <CoreServices/CoreServices.h>
#import "GPAppDelegate.h"
#import "GPMainWindowController.h"
#import "iTunes.h"

@implementation GPAppDelegate

OSStatus keystrokeActivated(EventHandlerCallRef nextHandler, EventRef event, void* userData);

static id this = nil;

#pragma mark - OS

OSStatus keystrokeActivated(EventHandlerCallRef nextHandler, EventRef
                            event, void *userData) {
        
    if (GetEventClass(event) != kEventClassKeyboard) {
        NSLogDebug(@"Not a Key Event");
    }
    
    switch(GetEventKind(event)) {
        case kEventHotKeyPressed: {
            [GPAppDelegate toggleState:GPApplicationStateToggle];
            
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
    
    
    this = self;
    
    _mainWindowController = [[GPMainWindowController alloc] initWithWindowNibName:@"GPMainWindow"];
    [_mainWindowController.window setHidesOnDeactivate:YES];
    [_mainWindowController.window becomeKeyWindow];
    [_mainWindowController.window becomeMainWindow];
        
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

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    RemoveEventHandler(trackKeyKeyboard);
    RemoveEventHandler(trackKeyTextInput);
}

-(void)applicationWillResignActive:(NSNotification *)notification {
    NSApplication *application = [NSApplication sharedApplication];
    if (![application isHidden]) {
        [application hide:this];
    }
}

#pragma Implementation

+(BOOL)toggleState:(GPApplicationState)state {
    NSApplication *application = [NSApplication sharedApplication];
    
    BOOL active = NO;
    
    switch (state) {
        case GPApplicationStateToggle: {
            if ([application isHidden]) {
                [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
                active = YES; 
            }
            else {
                [[NSApplication sharedApplication] hide:this];
            }
        } break;
        case GPApplicationStateActive: {
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            active = YES;
        } break;
        
        case GPApplicationStateInactive:
        default: {
            [[NSApplication sharedApplication] hide:this];
        } break;
    }
    
    return active;
}

- (void)dealloc {
    [_mainWindowController release];
    [super dealloc];
}

@end