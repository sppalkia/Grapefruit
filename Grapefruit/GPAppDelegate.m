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

OSStatus keyHandler(EventHandlerCallRef nextHandler, EventRef event, void* userData);

#pragma mark - OS

OSStatus keystrokeActivated(EventHandlerCallRef nextHandler, EventRef
                            event, void *userData) {
    
    NSLog(@"Handler Called");
    
    static UInt32 modifiers = 0;
    BOOL correctKeyPressed = NO;
    
    if (GetEventClass(event) != kEventClassKeyboard) {
        NSLog(@"Not a Key Event");
    }
    
    switch(GetEventKind(event)) {
        case kEventRawKeyDown: {
            UInt32 keyCode;
            GetEventParameter(event,
                              kEventParamKeyUnicodes,
                              typeUInt32,
                              NULL,
                              sizeof(UInt32),
                              NULL,
                              &keyCode);
            
            NSLog(@"%x", keyCode);
            NSLog(@"Key Event Recieved");
            correctKeyPressed = (keyCode == 0x64);
        }
        case kEventRawKeyModifiersChanged: {
            
            NSLog(@"Modifier Event Recieved");
            
            UInt32 newModifiers;
            GetEventParameter(event,
                              kEventParamKeyModifiers,
                              typeUInt32,
                              NULL,
                              sizeof(UInt32),
                              NULL,
                              &newModifiers);
            
            UInt32 changed = modifiers ^ newModifiers;
            
            if ((changed & (controlKey | rightControlKey)) != 0) {
                if ((modifiers & (controlKey | rightControlKey)) == 0) {
                    //Handle Control Press Here
                }
            }
            
            modifiers = newModifiers;
            
        } break;
        default:
            break;
    }
    
    if (((modifiers & (controlKey | rightControlKey)) != 0) && correctKeyPressed) {
        [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    }
    
    return CallNextEventHandler(nextHandler, event);
}

#pragma - NSApplicationDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Add in a global handler
    EventTypeSpec globalEventType[2];
    globalEventType[0].eventClass = kEventClassKeyboard;
    globalEventType[0].eventKind = kEventRawKeyDown;
    globalEventType[1].eventClass = kEventClassKeyboard;
    globalEventType[1].eventKind = kEventRawKeyModifiersChanged;
    
    EventHandlerUPP globalHandlerFunction = NewEventHandlerUPP(keystrokeActivated);
    InstallEventHandler(GetEventMonitorTarget(), globalHandlerFunction, 2, globalEventType, NULL, &trackKeyGlobal);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    RemoveEventHandler(trackKeyGlobal);
}

#pragma Implementation

-(void)becomeActive {
    //faites quelque chose
}

- (void)dealloc {
    [super dealloc];
}

@end