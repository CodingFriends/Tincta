//
//  OHGradientView.m
//  OHura
//
//  Created by Mr. Fridge on 10/19/10.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import "OHGradientView.h"


@implementation OHGradientView


@synthesize startColor;
@synthesize endColor;

- (id) initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
		self.startColor = [NSColor colorWithDeviceWhite:0.98 alpha:1];
		self.endColor = [NSColor colorWithDeviceWhite:0.9
												alpha:1];
	}
    return self;
	
}
/*
 Initilize the gradient view with colors
 */
- (id) initWithStartColor:(NSColor *)startCol endColor:(NSColor *)endCol {
    self = [super init];
	if (self) {
		self.startColor = startCol;
		self.endColor = endCol;
    }
    return self;
}

/*
 Draw the view with gradient
 */
- (void)drawRect:(NSRect)dirtyRect {
	gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
	[gradient drawInRect:[self bounds] angle:270];
}



@end
