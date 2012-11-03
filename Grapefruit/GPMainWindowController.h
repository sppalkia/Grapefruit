//
//  GPMainWindowController.h
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/28/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GPResultsTableView.h"

@class iTunesSource, SBElementArray;
@interface GPMainWindowController : NSWindowController <NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    iTunesSource *_library;
    NSOperationQueue *_searchOperationQueue;
    NSMutableArray *_searchResults;

    
    GPResultsTableView *resultsView;
    NSUInteger previousSearchID;
}

@property(assign) IBOutlet NSTextField *searchField;
@property(assign) IBOutlet NSScrollView *resultsContainerView;
@property(assign) IBOutlet GPResultsTableView *resultsView;

-(void)validateLibrary;
-(void)search;


@end
