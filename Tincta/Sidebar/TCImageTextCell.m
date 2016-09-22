//
//  ImageTextCell.m
//  SofaControl
//
//  Created by Martin Kahr on 10.10.06.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//  v1.0

#import "TCImageTextCell.h"
#import "TCSideBarItem.h"

@implementation TCImageTextCell
@synthesize topFont, bottomFont, topColor, bottomColor;
@synthesize selectedTopColor, selectedBottomColor, dirtyTopColor, dirtyBottomColor, iconSize, dirtySelectedTopColor, dirtySelectedBottomColor, useSmallerIcons;



- (id) init {
    self = [super init];
    [self setupColorsAndFonts];
    return self;
}

- (id) initImageCell:(NSImage *)image {
    self = [super initImageCell:image];
    [self setupColorsAndFonts];

    return self;
}

- (id) initTextCell:(NSString *)aString {
    self = [super initTextCell:aString];
    [self setupColorsAndFonts];

    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setupColorsAndFonts];

    return self;
}

- (void) setUseSmallerIcons:(BOOL)doUseSmallerIcons {
    useSmallerIcons = doUseSmallerIcons;
    [self setupColorsAndFonts];
}

- (void) setupColorsAndFonts {
    ////////
    //  FOR TESTING
    //useSmallerIcons = YES;
    ////////

    self.topColor = [NSColor blackColor];
    self.bottomColor = [NSColor blackColor];
    self.selectedBottomColor = [NSColor whiteColor];
    self.selectedTopColor = [NSColor whiteColor];

    CGFloat dirtyAlpha = 0.5;

    self.dirtySelectedBottomColor = [NSColor colorWithDeviceWhite:1 alpha:0.8];
    self.dirtySelectedTopColor = [NSColor colorWithDeviceWhite:1 alpha:0.8];

    self.dirtyTopColor = [NSColor colorWithDeviceWhite:0 alpha:dirtyAlpha];
    self.dirtyBottomColor = [NSColor colorWithDeviceWhite:0 alpha:dirtyAlpha];
    if (useSmallerIcons) {
        self.topFont = [NSFont boldSystemFontOfSize:11];
        self.bottomFont = [NSFont systemFontOfSize:9];
        self.iconSize = 32;
    } else {
        self.topFont = [NSFont boldSystemFontOfSize:13];
        self.bottomFont = [NSFont systemFontOfSize:10];
        self.iconSize = 46;
    }

    [self setControlTint:NSGraphiteControlTint];
}

- copyWithZone:(NSZone *)zone {
    TCImageTextCell * cell = [[TCImageTextCell alloc] init];
    cell.useSmallerIcons = self.useSmallerIcons;
    cell.topColor = self.topColor;
    cell.bottomColor = self.bottomColor;
    cell.topFont = self.topFont;
    cell.bottomFont = self.bottomFont;
    cell.selectedTopColor = self.selectedTopColor;
    cell.selectedBottomColor = self.selectedBottomColor;
    cell.dirtyBottomColor = self.dirtyBottomColor;
    cell.dirtyTopColor = self.dirtyTopColor;
    cell.dirtySelectedBottomColor = self.dirtySelectedBottomColor;
    cell.dirtySelectedTopColor = self.dirtySelectedTopColor;
    [cell setControlTint:NSGraphiteControlTint];

    return cell;
}


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [self setTextColor:[NSColor blackColor]];

    TCSideBarItem* data = [self objectValue];


    NSColor* primaryColor   = self.topColor;
    NSColor* secondaryColor   = self.bottomColor;

    if ([self isHighlighted]) {
        primaryColor = self.selectedTopColor;
        secondaryColor = self.selectedBottomColor;
        if (data.isDirty) {
            primaryColor = self.dirtySelectedTopColor;
            secondaryColor = self.dirtySelectedBottomColor;
        }
    } else {
        if (data.isDirty) {
            primaryColor = self.dirtyTopColor;
            secondaryColor = self.dirtyBottomColor;
        }
    }


    NSDictionary* primaryTextAttributes = @{NSForegroundColorAttributeName: primaryColor, NSFontAttributeName: self.topFont};
    NSDictionary* secondaryTextAttributes = @{NSForegroundColorAttributeName: secondaryColor, NSFontAttributeName: self.bottomFont};

    NSString* topTitle = data.topTitle != nil ? data.topTitle : @"";
    NSString* bottomTitle = data.bottomTitle != nil ? data.bottomTitle : @"";
    NSMutableString* primaryText = [NSMutableString stringWithString:topTitle];
    NSMutableString* secondaryText = [NSMutableString stringWithString:bottomTitle];

    NSRect primaryRect = [primaryText boundingRectWithSize: cellFrame.size options:NSStringDrawingOneShot attributes:primaryTextAttributes];
    NSRect secondaryRect = [secondaryText boundingRectWithSize: cellFrame.size options:NSStringDrawingOneShot attributes:secondaryTextAttributes];


    CGFloat leftOffset = self.iconSize + 10;
    CGFloat textCellWidth = (cellFrame.size.width - leftOffset);
    CGFloat verticalCenter = cellFrame.origin.y + cellFrame.size.height /2;

    if (data.numberOfSearchResults > 0) {
        NSString* number = [NSString stringWithFormat:@"%ld", data.numberOfSearchResults];
        NSDictionary* numberTextAttributes = @{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName: self.topFont};

        NSRect numberRect = [number boundingRectWithSize: cellFrame.size options:NSStringDrawingOneShot attributes:numberTextAttributes];
        numberRect.origin = NSMakePoint(cellFrame.origin.x + cellFrame.size.width - numberRect.size.width - 10, verticalCenter - numberRect.size.height / 2);
        numberRect.size.width += 12;
        numberRect.size.height += 3;

        NSBezierPath* roundRect = [NSBezierPath bezierPathWithRoundedRect:numberRect xRadius:10 yRadius:10];

        NSColor* roundRectColor = [NSColor colorWithDeviceRed:0.46 green:0.52 blue:0.59 alpha:1];
        [roundRectColor set];
        [roundRect fill];

        [number drawAtPoint:NSMakePoint(numberRect.origin.x + 6, numberRect.origin.y + 1) withAttributes:numberTextAttributes];

        //adjust text width so they don't overlap
        textCellWidth -= numberRect.size.width;
    }
    ////////////////////////////

    NSInteger deletePosition = primaryText.length / 2;
    BOOL didTruncate = NO;
    while (primaryRect.size.width > textCellWidth && [primaryText length] > 5) {

        [primaryText deleteCharactersInRange:NSMakeRange(deletePosition, 1)];
        primaryRect = [primaryText boundingRectWithSize: cellFrame.size options:NSStringDrawingOneShot attributes:primaryTextAttributes];
        didTruncate = YES;
        deletePosition = primaryText.length / 2;
    }
    if (didTruncate  && [primaryText length] > 4) {
        [primaryText deleteCharactersInRange:NSMakeRange(deletePosition, 2)];
        [primaryText insertString:@"…" atIndex:deletePosition];
    }


    deletePosition = secondaryText.length / 2;
    didTruncate = NO;
    while (secondaryRect.size.width > textCellWidth && [secondaryText length] > 5) {
        [secondaryText deleteCharactersInRange:NSMakeRange(deletePosition, 1)];
        secondaryRect = [secondaryText boundingRectWithSize: cellFrame.size options:NSStringDrawingOneShot attributes:secondaryTextAttributes];
        didTruncate = YES;
        deletePosition = secondaryText.length / 2;
    }
    if (didTruncate && [secondaryText length] > 4) {
        [secondaryText deleteCharactersInRange:NSMakeRange(deletePosition, 2)];
        [secondaryText insertString:@"…" atIndex:deletePosition];
    }


    CGFloat primaryY = verticalCenter - primaryRect.size.height ;
    CGFloat secondaryY = verticalCenter + 0;

    [primaryText drawAtPoint:NSMakePoint(cellFrame.origin.x + leftOffset, primaryY) withAttributes:primaryTextAttributes];
    [secondaryText drawAtPoint:NSMakePoint(cellFrame.origin.x + leftOffset, secondaryY) withAttributes:secondaryTextAttributes];
    /////////////////////////////


    ////////////////////////////

    [[NSGraphicsContext currentContext] saveGraphicsState];
    CGFloat yOffset = cellFrame.origin.y;
    if ([controlView isFlipped]) {
        NSAffineTransform* xform = [NSAffineTransform transform];
        [xform translateXBy:0.0 yBy: cellFrame.size.height];
        [xform scaleXBy:1.0 yBy:-1.0];
        [xform concat];
        yOffset = 0-cellFrame.origin.y;
    }

    NSImage* icon = data.image;

    NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
    [[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];

    CGFloat opacity = 1.0;
    if (data.isDirty) {
        opacity = 0.5;

        /*
         [icon lockFocus];
         [[[NSColor blackColor] colorWithAlphaComponent: .5] set];
         NSRectFillUsingOperation(NSMakeRect(0,0,[icon size].width, [icon size].height), NSCompositeSourceAtop);
         [icon unlockFocus];
         */

    }

    [icon drawInRect:NSMakeRect(cellFrame.origin.x+2,yOffset, self.iconSize, self.iconSize)
            fromRect:NSMakeRect(0,0,[icon size].width, [icon size].height)
           operation:NSCompositeSourceOver
            fraction:opacity];



    [[NSGraphicsContext currentContext] setImageInterpolation: interpolation];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}



- (id)accessibilityAttributeValue:(NSString *)attribute {

    if ([attribute isEqualToString:NSAccessibilityRoleAttribute]) {
        return @"file"; //any string
    }
    if ([attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
        TCSideBarItem* data = [self objectValue];

        return [NSString stringWithFormat:@"%@ in %@", data.topTitle, [data.bottomTitle lastPathComponent]];
    }
    
    return [super accessibilityAttributeValue:attribute];
}


@end
