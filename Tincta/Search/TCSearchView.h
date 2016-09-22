//
//  TCSearchView.h
//  Tincta
//
//  Created by Mr. Fridge on 5/17/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Cocoa/Cocoa.h>


@interface TCSearchView : NSView {
    
	NSColor *backgroundColorStart;
	NSColor *backgroundColorEnd;
	
	NSColor *borderColor;
	NSColor *midBorderColor;
	NSColor *innerBorderColor;
	
}

- (void) setActive: (BOOL) isActive;

@end
