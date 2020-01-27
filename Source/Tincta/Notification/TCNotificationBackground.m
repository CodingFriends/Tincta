//
//  FMDetailView.m
//  FridgeMagnet
//
//  Created by Mr. Fridge on 11/12/10.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//	2010-11-23

#import "TCNotificationBackground.h"

@implementation TCNotificationBackground

@synthesize  backgroundColor, borderColor;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.borderColor = [NSColor whiteColor];
		self.backgroundColor = [NSColor colorWithDeviceWhite:0 alpha:0];			
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code here.
		self.borderColor = [NSColor whiteColor];
		self.backgroundColor = [NSColor darkGrayColor];
    }
    return self;
}



- (void)drawRect:(NSRect)dirtyRect {
	// Drawing code here.
	CGFloat lineWidth = 2;
	CGFloat boundX = [self bounds].origin.x + 0.5;
	CGFloat boundY = [self bounds].origin.y + 0.5;
	CGFloat boundW = [self bounds].size.width;
	CGFloat boundH = [self bounds].size.height;
	
	CGFloat radius = 10;
    
    NSRect fillRect = NSMakeRect(boundX + lineWidth, boundY+lineWidth, boundW - lineWidth*2, boundH - lineWidth*2);
	NSBezierPath* fillPath = [NSBezierPath bezierPathWithRoundedRect:fillRect xRadius:radius yRadius:radius];
    
	[backgroundColor set]; 
    [fillPath fill];
    [borderColor set]; 
    [fillPath setLineWidth:lineWidth];
    [fillPath stroke];
}

@end
