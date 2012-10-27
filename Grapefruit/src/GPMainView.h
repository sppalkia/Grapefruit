//
//  GPMainView.h
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/26/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"


@interface GPMainView : NSView <NSTextFieldDelegate> {
}

@property(assign) IBOutlet NSSearchField *searchField;

@end
