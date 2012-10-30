//
//  GPMainWindowController.h
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/28/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class iTunesSource, SBElementArray;
@interface GPMainWindowController : NSWindowController <NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    iTunesSource *_library;
    NSOperationQueue *_searchOperationQueue;
    NSMutableArray *_searchResults;

    
    NSTableView *resultsView;
    
}

@property(assign) IBOutlet NSSearchField *searchField;
@property(assign) IBOutlet NSScrollView *resultsContainerView;
@property(assign) IBOutlet NSTableView *resultsView;

-(void)validateLibrary;
-(void)search;


@end
