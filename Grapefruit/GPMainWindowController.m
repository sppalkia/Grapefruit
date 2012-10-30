//
//  GPMainWindowController.m
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/28/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "GPMainWindowController.h"
#import "iTunes.h"

@interface GPMainWindowController(Search)
-(void)validateLibrary;
-(void)search;
-(void)searchResultsForString:(NSString *)string;
@end

@implementation GPMainWindowController
@synthesize searchField;
@synthesize resultsView;
@synthesize resultsContainerView;

#define MAX_SEARCH_RESULTS      10
#define MINIMUM_WINDOW_HEIGHT   42
#define MINIMUM_TABLE_HEIGHT    140

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
    
    _searchResults = [[NSMutableArray alloc] initWithCapacity:MAX_SEARCH_RESULTS];
    
    
    _searchOperationQueue = [[NSOperationQueue alloc] init];
    [_searchOperationQueue setMaxConcurrentOperationCount:1];
    
    [self validateLibrary];
    
    [self.resultsView setDelegate:self];
    [self.resultsView setDataSource:self];
    
    
    //[self.resultsView reloadData];
}

-(void)updateWindowSize {
    CGFloat adjustSize = self.resultsContainerView.contentView.documentRect.size.height;
    CGRect newFrame = CGRectMake(self.window.frame.origin.x,
                                 self.window.frame.origin.y,
                                 self.window.frame.size.width,
                                 self.window.frame.size.height + 100);
    [self.window setFrame:NSRectFromCGRect(newFrame) display:YES];

}

- (void)windowDidLoad {
    [self updateWindowSize];
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

-(void)search {
    [self validateLibrary];
    
    [_searchOperationQueue cancelAllOperations];
    NSInvocationOperation *searchOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(searchResultsForString:) object:[self.searchField stringValue]];
    [_searchOperationQueue addOperation:searchOperation];
    
    [searchOperation release];
}

-(void)searchResultsForString:(NSString *)string {
    
    //Header file is wrong here; this function does return a SBElementArray. Cast to surpress warning.
    SBElementArray *results = (SBElementArray *)[[[_library playlists] objectAtIndex:0] searchFor:string only:iTunesESrAAll];
    
    NSUInteger resultCount = [results count];
    resultCount = (resultCount <= MAX_SEARCH_RESULTS) ? resultCount : MAX_SEARCH_RESULTS;
    
    SBElementArray *truncatedResults = (SBElementArray *)[results subarrayWithRange:NSMakeRange(0, resultCount)];
    [self performSelectorOnMainThread:@selector(updateResultsView:) withObject:truncatedResults waitUntilDone:NO];
}

-(void)updateResultsView:(SBElementArray *)results {
    [_searchResults removeAllObjects];
    [_searchResults addObjectsFromArray:results];
    NSLogDebug(@"results: %lu, height: %f", [_searchResults count], self.resultsContainerView.contentView.documentRect.size.height);
    [self.resultsView reloadData];
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
    return [_searchResults count];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation {
    return NO;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTableCellView *cellView;
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"MainCell"]) {
        NSString *trackName;
        if ([_searchResults count] > row) {
            trackName = [[_searchResults objectAtIndex:row] name];
        }
        else {
            trackName = @"Changing too fast!";
        }
        cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = trackName;
        
    }
    else {
        NSAssert1(NO, @"Unhandled table column identifier: %@", identifier);
    }
    return cellView;
}


-(void)dealloc {
    [_searchOperationQueue cancelAllOperations];
    [_searchOperationQueue release];
    [_searchResults removeAllObjects];
    [_searchResults release];
    [super dealloc];
}

@end
