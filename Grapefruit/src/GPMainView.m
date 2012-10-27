//
//  GPMainView.m
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/26/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "GPMainView.h"

@implementation GPMainView
@synthesize searchField;

-(void)awakeFromNib {
    self.searchField.delegate = self;
}

#pragma mark - NSTextFieldDelegate 

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    
    BOOL handle = NO;
    
    if (command == @selector(cancelOperation:)) {
        [GPAppDelegate toggleState:GPApplicationStateInactive];
        handle = YES;
    }

    return handle;
}


@end
