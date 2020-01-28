//
//  TCSearchView.h
//  Tincta
//
//  Created by Mr. Fridge on 5/17/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Cocoa/Cocoa.h>


@interface TCBackgroundView : NSView {
    
	NSColor* _backgroundColor;
	
}

- (void) setBackgroundColor:(NSColor *) bgColor;
- (NSColor*) backgroundColor;

@end
