//
//  ImageTextCell.h
//  SofaControl
//
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
// v1.0

#import <Cocoa/Cocoa.h>


@interface TCImageTextCell : NSTextFieldCell {
    NSFont* topFont;
    NSFont* bottomFont;
    NSColor* topColor;
    NSColor* bottomColor;

    NSColor* selectedTopColor;
    NSColor* selectedBottomColor;

    NSColor* dirtyTopColor;
    NSColor* dirtyBottomColor;
    NSColor* dirtySelectedTopColor;
    NSColor* dirtySelectedBottomColor;

    NSDictionary* quickLookOptions;
    CGFloat iconSize;

    BOOL useSmallerIcons;
}

@property (assign, nonatomic) BOOL useSmallerIcons;


@property (assign) CGFloat iconSize;

@property (strong) NSFont* topFont;
@property (strong) NSFont* bottomFont;
@property (strong) NSColor* topColor;
@property (strong) NSColor* bottomColor;
@property (strong) NSColor* selectedTopColor;
@property (strong) NSColor* selectedBottomColor;
@property (strong) NSColor* dirtyTopColor;
@property (strong) NSColor* dirtyBottomColor;
@property (strong) NSColor* dirtySelectedTopColor;
@property (strong) NSColor* dirtySelectedBottomColor;

- (void) setupColorsAndFonts;

@end

