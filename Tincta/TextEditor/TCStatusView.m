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
    _isActive = isActive;
    if (isActive) {
        
        self.backgroundColorStart = [NSColor colorWithDeviceWhite:0.89 alpha:1];
        self.backgroundColorEnd = [NSColor colorWithDeviceWhite:0.82 alpha:1];
        self.borderColor = [NSColor colorWithDeviceWhite:0.8 alpha:1];
            if (@available(macOS 10.14, *)) {
                if (NSAppearance.currentAppearance.name == NSAppearanceNameDarkAqua) {
                    self.backgroundColorStart = [NSColor colorWithDeviceWhite:0.26 alpha:1];
                    self.backgroundColorEnd = [NSColor colorWithDeviceWhite:0.22 alpha:1];
                    self.borderColor = [NSColor colorWithDeviceWhite:0.11 alpha:1];
                }
            }
        
        
    } else {
        self.backgroundColorStart = [NSColor colorWithDeviceWhite:0.96 alpha:1];
		self.backgroundColorEnd = [NSColor colorWithDeviceWhite:0.96 alpha:1];
        self.borderColor = [NSColor colorWithDeviceWhite:0.11 alpha:1];
        
        if (@available(macOS 10.14, *)) {
            if (NSAppearance.currentAppearance.name == NSAppearanceNameDarkAqua) {
                self.backgroundColorStart = [NSColor colorWithDeviceWhite:0.19 alpha:1];
                self.backgroundColorEnd = [NSColor colorWithDeviceWhite:0.19 alpha:1];
                self.borderColor = [NSColor colorWithDeviceWhite:0.07 alpha:1];
            }
        }
    }
}


/*
 Draw the view with gradient
 */
- (void)drawRect:(NSRect)dirtyRect {
    // need to update colors in case dark mode has changed
    [self setActive: _isActive];

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
