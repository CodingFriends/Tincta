
#import "TCLineNumberView.h"
#import "ColorConverter.h"
#import "TCTextStorage.h"
#import "TCTextView.h"
#import "TCLayoutManager.h"
#import "TCAMiscHelper.h"


#define DEFAULT_THICKNESS	22.0
#define RULER_MARGIN		1.0

@implementation TCLineNumberView

@synthesize lineWraps, isWrappingDisabled;

- (id)initWithScrollView:(NSScrollView *)aScrollView {
    if ((self = [super initWithScrollView:aScrollView orientation:NSVerticalRuler]) != nil) {
        
        [self setClientView:[aScrollView documentView]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawAfterScroll:) name:NSViewBoundsDidChangeNotification object: [aScrollView contentView]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidResize:) name:NSViewFrameDidChangeNotification object:aScrollView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textStorageDidChangeText:) name: @"TCTextStorageDidChangeText" object:nil];
        
        tabInSpaces = [NSMutableString stringWithCapacity:8];
        NSInteger tabWidthInSpaces = [TCADefaultsHelper getTabWidth];
        for (int i = 0; i < tabWidthInSpaces; i++) {
            [tabInSpaces appendString:@" "];
        }
        
        [self updateColors];        
        
        self.isWrappingDisabled = NO;
        
        linesTextView = [[NSTextView alloc] initWithFrame:[self bounds]];
        
        [linesTextView setAllowsUndo:NO];
        [linesTextView setRichText:NO];
        [linesTextView setUsesFontPanel:NO];
        [linesTextView setUsesFindPanel:NO];
        [linesTextView setAlignment:NSRightTextAlignment];
        [linesTextView setEditable:YES];
        [linesTextView setSelectable:NO];
        [linesTextView setAutomaticLinkDetectionEnabled:NO];
        [linesTextView setAutomaticQuoteSubstitutionEnabled:NO];
        [linesTextView setAutomaticTextReplacementEnabled:NO];
        [linesTextView setAutomaticDashSubstitutionEnabled:NO];
        [linesTextView setAutomaticDataDetectionEnabled:NO];
        [[linesTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
        [[linesTextView textContainer] setWidthTracksTextView:NO];
        [linesTextView setHorizontallyResizable:YES];
        [linesTextView setAutomaticSpellingCorrectionEnabled:NO];
        [linesTextView setDrawsBackground:NO];        
        [self addSubview:linesTextView];
    }
    return self;
}

- (void) updateColors {
    NSColor* tvBackground = [TCADefaultsHelper getBackgroundColor];
    NSColor* tvTextColor = [TCADefaultsHelper getTextColor];
    
    backgroundColor = [ColorConverter contrastingColorforColor:tvBackground withDegree:0.15];
    textColor = [ColorConverter contrastingColorforColor:tvTextColor withDegree:0.1];
    [linesTextView setTextColor:textColor];
    [self setNeedsDisplayCapsule];
}



- (NSInteger) wrapsOfLine: (NSInteger) aLineNumber {
    if (self.lineWraps == nil) {
        self.lineWraps = [NSMutableDictionary dictionaryWithCapacity:128];
    }

    TCTextStorage* textStorage = (TCTextStorage*)[(TCTextView*)[self clientView] textStorage];
    NSString* text = [textStorage string];
    if (text == nil) {//this should never happen and is not an intended case
        NSLog(@"ERROR > LineNumberView > textSTorage string is nil");
        return 0;
    }
    NSNumber* lineNumberObj = @(aLineNumber);
    NSNumber* lineWrapsNumberObj = (self.lineWraps)[lineNumberObj];
    if (lineWrapsNumberObj == nil) {
        NSRange lineRange = [textStorage lineRangeOfLine:aLineNumber];
        if (lineRange.location == NSNotFound || NSMaxRange(lineRange) > [text length] ) {
            return 0;
        }

        if (![TCAMiscHelper isRange:lineRange inBoundOfString:text]) {
            return 0;
        }
        NSString* lineText = [text substringWithRange:lineRange];
        NSInteger wraps = [self calculateLineWrapsForString:lineText];
        lineWrapsNumberObj = @(wraps);
        lineWraps[lineNumberObj] = lineWrapsNumberObj;
    }

    return [lineWrapsNumberObj integerValue];
}


- (void)resetLineNumbers {
    
    if (!self.isWrappingDisabled) {
        //WITH WRAPS ALLOWED        
        NSTextContainer* container = [(NSTextView*)[self clientView] textContainer];
        CGFloat containerWidth = [container containerSize].width;
        CGFloat charWidth = [@"8" sizeWithAttributes:[self textAttributes]].width;
        //CGFloat charHeight = [@"8" sizeWithAttributes:[self textAttributes]].height;
        
        CGFloat linePadding = [container lineFragmentPadding];
        _charsPerLine = (NSInteger)floor(((containerWidth - 2.0*linePadding) / charWidth));        
    } 
    CGFloat oldThickness = [self ruleThickness];
    CGFloat newThickness = [self requiredThickness];
    if (fabs(oldThickness - newThickness) > 1) {
        // Not a good idea to resize the view during calculations (which can happen during
        // display). Do a delayed perform (using NSInvocation since arg is a float).
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(setRuleThickness:)]];
        [invocation setSelector:@selector(setRuleThickness:)];
        [invocation setTarget:self];
        [invocation setArgument:&newThickness atIndex:2];
        [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0.0];
    }
    
    tabInSpaces = [NSMutableString stringWithCapacity:8];
    NSInteger tabWidthInSpaces = [TCADefaultsHelper getTabWidth];
    for (int i = 0; i < tabWidthInSpaces; i++) {
        [tabInSpaces appendString:@" "];
    }
    
    self.lineWraps = nil;
}


- (NSInteger) calculateLineWrapsForString: (NSString*) aLine {
    //chars per line must already be set correctly
    
    NSInteger wraps = 0;
    NSString* myLine = [aLine stringByReplacingOccurrencesOfString:@"\t" withString:tabInSpaces];
    NSInteger lineLength = [myLine length];
    
    if (lineLength > _charsPerLine && _charsPerLine != 0) {
        NSArray* components = [myLine componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t-/}!?+%|\\$€¥¢"]]; //$€¥¢\ will be inserted in next line instead of previous but we ignore that at the moment
        NSInteger currentLength = 0;
        NSInteger accuLength = 0;
        for (NSString* component in components) {
            currentLength = [component length];
            if (currentLength > _charsPerLine) {
                wraps += (NSInteger)ceil((CGFloat)currentLength/(CGFloat)_charsPerLine);
                accuLength = currentLength % _charsPerLine;
            } else {
                NSInteger totalLength = (accuLength + 1 + currentLength);
                if (totalLength > _charsPerLine) {
                    wraps++;
                    accuLength = currentLength;
                } else {
                    accuLength = totalLength;
                }
            }            
        }
    }
    return wraps;
}

- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)index  {
    // Binary search
    return [(TCTextStorage*)[(TCTextView*)[self clientView] textStorage] lineNumberForLocation:index];
}

- (NSDictionary *)textAttributes {
    NSMutableDictionary* attDict = [NSMutableDictionary dictionaryWithDictionary:[(NSTextView*)[self clientView] typingAttributes]];
    [attDict setValue:[TCADefaultsHelper getEditorFont] forKey:NSFontAttributeName];
    [attDict setValue:textColor forKey:NSForegroundColorAttributeName];
    return attDict;
}


- (void)textStorageDidChangeText:(NSNotification *)aNotification {
    if ([aNotification object][0] != (TCTextStorage*)[(TCTextView*)[self clientView] textStorage]) {
        return;
    }

    if (lineWraps != nil) {
        
        NSRange rangeAfter = [[aNotification object][2] rangeValue];
        NSInteger affectedNewLineNumbersStart = [self lineNumberForCharacterIndex:rangeAfter.location];
        NSInteger affectedNewLineNumbersEnd = [self lineNumberForCharacterIndex:NSMaxRange(rangeAfter)];
        
        if (self.numberOfLines == lastLineCount) {
            
            NSInteger i = affectedNewLineNumbersStart;
            NSInteger m = affectedNewLineNumbersEnd;

            for (; i <= m; i++) {
                    [lineWraps removeObjectForKey:@(i)];
            }
          
        } else {
            [self resetLineNumbers];
        }
        lastLineCount = self.numberOfLines;

    } else {
        lastLineCount = -1;
    }
    [self redrawAfterTyping:nil];
}


- (NSUInteger) numberOfLines {
    return [(TCTextStorage*)[(TCTextView*)[self clientView] textStorage] numberOfLines];
}

- (CGFloat)requiredThickness {
    NSUInteger lineCount = self.numberOfLines;
    NSUInteger digits = (unsigned)log10(lineCount) + 1 + 1;
	NSMutableString* sampleString = [NSMutableString string];
    for (int i = 0; i < digits; i++) {
        [sampleString appendString:@"8"]; // Use "8" since it is one of the fatter numbers.
    }
    NSSize stringSize = [sampleString sizeWithAttributes:[self textAttributes]];
    
	// Round up the value to return integer value (.5 would be ok, too i guess...)
    return ceilf(MAX(DEFAULT_THICKNESS, stringSize.width + RULER_MARGIN * 2));
}

- (void) redrawAfterScroll: (NSNotification*) aNotification {
    [self setNeedsDisplayCapsule];
}

- (void) redrawAfterTyping: (NSNotification*) aNotification {
    if (!timerSet) {
        timerSet = YES;
    } else {
        if (redrawTimer != nil) {
            [redrawTimer invalidate];
        }
    }
    redrawTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setNeedsDisplayCapsule) userInfo:nil repeats:NO];
}

- (void) textViewDidResize: (NSNotification*) aNotification {
    if (!timerSet) {
        timerSet = YES;
        [self resetLineNumbers];
    } else {
        [redrawTimer invalidate];
        [self resetLineNumbers];
    }
    redrawTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setNeedsDisplayCapsule) userInfo:nil repeats:NO];
}


- (void) setNeedsDisplayCapsule {
    timerSet = NO;
    [self setNeedsDisplay:YES];
    capsuleSet = YES;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect {
    //draw background and vertical line
	NSRect bounds = [self bounds];
	if (backgroundColor != nil) {
		[backgroundColor set];
		NSRectFill(bounds);
		
		[textColor set];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(bounds) - 0/5, NSMinY(bounds)) toPoint:NSMakePoint(NSMaxX(bounds) - 0.5, NSMaxY(bounds))];
	}
    
    if (!capsuleSet || timerSet/* || ![NSApp isActive]*/) {
        return;
    }
    capsuleSet = NO;
    
    
	
    NSRect visibleRect = [[[self scrollView] contentView] bounds];
    
    // Find the characters that are currently visible
    TCTextView* textView = (TCTextView*)[self clientView];
    TCLayoutManager* layoutManager = (TCLayoutManager*)[textView layoutManager];
    
    NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer: [textView textContainer]];
    NSRange visibleCharRange = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];

    NSUInteger locationOfFirstVisibleChar = visibleCharRange.location;
    
    NSUInteger lineNumber = [self lineNumberForCharacterIndex:locationOfFirstVisibleChar];
    NSUInteger lineStartIndex;

    NSMutableString* linesLabels = [NSMutableString stringWithCapacity:256];
    NSRect firstGlyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(locationOfFirstVisibleChar, 1) inTextContainer:[textView textContainer]];
    CGFloat yinset = [textView textContainerInset].height;
    
    CGFloat ypos = yinset + firstGlyphRect.origin.y - visibleRect.origin.y;

    CGFloat charHeight = [@"8" sizeWithAttributes:[self textAttributes]].height;
    CGFloat linePadding = [[textView textContainer] lineFragmentPadding];
    
    if (ypos <= -(charHeight - yinset)) {
        //sometimes the draw position does not match the first char to draw so it draws at ca. -20 we need to correct this
        ypos += charHeight + linePadding - yinset;
    }
    [linesTextView setAlignment:NSRightTextAlignment range:NSMakeRange(0, [linesLabels length])];
    NSRect labelDrawRect = NSMakeRect(0, ypos, [self bounds].size.width - RULER_MARGIN * 2.0, [self bounds].size.height+10);
    [linesTextView setFrame:labelDrawRect];
    [linesTextView setFont:[TCADefaultsHelper getEditorFont]];

    NSInteger lastVisibleLine = [self lineNumberForCharacterIndex:NSMaxRange(visibleCharRange)];
    
    while (lineNumber <= lastVisibleLine ) {
        
        if (!self.isWrappingDisabled) {
            
            lineStartIndex = [(TCTextStorage*) [textView textStorage] lineRangeOfLine:lineNumber].location;
            
            if (locationOfFirstVisibleChar > lineStartIndex) {
                //first visible is break of previous line
                //so we first need to calculate how much of the previous line is visible
                NSUInteger nextLineCharIndex = NSMaxRange([(TCTextStorage*) [textView textStorage] lineRangeOfLine:lineNumber]);
                if (lineNumber + 1 < self.numberOfLines) {
                    nextLineCharIndex = [(TCTextStorage*) [textView textStorage] lineRangeOfLine:lineNumber + 1].location;
                } else {
                    //NSRange lastLineRange = [[self.lineRanges lastObject] rangeValue];
                }
                NSUInteger visibleLineLength = nextLineCharIndex - locationOfFirstVisibleChar;
                if (locationOfFirstVisibleChar > nextLineCharIndex) {
                    visibleLineLength = 0;
                }
                NSRange visibleLineRange = NSMakeRange(locationOfFirstVisibleChar, visibleLineLength);
                if (![TCAMiscHelper isRange:visibleLineRange inBoundOfString:[textView string]]) {
                    return;
                }
                NSString* lineText = [[textView string] substringWithRange:visibleLineRange];
                NSInteger wraps = 1 + [self calculateLineWrapsForString:lineText];
                for (int i = 0; i < wraps; i++) {
                    [linesLabels appendString:@".\n"];  
                }
            } else {
                //calculate regular line numbers and wraps
                NSString* labelText = [NSString stringWithFormat:@"%ld\n", lineNumber + 1];
                [linesLabels appendString:labelText];  
                NSInteger lineWrapsNo = [self wrapsOfLine:lineNumber];
                for (int i = 0; i < lineWrapsNo; i++) {
                    [linesLabels appendString:@".\n"]; 
                }
            }
        } else {
            //NO LINE WRAPS ALLOWED
            lineStartIndex = [(TCTextStorage*) [textView textStorage] lineRangeOfLine:lineNumber].location;
            //calculate regular line numbers
            NSString* labelText = [NSString stringWithFormat:@"%ld\n", lineNumber + 1];
            [linesLabels appendString:labelText];  
            
        }
        if (lineStartIndex > NSMaxRange(visibleCharRange)) {
            //break;
        }
        lineNumber++;
    }
    [linesTextView setFont:[TCADefaultsHelper getEditorFont]];
    [linesTextView setString:linesLabels];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
