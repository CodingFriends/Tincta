//
//  TCSearchView.m
//  Tincta
//
//  Created by Mr. Fridge on 5/17/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "TCBackgroundView.h"


@implementation TCBackgroundView

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        // nothing
        
    }
    return self;
    
}

- (void) setBackgroundColor:(NSColor *) bgColor {
    _backgroundColor = bgColor;
    [self setNeedsDisplay:YES];
}

- (NSColor*) backgroundColor {
    return _backgroundColor;
}


- (void)drawRect:(NSRect)dirtyRect {
    // update view in case dark mode has changed
    [super drawRect:dirtyRect];
    NSRect rect = [self bounds];
    [self.backgroundColor setFill];
    NSRectFill(rect);
}

//start in upper left
- (BOOL) isFlipped {
    return NO;
}


@end
