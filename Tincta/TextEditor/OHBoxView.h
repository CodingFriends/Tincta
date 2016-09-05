//
//  OHBoxView.h
//  OHura
//
//  Created by Mr. Fridge on 10/19/10.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <Cocoa/Cocoa.h>


@interface OHBoxView : NSView {

	NSColor *backgroundColorStart;
	NSColor *backgroundColorEnd;
	
	NSColor *borderColor;
	NSColor *midBorderColor;
	NSColor *innerBorderColor;
	
	BOOL hasTopEdge;
	BOOL hasBottomEdge;
	BOOL hasLeftEdge;
	BOOL hasRightEdge;
	
}
- (NSRect) updateDrawRect: (NSRect) rect;

@property (assign) BOOL hasTopEdge;
@property (assign) BOOL hasBottomEdge;
@property (assign) BOOL hasLeftEdge;
@property (assign) BOOL hasRightEdge;


@property (nonatomic,strong) NSColor *backgroundColorStart;
@property (nonatomic,strong) NSColor *backgroundColorEnd;

@property (nonatomic,strong) NSColor *borderColor;
@property (nonatomic,strong) NSColor *innerBorderColor;
@property (nonatomic,strong) NSColor *midBorderColor;



@end
