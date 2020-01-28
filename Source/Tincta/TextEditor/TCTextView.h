//
//  TCTextView.h
//  Tincta
//
//  Created by Mr. Fridge on 4/30/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Foundation/Foundation.h>


@interface TCTextView : NSTextView {

    NSString *tabString;
    NSInteger tabBlankLength;
    NSInteger pageGuideColumn;
    CGFloat pageGuidePosition;
    NSColor* pageGuideColor;
    NSDictionary* currentLineColor;
    BOOL shallColorCurrentLine;
    BOOL shallIndentNewLine;
    BOOL shallAutocompleteBrackets;
    BOOL shallAutocompleteQuotations;
    float tabWidth;
    
}


- (void)insertTabInRange:(NSDictionary*)theParameters;
- (void)insertBackTabInRange:(NSDictionary*)theParameters;
- (void)alterBeginningOfLinesWithParameters:(NSDictionary*)parameters;

- (void)setStringWithUndo: (NSString*)aString;

- (void)setTabString;
- (void)setBackgroundColor:(NSColor* )color;
- (void)setPageGuideColumn:(NSInteger)col;
- (void)setSelectedTextColor:(NSColor* )color;
- (void)setCurrentLineColor:(NSColor* )color;
- (void)colorCurrentLine;
- (void)toggleColoringCurrentLine:(BOOL)b;
- (void)toggleIndentNewLine:(BOOL)b;
- (void)markRanges:(NSArray* )ranges;
- (void)toggleAutocompleteBrackets:(BOOL)b;
- (void)toggleAutocompleteQuotations:(BOOL)b;
- (void)setTabWidthForCurrentFont;
- (void)setInvisiblesColor:(NSColor* )color;
- (void)removeBackgroundColorAttributesInText;

- (void)commentStringWithParameters:(NSDictionary*)parameters;
- (void)uncommentStringWithParameters:(NSDictionary*)parameters;

@end
