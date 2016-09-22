//
//  OHBoxView.m
//  OHura
//
//  Created by Mr. Fridge on 10/19/10.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "TCStatusView.h"


@implementation TCStatusView


@synthesize backgroundColorStart, backgroundColorEnd, borderColor, innerBorderColor, midBorderColor;

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
        self.backgroundColorStart = [NSColor colorWithDeviceWhite:0.81 alpha:1];
        self.backgroundColorEnd = [NSColor colorWithDeviceWhite:0.65 alpha:1];
        self.borderColor = [NSColor colorWithDeviceWhite:0.318 alpha:1];
    } else {
        self.backgroundColorStart = [NSColor colorWithDeviceWhite:0.929 alpha:1];
		self.backgroundColorEnd = [NSColor colorWithDeviceWhite:0.847 alpha:1];
        self.borderColor = [NSColor colorWithDeviceWhite:0.318 alpha:1];
    }
}


/*
 Draw the view with gradient
 */
- (void)drawRect:(NSRect)dirtyRect {
	
	NSRect rect = [self bounds];
	[self.borderColor set];
	NSRectFill(rect);
	
    
	rect.size.height -= 1;
	
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:self.backgroundColorStart endingColor:self.backgroundColorEnd];
	[gradient drawInRect:rect angle:270];
	
}

//start in upper left
- (BOOL) isFlipped {
	return NO;
}


@end
