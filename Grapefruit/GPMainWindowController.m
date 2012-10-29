//
//  GPMainWindowController.m
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/28/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "GPMainWindowController.h"
#import "iTunes.h"

@implementation GPMainWindowController
@synthesize searchField;
@synthesize resultsView;

-(void)applicationWillResignActive:(NSNotification *)notification {
    [self.searchField setStringValue:@""];
}

-(void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:NSApplicationWillResignActiveNotification
                                               object:nil];
    
    self.searchField.delegate = self;
    if ( [searchField respondsToSelector:@selector(setRecentSearches:)] ) {
        id searchCell = [searchField cell];
        [searchCell setSendsSearchStringImmediately:YES];
        [searchCell setAction:@selector(search)];
    }
    
    _searchOperationQueue = [[NSOperationQueue alloc] init];
    [_searchOperationQueue setMaxConcurrentOperationCount:1];
    
    [self validateLibrary];
    
    [self.resultsView setDelegate:self];
    [self.resultsView setDataSource:self];
    //[self.resultsView reloadData];
}

#pragma mark - Search Logic

-(void)validateLibrary {
    if (![_library respondsToSelector:@selector(playlists)]) {
        
        //really make sure we release library and don't leak here
        if ([_library respondsToSelector:@selector(retainCount)]) {
            while ([_library retainCount] != 1) [_library release];
            [_library release];
        }
        
        _library = nil;
        iTunesApplication *iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        SBElementArray *iTunesSources = [iTunesApp sources];
        for (iTunesSource *thisSource in iTunesSources) {
            if ([thisSource kind] == iTunesESrcLibrary) {
                NSLogDebug(@"library was validated");
                _library = thisSource;
                [_library retain];
                break;
            }
        }
    }
}

-(SBElementArray *)performSearch {
    //Header file is wrong here; this function does return a SBElementArray. Cast to surpress warning.
    return (SBElementArray *)[[[_library playlists] objectAtIndex:0] searchFor:[self.searchField stringValue] only:iTunesESrAAll];
}

-(void)search {
    [self validateLibrary];
    
    [_searchOperationQueue cancelAllOperations];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performSearch) object:nil];
    [_searchOperationQueue addOperation:operation];
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    
    NSLogDebug(@"%@", NSStringFromSelector(command));
    
    BOOL handle = NO;
    if (command == @selector(cancelOperation:)) {
        [GPAppDelegate toggleState:GPApplicationStateInactive];
        handle = YES;
    }
    else if (command == @selector(insertNewline:)) {
        
        [self validateLibrary];
        
        //Header file is wrong here; this function does return a SBElementArray. Cast to surpress warning.
        SBElementArray *tracksWithOurTitle = (SBElementArray *)[[[_library playlists] objectAtIndex:0] searchFor:[textView string] only:iTunesESrAAll];
        
        if ([tracksWithOurTitle count] > 0) {
            iTunesTrack *track = [tracksWithOurTitle objectAtIndex:0];
            [track playOnce:YES];
        }
        handle = YES;
    }
    
    return handle;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return 3;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation {
    return NO;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTableCellView *cellView;
    NSString *identifier = [tableColumn identifier];
    NSLogDebug(@"%@", identifier);
    
    if ([identifier isEqualToString:@"MainCell"]) {
        cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = @"Hello World";
        
    }
    else {
        NSAssert1(NO, @"Unhandled table column identifier: %@", identifier);
    }
    return cellView;
}


-(void)dealloc {
    [_searchOperationQueue cancelAllOperations];
    [_searchOperationQueue release];
    [super dealloc];
}

@end
