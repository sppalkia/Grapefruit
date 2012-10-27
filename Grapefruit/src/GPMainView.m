//
//  GPMainView.m
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/26/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <CoreServices/CoreServices.h>
#import "GPMainView.h"

@interface GPMainView(Obesrvers)
-(void)applicationWillResignActive:(NSNotification *)notification;
@end

@implementation GPMainView
@synthesize searchField;

-(void)applicationWillResignActive:(NSNotification *)notification {
    [self.searchField setStringValue:@""];
}

-(void)awakeFromNib {
    self.searchField.delegate = self;
    
    
    NSSearchFieldCell *cell = [self.searchField cell];
    [cell setSendsSearchStringImmediately:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:NSApplicationWillResignActiveNotification
                                               object:nil];
    

    
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    
    BOOL handle = NO;
    NSLogDebug(@"%@", NSStringFromSelector(command));
    if (command == @selector(cancelOperation:)) {
        [GPAppDelegate toggleState:GPApplicationStateInactive];
        handle = YES;
    }
    else if (command == @selector(insertNewline:)) {
        NSLogDebug(@"textView text: %@", [textView string]);
        iTunesApplication *iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        SBElementArray *iTunesSources = [iTunesApp sources];
        iTunesSource *library;
        for (iTunesSource *thisSource in iTunesSources) {
            if ([thisSource kind] == iTunesESrcLibrary) {
                library = thisSource;
                break;
            }
        }
        
        //Header file is wrong here; this function does return a SBElementArray. Cast to surpress warning.
        SBElementArray *tracksWithOurTitle = (SBElementArray *)[[[library playlists] objectAtIndex:0] searchFor:[textView string] only:iTunesESrAAll];
        
        if ([tracksWithOurTitle count] > 0) {
            iTunesTrack *track = [tracksWithOurTitle objectAtIndex:0];
            NSLogDebug(@"iTunesTrack title: %@", [track sortName]);
            
            [track playOnce:YES];
        }
    }

    return handle;
}


@end
