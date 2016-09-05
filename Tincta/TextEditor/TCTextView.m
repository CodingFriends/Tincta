//
//  TCTextView.m
//  Tincta
//
//  Created by Mr. Fridge on 4/30/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import "TCTextView.h"
#import "TCLayoutManager.h"
#import "ColorConverter.h"
#import "TCTextStorage.h"
#import "TCATextManipulation.h"
#import "TCAMiscHelper.h"

@implementation TCTextView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder* )aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit {
    TCLayoutManager* layoutManager = [[TCLayoutManager alloc] init];
    [[self textContainer] replaceLayoutManager:layoutManager];
    
    //undomanager shall be overwritten by sidebar item
    TCTextStorage* textStorage = [[TCTextStorage alloc] initWithAttributedString:[self attributedString]];
    [[self layoutManager] replaceTextStorage: textStorage];
    
    // Initialization code here.
    [self setTabString];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    tabWidth = 28;
    for (int i = 0; i < 100; i++) {
        NSTextTab *tabStop = [[NSTextTab alloc] initWithType:NSLeftTabStopType
                                                    location: tabWidth * i];
        [style addTabStop:tabStop];
    }
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
    [self setTypingAttributes:attributes];

    [self setBackgroundColor:[TCADefaultsHelper getBackgroundColor]];
    [self setTextColor:[TCADefaultsHelper getTextColor]];
    
    [self setTabWidthForCurrentFont];
}

- (void)setStringWithUndo: (NSString*)aString {
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setStringWithUndo:)object:[NSString stringWithString:[self string]]];
    [self setString:aString];
}


- (void)insertText:(id)insertString {
    
    [super insertText:insertString];
    
    if (shallAutocompleteBrackets && [insertString isKindOfClass:[NSString class]]) {
        if ([insertString isEqualToString:@"("]) {
            [super insertText:@")"];
        } else if ([insertString isEqualToString:@"["]) {
            [super insertText:@"]"];
        } else if ([insertString isEqualToString:@"{"]) {
            [super insertText:@"}"];
        } else {
            return;
        }
        
        // insertion point between the braces
        NSArray* selRanges = @[[NSValue valueWithRange:NSMakeRange([self selectedRange].location - 1, 0)]];
        [self setSelectedRanges:selRanges];
    }
}


- (NSImage *)dragImageForSelectionWithEvent:(NSEvent *)event origin:(NSPointPointer)origin {
    NSDictionary* atts = [[self textStorage] attributesAtIndex:[self selectedRange].location effectiveRange:NULL];
    NSMutableString* draggedString = [NSMutableString stringWithString:@""];
    for (NSValue* value in [self selectedRanges]) {
        NSRange r = [value rangeValue];
        if (![TCAMiscHelper isRange:r inBoundOfString:self.string]) {
            continue;
        }
        [draggedString appendFormat:@"%@%@", [[self string] substringWithRange:r],@"\n"];
    }
    
    NSSize drawingSize = [draggedString sizeWithAttributes: atts];
    NSImage* image = [[NSImage alloc] initWithSize:drawingSize];
    [image lockFocus];
    
    [draggedString drawInRect:NSMakeRect(0, 0, drawingSize.width, drawingSize.height)withAttributes:atts];
    [image unlockFocus];
    
    NSRect firstGlyphRect = [[self layoutManager] boundingRectForGlyphRange:[self selectedRange] inTextContainer:[self textContainer]];
    
    NSPoint theOrigin = firstGlyphRect.origin;
    origin->x = theOrigin.x;
    origin->y = theOrigin.y + drawingSize.height;
    
    return image;
}

- (void)insertNewline:(id)sender {
    NSRange selRange = [self selectedRange];
    NSRange currentLineRange = [[self string]lineRangeForRange:selRange];
    if (![TCAMiscHelper isRange:currentLineRange inBoundOfString:self.string]) {
        return;
    }
    NSString *currentLine = [[self string] substringWithRange:currentLineRange];
    NSMutableString *indentString = [NSMutableString stringWithCapacity:8];
    [super insertNewline:sender];
    //selLoc is already in new line because of [super insertNewline]
    NSInteger selLoc = [self selectedRange].location;
    while ((selLoc + 1)<= [[self string] length] && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[[self string] characterAtIndex:selLoc]]) {
        [self replaceCharactersInRange:NSMakeRange(selLoc, 1)withString:@""];
    }
    if (shallIndentNewLine) {
        for (int i = 0; i < [currentLine length]; i++) {
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:[currentLine characterAtIndex:i]]) {
                if ([TCAMiscHelper isRange:NSMakeRange(i, 1) inBoundOfString:self.string]) {
                    [indentString appendString:[currentLine substringWithRange:NSMakeRange(i, 1)]];
                }
            } else {
                break;
            }
        }
        [self insertText:indentString];
        [self setSelectedRange:NSMakeRange(selLoc + [indentString length], 0)];
    }
}


- (void)setTabString {
    tabBlankLength = [TCADefaultsHelper getTabWidth];

    if ([TCADefaultsHelper getReplaceTabs]) {
        NSMutableString *tempTabString = [NSMutableString stringWithCapacity:tabBlankLength];
        for (int i = 0; i < tabBlankLength; i++) {
            [tempTabString appendString:@" "];
        }
        tabString = [NSString stringWithString:tempTabString];
    } else {
        tabString = @"\t";
    }    
}


- (void) insertTab:(id)sender {
    NSMutableArray* rangesWithStringsToInsert = [NSMutableArray arrayWithCapacity:3];
    //[<range-string>,<tab-string>,<range-string>,<tab-string>, <selectedRange-string>]
    NSMutableArray* undoRangesWithStringsToReplace = [NSMutableArray arrayWithCapacity:3];
    
    NSRange selRange = [self selectedRange];
    NSInteger selLength = selRange.length;
    NSInteger selMax = NSMaxRange(selRange);
    NSInteger linesWithinSelection = 0;

    if (selLength == 0) {
        NSMutableString* tempTabString = [[NSMutableString alloc] initWithString:tabString];
        if ([TCADefaultsHelper getReplaceTabs]) {
            NSInteger lineStart = [[self string] lineRangeForRange:selRange].location;
            NSInteger tabLength = tabBlankLength - ((selRange.location - lineStart)% tabBlankLength);
            tempTabString = [NSMutableString stringWithCapacity:tabLength];
            for (int i = 0; i < tabLength; i++) {
                [tempTabString appendString:@" "];
            }
        }
        rangesWithStringsToInsert = [@[NSStringFromRange(selRange), tempTabString] mutableCopy];
        NSRange undoReplaceRange = NSMakeRange(selRange.location, tempTabString.length);
        undoRangesWithStringsToReplace = [@[NSStringFromRange(undoReplaceRange), tempTabString] mutableCopy];
    } else {
        NSInteger lineStart = selRange.location;
        NSString* text = [self string];
        NSInteger noOfLines = 0;
        do {
            NSRange lineRange = NSMakeRange(lineStart, NSMaxRange([text lineRangeForRange:NSMakeRange(lineStart, 0)])-lineStart);
            NSRange replaceRange = NSMakeRange(lineStart + tabString.length * noOfLines, 0);
            [rangesWithStringsToInsert addObject:NSStringFromRange(replaceRange)];
            [rangesWithStringsToInsert addObject:[tabString copy]];
            
            NSRange undoReplaceRange = NSMakeRange(replaceRange.location, tabString.length);
            [undoRangesWithStringsToReplace insertObject:[tabString copy] atIndex:0];
            [undoRangesWithStringsToReplace insertObject:NSStringFromRange(undoReplaceRange)atIndex:0];
            
            //get range of next line
            lineStart = NSMaxRange(lineRange);
            noOfLines++;
            linesWithinSelection++;
        } while (lineStart < selMax);
        linesWithinSelection--;
    }

    NSRange selectedRangeAfterInsert = NSMakeRange(selRange.location + tabString.length, selLength + ((linesWithinSelection)* tabString.length));

    NSDictionary* parameters = @{
    @"rangesWithStringsToInsert" : rangesWithStringsToInsert,
    @"selectionRange" : NSStringFromRange(selRange),
    @"undoRangesWithStringsToReplace" : undoRangesWithStringsToReplace,
    @"selectedRangeAfterInsert" : NSStringFromRange(selectedRangeAfterInsert)};
    
    [self insertTabInRange: parameters];
}

- (void)insertTabInRange:(NSDictionary*)theParameters {
    
    NSArray* theRangesWithStringsToInsert = theParameters[@"rangesWithStringsToInsert"];
    NSRange selRange = NSRangeFromString(theParameters[@"selectionRange"]);
    NSInteger firstTabLength = [[theRangesWithStringsToInsert objectAtIndex:1] length] - NSRangeFromString(theRangesWithStringsToInsert[0]).length;
    NSInteger lengthOfTabsInSelection = 0;
    [[self textStorage] beginEditing];
    for (NSInteger i = 0; i < theRangesWithStringsToInsert.count - 1; i += 2) {
        NSRange range = NSRangeFromString(theRangesWithStringsToInsert[i]);
        NSString* tab = theRangesWithStringsToInsert[i+1];
        [[self textStorage] replaceCharactersInRange:range withString:tab];
        lengthOfTabsInSelection += tab.length - range.length;
    }
    [[self textStorage] endEditing];
    
    lengthOfTabsInSelection -= firstTabLength;
    
    [self setSelectedRange:NSMakeRange(selRange.location + firstTabLength, selRange.length + lengthOfTabsInSelection)];
    
    
    NSDictionary* undoParameters = @{
    @"rangesWithStringsToReplace" : theParameters[@"undoRangesWithStringsToReplace"],
    @"selectionRange" : theParameters[@"selectedRangeAfterInsert"],
    @"undoRangesWithStringsToInsert" : theParameters[@"rangesWithStringsToInsert"],
    @"selectedRangeAfterDetab" : theParameters[@"selectionRange"]};
    
    [[self undoManager] registerUndoWithTarget:self selector:@selector(insertBackTabInRange:)object:undoParameters];
    if (self.undoManager.isUndoing) {
        [self.undoManager setActionName:@"Detab"];
    } else {
        [self.undoManager setActionName:@"Tab"];
    }
}


- (void)insertBacktab:(id)sender {
    NSMutableArray* rangesWithStringsToReplace = [NSMutableArray arrayWithCapacity:3];
    //[<range-string>,<tab-string>,<range-string>,<tab-string>, <selectedRange-string>]
    NSMutableArray* undoRangesWithStringsToInsert = [NSMutableArray arrayWithCapacity:3];
    
    NSRange selRange = [self selectedRange];
    NSInteger totalInsertedBlankLength = 0;
    NSInteger selLoc = selRange.location;
    NSInteger selLength = selRange.length;
    NSInteger selMax = NSMaxRange(selRange);
    NSString* text = [self string];
    NSRange lineRange = [text lineRangeForRange:NSMakeRange(selLoc, 0)];
    NSInteger lineStart = lineRange.location;
    while (lineStart <= selMax) { //iterate over all selected lines
        NSString* stringToReplace = @"";
        NSInteger blankLength = 0;
        NSRange tabReplaceRange = NSMakeRange(lineStart, blankLength);
        
        if ((lineStart < selLoc)&& ([text characterAtIndex:selLoc-1] == '\t')) {
            //remove tab within line
            stringToReplace = @"\t";
            blankLength = 1;
            tabReplaceRange =  NSMakeRange(selLoc - 1, blankLength);
            selLoc -= blankLength;
            if (selLoc > self.string.length || selLoc < 0) {
                selLoc = 0;
            }
        } else if ((lineStart < selLoc)&&  ([text characterAtIndex:selLoc-1] == ' ')) {
            //remove blanks within line
            NSInteger noOfTabsBefore = 0;
            for (NSInteger i = 0; i < (selLoc - lineStart); i++) {
                if ([text characterAtIndex:(lineStart + i)] == '\t') {
                    noOfTabsBefore++;
                }
            }
            
            blankLength = 0;
            NSInteger tabLength = tabBlankLength;
            unichar c = [text characterAtIndex:selLoc-1];
            while (c == ' ') {
                blankLength++;
                stringToReplace = [stringToReplace stringByAppendingString:@" "];
                
                if (blankLength == tabLength) {
                    break;
                }
                if (selLoc == blankLength) {
                    break;
                }
                NSInteger ttabBlackEqals = (noOfTabsBefore * tabBlankLength)- noOfTabsBefore;
                if ((selLoc + ttabBlackEqals - lineStart - blankLength)% tabLength == 0) {
                    break;
                }
                c = [text characterAtIndex:(selLoc - 1 - blankLength)];
            }
            tabReplaceRange =  NSMakeRange(selLoc - blankLength, blankLength);
            selLoc -= blankLength;
            if (selLoc > self.string.length || selLoc < 0) {
                selLoc = 0;
            }
        } else if ((lineStart >= selLoc)&& [text characterAtIndex:lineStart] == '\t') {
            //remove tab at line start
            stringToReplace = @"\t";
            blankLength = 1;
            tabReplaceRange = NSMakeRange(lineStart, blankLength);
            selLength -= blankLength;
        } else if ((lineStart >= selLoc)&& [text characterAtIndex:lineStart] == ' ') {
            //remove blanks at line start
            blankLength = 0;
            NSInteger tabLength = tabBlankLength;
            unichar c = [text characterAtIndex:lineStart];
            while (c == ' ') {
                blankLength++;
                stringToReplace = [stringToReplace stringByAppendingString:@" "];
                if (blankLength == tabLength || ((lineStart + blankLength)>= [text length] - 1)) {
                    break;
                }
                c = [text characterAtIndex:(lineStart + blankLength)];
            }
            tabReplaceRange = NSMakeRange(lineStart, blankLength);
            selLength -= blankLength;
        }

        tabReplaceRange.location -= totalInsertedBlankLength;
        //if no tab found tabReplaceRange has zero length
        [rangesWithStringsToReplace addObject:NSStringFromRange(tabReplaceRange)];
        [rangesWithStringsToReplace addObject:stringToReplace];
        NSRange undoTabInsertRange = NSMakeRange(tabReplaceRange.location, 0);
        [undoRangesWithStringsToInsert insertObject:stringToReplace atIndex:0];
        [undoRangesWithStringsToInsert insertObject:NSStringFromRange(undoTabInsertRange)atIndex:0];
        
        //calculate next line
        totalInsertedBlankLength += blankLength;
        lineRange = [text lineRangeForRange:NSMakeRange(NSMaxRange(lineRange), 0)];
        if (lineStart == lineRange.location) {
            //no next line in text
            break;
        } else {
            lineStart = lineRange.location;
        }
    } //end while
    
    if (selLength > self.string.length || selLength < 0) {
        selLength = 0;
    }
    NSRange selectedRangeAfterDetab =  NSMakeRange(selLoc, selLength);
    [undoRangesWithStringsToInsert addObject:NSStringFromRange(selectedRangeAfterDetab)];
    
    NSDictionary* parameters = @{
    @"rangesWithStringsToReplace" : rangesWithStringsToReplace,
    @"selectionRange" : NSStringFromRange(selRange),
    @"undoRangesWithStringsToInsert" : undoRangesWithStringsToInsert,
    @"selectedRangeAfterDetab" : NSStringFromRange(selectedRangeAfterDetab)};
    
    [self insertBackTabInRange: parameters];
    
}

- (void)insertBackTabInRange:(NSDictionary*)theParameters {
    NSArray* theRangesWithStringsToReplace = theParameters[@"rangesWithStringsToReplace"];
    NSRange selRange = NSRangeFromString(theParameters[@"selectionRange"]);
    NSInteger firstTabLength = NSRangeFromString(theRangesWithStringsToReplace[0]).length;
    NSInteger lengthOfTabsInSelection = 0;
    
    [[self textStorage] beginEditing];
    NSInteger minimumReplaceLocation = selRange.location;
    for (NSInteger i = 0; i < theRangesWithStringsToReplace.count - 1; i += 2) {
        NSRange range = NSRangeFromString(theRangesWithStringsToReplace[i]);
        minimumReplaceLocation = MIN(minimumReplaceLocation, range.location);
        [[self textStorage] replaceCharactersInRange:range withString:@""];
        lengthOfTabsInSelection +=  range.length;
    }
    [[self textStorage] endEditing];
    
    if ((minimumReplaceLocation >= selRange.location)) {
        NSInteger selLen = selRange.length - lengthOfTabsInSelection;
        if (selLen > self.string.length || selLen < 0) {
            selLen = 0;
        }
        [self setSelectedRange:NSMakeRange(selRange.location, selLen)];//start of line
    } else {
        NSInteger selLen = MAX(0, selRange.length - lengthOfTabsInSelection + firstTabLength);
        [self setSelectedRange:NSMakeRange(selRange.location - firstTabLength, selLen)];
    }
    
    NSDictionary* undoParameters = @{
    @"rangesWithStringsToInsert" : theParameters[@"undoRangesWithStringsToInsert"],
    @"selectionRange" : theParameters[@"selectedRangeAfterDetab"],
    @"undoRangesWithStringsToReplace" : theParameters[@"rangesWithStringsToReplace"],
    @"selectedRangeAfterInsert" : theParameters[@"selectionRange"]};
    
    [self.undoManager registerUndoWithTarget:self selector:@selector(insertTabInRange:)object:undoParameters];
    if (self.undoManager.isUndoing) {
        [self.undoManager setActionName:@"Tab"];
    } else {
        [self.undoManager setActionName:@"Detab"];
    }
}


- (void)commentStringWithParameters:(NSDictionary*)parameters {
    NSString* selRangeString = parameters[@"selectionRange"];
    NSString* token = parameters[@"token"];
    NSArray* multiLineTokens = parameters[@"multilineTokens"];
    if (token == nil && multiLineTokens == nil) {
        return;
    }
    NSDictionary* commentParam;
    NSDictionary* uncommentParam;

    if (token) {
        commentParam = [TCATextManipulation parametersForCommentingString:self.string
                                                                  inRange:NSRangeFromString(selRangeString)
                                                                withToken:token];
        [self alterBeginningOfLinesWithParameters:commentParam];
        uncommentParam = @{@"selectionRange": commentParam[@"selectedRangeStringAfterInsert"],
                           @"token": token};
    } else if (multiLineTokens) {
        NSArray* actionNames = @[@"Commment", @"Uncomment"];
        commentParam = [TCATextManipulation parametersForSurroundString:self.string
                                                                inRange:NSRangeFromString(selRangeString)
                                                             withTokens:multiLineTokens
                                                         andActionNames:actionNames];
        [self surroundSelectionWithParameters:commentParam];
        uncommentParam = @{@"selectionRange": commentParam[@"selectedRangeStringAfterInsert"],
                           @"multilineTokens": multiLineTokens};
    }


        [self.undoManager registerUndoWithTarget:self selector:@selector(uncommentStringWithParameters:)object:uncommentParam];
    if (self.undoManager.isUndoing) {
        [self.undoManager setActionName:commentParam[@"doActionName"]];
    } else {
        [self.undoManager setActionName:commentParam[@"undoActionName"]];
    }
}


- (void)uncommentStringWithParameters:(NSDictionary*)parameters {
    NSString* selRangeString = parameters[@"selectionRange"];
    NSString* token = parameters[@"token"];
    NSArray* multiLineTokens = parameters[@"multilineTokens"];
    if (token == nil && multiLineTokens == nil) {
        return;
    }
    NSDictionary* uncommentParam;
    NSDictionary* commentParam;
    if (token) {
        uncommentParam = [TCATextManipulation parametersForUncommentingString:self.string
                                                                                    inRange:NSRangeFromString(selRangeString)
                                                                                  withToken:token];
        [self alterBeginningOfLinesWithParameters:uncommentParam];
        commentParam = @{@"selectionRange": uncommentParam[@"selectedRangeStringAfterInsert"],
                         @"token": token};
    } else if (multiLineTokens) {
        NSArray* actionNames = @[@"Uncomment", @"Comment"];
        uncommentParam = [TCATextManipulation parametersForRemoveSurroundingTokens:multiLineTokens
                                                                          ofString:self.string
                                                                           inRange:NSRangeFromString(selRangeString)
                                                                    andActionNames:actionNames];
        [self surroundSelectionWithParameters:uncommentParam];
        commentParam = @{@"selectionRange": uncommentParam[@"selectedRangeStringAfterInsert"],
                         @"multilineTokens": multiLineTokens};
    }

    [self.undoManager registerUndoWithTarget:self selector:@selector(commentStringWithParameters:)object:commentParam];
    if (self.undoManager.isUndoing) {
        [self.undoManager setActionName:uncommentParam[@"doActionName"]];
    } else {
        [self.undoManager setActionName:uncommentParam[@"undoActionName"]];
    }
}



- (void)alterBeginningOfLinesWithParameters:(NSDictionary*)parameters {
    NSArray* insertRanges = parameters[@"insertRanges"];
    NSString* token = parameters[@"workingString"];

    [[self textStorage] beginEditing];
    for (NSString* rangeString in insertRanges) {
        NSRange range = NSRangeFromString(rangeString);
        [[self textStorage] replaceCharactersInRange:range withString:token];
    }
    [[self textStorage] endEditing];

    NSRange selRange = NSRangeFromString(parameters[@"selectedRangeStringAfterInsert"]);
    [self setSelectedRange:selRange];
}


- (void)surroundSelectionWithParameters:(NSDictionary*)parameters {
    NSArray* insertRanges = parameters[@"insertRanges"];
    NSArray* tokens = parameters[@"tokens"];

    [[self textStorage] beginEditing];
    NSRange range = NSRangeFromString(insertRanges[0]);
    [[self textStorage] replaceCharactersInRange:range withString:tokens[0]];
    range = NSRangeFromString(insertRanges[1]);
    [[self textStorage] replaceCharactersInRange:range withString:tokens[1]];
    [[self textStorage] endEditing];

    NSRange selRange = NSRangeFromString(parameters[@"selectedRangeStringAfterInsert"]);
    [self setSelectedRange:selRange];
}


- (void) drawRect:(NSRect)dirtyRect {
    if ([(TCTextStorage*)[self textStorage] isEditingLevel] > 0) {
        return;
    }
    [super drawRect:dirtyRect];
    if (pageGuideColumn > 0 && [TCADefaultsHelper getShowPageGuide]) {
        NSBezierPath* verticalLine = [NSBezierPath bezierPath];
        CGFloat top = dirtyRect.origin.y;
        CGFloat bottom = dirtyRect.origin.y + dirtyRect.size.height;
        CGFloat x = 5 + pageGuidePosition;
        
        [verticalLine setLineWidth: 1];
        [verticalLine moveToPoint:NSMakePoint(x, top)];
        [verticalLine lineToPoint:NSMakePoint(x, bottom)];
        [verticalLine setFlatness:0];
        [pageGuideColor set];
        [verticalLine stroke];
    }
}


- (void)setBackgroundColor:(NSColor *)color {
    [super setBackgroundColor:color];
    pageGuideColor = [ColorConverter contrastingColorforColor:color withDegree:0.2];
}


- (void)setPageGuideColumn:(NSInteger)col {
    pageGuideColumn = col;
    if (pageGuideColumn < 1) {
        pageGuideColumn = 0;
    }
    CGFloat charWidth = [@"8" sizeWithAttributes:[self typingAttributes]].width;
    pageGuidePosition = charWidth * pageGuideColumn + 0.5;
}

- (void)setSelectedTextColor:(NSColor *)color {
    NSMutableDictionary *selTextAttributes = [[self selectedTextAttributes] mutableCopy];
    selTextAttributes[NSBackgroundColorAttributeName] = color;
    [self setSelectedTextAttributes:selTextAttributes];
    
}

- (void)setCurrentLineColor:(NSColor *)color {
    currentLineColor = @{NSBackgroundColorAttributeName: color};
    if (shallColorCurrentLine) {
        [self colorCurrentLine];
    }
}

- (void)toggleColoringCurrentLine:(BOOL)b {
    shallColorCurrentLine = b;
}

- (void)colorCurrentLine {
    [self removeBackgroundColorAttributesInText];
    if (shallColorCurrentLine) {
        NSRange selRange = [self selectedRange];
        if (selRange.length == 0) {
            NSRange lineRange = [[self string] lineRangeForRange:selRange];
            [[self layoutManager] setTemporaryAttributes:currentLineColor forCharacterRange:lineRange];
        }
    }
}

- (void)toggleIndentNewLine:(BOOL)b {
    shallIndentNewLine = b;
}


//Needed to enable the textView to select the whole content of brackets if doubleclicked on one bracket
- (NSRange)selectionRangeForProposedRange:(NSRange)proposedCharRange granularity:(NSSelectionGranularity)granularity {

    if (granularity != NSSelectByWord || [[self string] length] == proposedCharRange.location || [[NSApp currentEvent] clickCount] != 2) { 
        // if not doubleclicked
        return [super selectionRangeForProposedRange:proposedCharRange granularity:granularity];
    }
    
    NSInteger location = [super selectionRangeForProposedRange:proposedCharRange granularity:NSSelectByCharacter].location;
    NSInteger oldLocation = location;
    
    NSString *text = [self string];
    unichar charToCheck = [text characterAtIndex:location];
    NSInteger skipMatchingBrace = 0;
    NSInteger textLength = [text length];
    if (textLength == proposedCharRange.location) { // To avoid crash if a double-click occurs after any text
        return [super selectionRangeForProposedRange:proposedCharRange granularity:granularity];
    }
    
    BOOL triedToMatchBrace = NO;
    
    if (charToCheck == ')') {
        triedToMatchBrace = YES;
        while (location - 1 >= 0) {
            location--;
            charToCheck = [text characterAtIndex:location];
            if (charToCheck == '(') {
                if (!skipMatchingBrace) {
                    return NSMakeRange(location, oldLocation - location + 1);
                } else {
                    skipMatchingBrace--;
                }
            } else if (charToCheck == ')') {
                skipMatchingBrace++;
            }
        }
    } else if (charToCheck == '}') {
        triedToMatchBrace = YES;
        while (location - 1 >= 0) {
            location--;
            charToCheck = [text characterAtIndex:location];
            if (charToCheck == '{') {
                if (!skipMatchingBrace) {
                    return NSMakeRange(location, oldLocation - location + 1);
                } else {
                    skipMatchingBrace--;
                }
            } else if (charToCheck == '}') {
                skipMatchingBrace++;
            }
        }
    } else if (charToCheck == ']') {
        triedToMatchBrace = YES;
        while (location - 1 >= 0) {
            location--;
            charToCheck = [text characterAtIndex:location];
            if (charToCheck == '[') {
                if (!skipMatchingBrace) {
                    return NSMakeRange(location, oldLocation - location + 1);
                } else {
                    skipMatchingBrace--;
                }
            } else if (charToCheck == ']') {
                skipMatchingBrace++;
            }
        }
    } else if (charToCheck == '>') {
        triedToMatchBrace = YES;
        while (location - 1 >= 0) {
            location--;
            charToCheck = [text characterAtIndex:location];
            if (charToCheck == '<') {
                if (!skipMatchingBrace) {
                    return NSMakeRange(location, oldLocation - location + 1);
                } else {
                    skipMatchingBrace--;
                }
            } else if (charToCheck == '>') {
                skipMatchingBrace++;
            }
        }
    } else if (charToCheck == '(') {
        triedToMatchBrace = YES;
        while (location + 1 < textLength) {
            location++;
            charToCheck = [text characterAtIndex:location];
            if (charToCheck == ')') {
                if (!skipMatchingBrace) {
                    return NSMakeRange(oldLocation, location - oldLocation + 1);
                } else {
                    skipMatchingBrace--;
                }
            } else if (charToCheck == '(') {
                skipMatchingBrace++;
            }
        }
    } else if (charToCheck == '{') {
        triedToMatchBrace = YES;
        while (location + 1 < textLength) {
            location++;
            charToCheck = [text characterAtIndex:location];
            if (charToCheck == '}') {
                if (!skipMatchingBrace) {
                    return NSMakeRange(oldLocation, location - oldLocation + 1);
                } else {
                    skipMatchingBrace--;
                }
            } else if (charToCheck == '{') {
                skipMatchingBrace++;
            }
        }
    } else if (charToCheck == '[') {
        triedToMatchBrace = YES;
        while (location + 1 < textLength) {
            location++;
            charToCheck = [text characterAtIndex:location];
            if (charToCheck == ']') {
                if (!skipMatchingBrace) {
                    return NSMakeRange(oldLocation, location - oldLocation + 1);
                } else {
                    skipMatchingBrace--;
                }
            } else if (charToCheck == '[') {
                skipMatchingBrace++;
            }
        }
    } else if (charToCheck == '<') {
        triedToMatchBrace = YES;
        while (location + 1 < textLength) {
            location++;
            charToCheck = [text characterAtIndex:location];
            if (charToCheck == '>') {
                if (!skipMatchingBrace) {
                    return NSMakeRange(oldLocation, location - oldLocation + 1);
                } else {
                    skipMatchingBrace--;
                }
            } else if (charToCheck == '<') {
                skipMatchingBrace++;
            }
        }
    }
    
    //if no closing match exists
    if (triedToMatchBrace) {
        return [super selectionRangeForProposedRange:NSMakeRange(proposedCharRange.location, 1)granularity:NSSelectByCharacter];
    } else {
        return [super selectionRangeForProposedRange:proposedCharRange granularity:granularity];
    }
}

-(void)markRanges:(NSArray *)ranges {
    [self removeBackgroundColorAttributesInText];
    [self colorCurrentLine];
    for (NSValue *value in ranges) {
        /*[[self layoutManager] setTemporaryAttributes:[NSDictionary dictionaryWithObject:[NSUnarchiver unarchiveObjectWithData:[TCADefaults objectForKey:@"attributesColor"]] forKey:NSBackgroundColorAttributeName] forCharacterRange:[value rangeValue]];*/
        [[self layoutManager] setTemporaryAttributes:@{NSBackgroundColorAttributeName: pageGuideColor} forCharacterRange:[value rangeValue]];
        
    }
}

- (void)removeBackgroundColorAttributesInText {
    [[self layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, [[self string] length])];
}


- (void)toggleAutocompleteBrackets:(BOOL)b {
    shallAutocompleteBrackets = b;
}


- (float)calculateTabWidth {
    NSInteger tabLength = [TCADefaultsHelper getTabWidth];
    float charWidth = [@" " sizeWithAttributes:[self typingAttributes]].width;
    tabWidth = charWidth * tabLength;
    return tabWidth;
}

- (void)setTabWidthForCurrentFont {
    [self calculateTabWidth];
    NSMutableDictionary *textAttributes = [[self typingAttributes] mutableCopy];
    NSMutableParagraphStyle *style = [textAttributes[NSParagraphStyleAttributeName] mutableCopy];
    [style setDefaultTabInterval: tabWidth];
    [style setTabStops:@[]];
    for (int i = 0; i < 100; i++) {
        NSTextTab *tabStop = [[NSTextTab alloc] initWithType:NSLeftTabStopType location: tabWidth * i];
        [style addTabStop:tabStop];
    }

    textAttributes[NSParagraphStyleAttributeName] = style;
    [self setTypingAttributes:textAttributes];
    [self setDefaultParagraphStyle:style];
    NSRange rangeOfChange = NSMakeRange(0, [[self string]length]);
    [self shouldChangeTextInRange:rangeOfChange replacementString:nil];
    [[self textStorage] setAttributes:textAttributes range:rangeOfChange];
    [self didChangeText];
}

- (void)setInvisiblesColor:(NSColor *)color {
    [(TCLayoutManager *)[self layoutManager] setInvisiblesColor:color];
}

@end
