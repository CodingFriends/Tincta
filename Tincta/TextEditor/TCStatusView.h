//
//  OHBoxView.h
//  OHura
//
//  Created by Mr. Fridge on 10/19/10.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Cocoa/Cocoa.h>


@interface TCStatusView : NSView {

	NSColor* backgroundColorStart;
	NSColor* backgroundColorEnd;
	
	NSColor* borderColor;
	NSColor* midBorderColor;
	NSColor* innerBorderColor;
	
    BOOL _isActive;
}
- (void)setActive:(BOOL)isActive;

@property (nonatomic, strong)NSColor* backgroundColorStart;
@property (nonatomic, strong)NSColor* backgroundColorEnd;

@property (nonatomic, strong)NSColor* borderColor;
@property (nonatomic, strong)NSColor* innerBorderColor;
@property (nonatomic, strong)NSColor* midBorderColor;

@end
