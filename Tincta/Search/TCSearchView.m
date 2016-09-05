//
//  TCSearchView.m
//  Tincta
//
//  Created by Mr. Fridge on 5/17/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import "TCSearchView.h"


@implementation TCSearchView

- (id) initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
		
		[self setActive:YES];
		
	}
    return self;
	
}

- (void) setBackgroundColorEnd:(NSColor *) bgColorE {
	backgroundColorEnd = bgColorE;
	[self setNeedsDisplay:YES];
}

- (void) setBackgroundColorStart:(NSColor *) bgColorS {
	backgroundColorStart = bgColorS;
	[self setNeedsDisplay:YES];
}

- (void) setActive: (BOOL) isActive {
    if (isActive) {
        backgroundColorStart = [NSColor colorWithDeviceWhite:0.91 alpha:1];
        backgroundColorEnd = [NSColor colorWithDeviceWhite:0.91 alpha:1];
        borderColor = [NSColor colorWithDeviceWhite:0.318 alpha:1];
    } else {
        backgroundColorStart = [NSColor colorWithDeviceWhite:0.91 alpha:1];
		backgroundColorEnd = [NSColor colorWithDeviceWhite:0.91 alpha:1];
        borderColor = [NSColor colorWithDeviceWhite:0.6 alpha:1];
    }
}


/*
 Draw the view with gradient
 */
- (void)drawRect:(NSRect)dirtyRect {
	
	NSRect rect = [self bounds];
	[borderColor set];
	NSRectFill(rect);
	
    
	rect.size.height -= 1;
	rect.origin.y += 1;
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:backgroundColorStart endingColor:backgroundColorEnd];
	[gradient drawInRect:rect angle:270];
	
}

//start in upper left
- (BOOL) isFlipped {
	return NO;
}


@end
