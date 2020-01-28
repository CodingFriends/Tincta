//
//  OHGradientView.h
//  OHura
//
//  Created by Mr. Fridge on 10/19/10.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Cocoa/Cocoa.h>


@interface OHGradientView : NSView {
	
	NSColor *startColor;
	NSColor *endColor;
    NSGradient *gradient;
}

@property (nonatomic,strong) NSColor *startColor;
@property (nonatomic,strong) NSColor *endColor;

- (id) initWithStartColor:(NSColor *)startCol endColor:(NSColor *)endCol;
- (id) initWithFrame:(NSRect)frameRect;
@end
