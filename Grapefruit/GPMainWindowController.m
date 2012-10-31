//
//  GPMainWindowController.m
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/28/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "GPMainWindowController.h"
#import "GPResultTableCellView.h"
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

#define MAX_SEARCH_RESULTS         10
#define MINIMUM_WINDOW_HEIGHT      300
#define MINIMUM_TABLE_HEIGHT       140

-(void)applicationWillResignActive:(NSNotification *)notification {
    [self.searchField setStringValue:@""];
    [_searchResults removeAllObjects];
    [self.resultsView reloadData];
}

-(void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:NSApplicationWillResignActiveNotification
                                               object:nil];
    
    self.searchField.delegate = self;
    
    _searchResults = [[NSMutableArray alloc] init];
    
    
    _searchOperationQueue = [[NSOperationQueue alloc] init];
    [_searchOperationQueue setMaxConcurrentOperationCount:1];
    
    [self validateLibrary];
    
    [self.resultsView setDelegate:self];
    [self.resultsView setDataSource:self];
    
    
    //[self.resultsView reloadData];
}

-(void)updateWindowSize {
    CGFloat adjustSize = self.resultsContainerView.contentView.frame.size.height;
    CGRect newFrame = CGRectMake(self.window.frame.origin.x,
                                 self.window.frame.origin.y,
                                 self.window.frame.size.width,
                                 MINIMUM_WINDOW_HEIGHT + MINIMUM_TABLE_HEIGHT*2 + adjustSize);
    [self.window setFrame:NSRectFromCGRect(newFrame) display:YES];

}

- (void)windowDidLoad {
    [self.window setBackgroundColor:[NSColor darkGrayColor]];
    NSTextView *fieldEditor = (NSTextView *)[self.window fieldEditor:YES
                                                     forObject:self.searchField];
    
    fieldEditor.insertionPointColor = [NSColor whiteColor];

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
    [self.resultsView reloadData];
    
    if ([_searchResults count] > 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [self.resultsView selectRowIndexes:indexSet byExtendingSelection:NO];
    }

    //[self updateWindowSize];
}


#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == self.searchField) {
        [self search];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    
    //NSLogDebug(@"%@", NSStringFromSelector(command));
    
    BOOL handle = NO;
    if (command == @selector(cancelOperation:)) {
        [GPAppDelegate toggleState:GPApplicationStateInactive];
        handle = YES;
    }
    else if (command == @selector(insertNewline:)) {
        NSInteger selectedRow = [self.resultsView selectedRow];
        if ([_searchResults count] > selectedRow && selectedRow >= 0) {
            [self validateLibrary];
            if ([_searchResults count] > 0) {
                iTunesTrack *track = [_searchResults objectAtIndex:selectedRow];
                [track playOnce:YES];
            }
        }
        handle = YES;
    }
    else if (command == @selector(moveDown:)) {
        NSInteger selectedRow = [self.resultsView selectedRow];
        if ([_searchResults count] > selectedRow) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:selectedRow+1];
            [self.resultsView selectRowIndexes:indexSet byExtendingSelection:NO];
        }
        handle = YES;
    }
    else if (command == @selector(moveUp:)) {
        NSInteger selectedRow = [self.resultsView selectedRow];
        if (selectedRow > 0) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:selectedRow-1];
            [self.resultsView selectRowIndexes:indexSet byExtendingSelection:NO];
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

- (IBAction)tableViewSelected:(id)sender {
    NSInteger row = [sender selectedRow];
    if ([_searchResults count] > row) {
        [self validateLibrary];
        iTunesTrack *track = [_searchResults objectAtIndex:row];
        [track playOnce:YES];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    GPResultTableCellView *cellView;
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"MainCell"]) {
        cellView = (GPResultTableCellView *)[tableView makeViewWithIdentifier:identifier owner:self];
        
        NSString *trackName;
        NSString *artistName;
        if ([_searchResults count] > row) {
            iTunesTrack *track = [_searchResults objectAtIndex:row];
            trackName = [track name];
            artistName = [track artist];
            
            
            if ([track.artworks  count] > 0) {
                NSData *data = [[track.artworks objectAtIndex:0] rawData];
                NSImage *image = [[NSImage alloc] initWithData:data];
                if (data != nil)
                    cellView.imageView.objectValue = image;
                [image release];
            }
            
                        
            [cellView setBackgroundStyle:NSBackgroundStyleDark];
            
        }
        else {
            trackName = @"Not a Real Song!";
            artistName = @"Shoumik Palkar";
        }

        cellView.textField.stringValue = trackName;
        cellView.detailTextField.stringValue = artistName;
        
    }
    else {
        NSAssert1(NO, @"Unhandled table column identifier: %@", identifier);
    }
    return cellView;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 60;
}

-(void)dealloc {
    [_searchOperationQueue cancelAllOperations];
    [_searchOperationQueue release];
    [_searchResults removeAllObjects];
    [_searchResults release];
    [super dealloc];
}

@end
