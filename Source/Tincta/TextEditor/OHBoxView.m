//
//  OHBoxView.m
//  OHura
//
//  Created by Mr. Fridge on 10/19/10.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "OHBoxView.h"


@implementation OHBoxView


@synthesize backgroundColorStart, backgroundColorEnd, borderColor, innerBorderColor, midBorderColor, hasTopEdge, hasBottomEdge, hasLeftEdge, hasRightEdge;

- (id) initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
		self.hasTopEdge = YES;
		self.hasBottomEdge = YES;
		self.hasLeftEdge = YES;
		self.hasRightEdge = YES;
		self.backgroundColorStart = [NSColor colorWithDeviceWhite:0.9 alpha:1];
		self.backgroundColorEnd = [NSColor colorWithDeviceWhite:0.93 alpha:1];
		
		self.borderColor = [NSColor colorWithDeviceWhite:0.6 alpha:1];
		self.midBorderColor = [NSColor colorWithDeviceWhite:0.7 alpha:1];
		self.innerBorderColor = [NSColor colorWithDeviceWhite:0.85 alpha:1];
		
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

- (NSRect) updateDrawRect: (NSRect) rect {
	if (hasLeftEdge) {
		rect.origin.x += 1;
		rect.size.width  -= 1;
	} 
	if (hasTopEdge) {
		rect.origin.y += 1;
		rect.size.height -= 1;
	}
	if (hasRightEdge) rect.size.width  -= 1;
	if (hasBottomEdge) rect.size.height -= 1;
	return rect;
}

/*
 Draw the view with gradient
 */
- (void)drawRect:(NSRect)dirtyRect {
	
	NSRect rect = [self bounds];
	[self.borderColor set];
	NSRectFill(rect);
	
	rect = [self updateDrawRect: rect];
	[self.midBorderColor set];
	NSRectFill(rect);
	
	rect = [self updateDrawRect: rect];
	[self.innerBorderColor set];
	
	NSRectFill(rect);

	
	rect = [self updateDrawRect: rect];
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:self.backgroundColorStart endingColor:self.backgroundColorEnd];
	[gradient drawInRect:rect angle:270];
	
	
}

//start in upper left
- (BOOL) isFlipped {
	return NO;
}


@end
