//
//  TCTextStorage.m
//  Tincta Pro
//
//  Created by Mr. Fridge on 10/29/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "TCTextStorage.h"
#import "TCAMiscHelper.h"

@implementation TCTextStorage
@synthesize isTCNotificationEnabled, isEditingLevel;

- (id) init {
    self = [super init];
    m_attributedString = [[NSMutableAttributedString alloc] init];
    [self doInitStuff];
    return self;
}

- (id) initWithAttributedString:(NSAttributedString *)attrStr {
    self = [super init];
    m_attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    [self doInitStuff];
    return self;
}

- (id) initWithString:(NSString *)str {
    self = [super init];
    m_attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [self doInitStuff];
    return self;
}

- (id) initWithString:(NSString *)str attributes:(NSDictionary *)attrs {
    self = [super init];
    m_attributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
    [self doInitStuff];
    return self;
}


- (void) doInitStuff {
    numberOfLines = -1;
    lastEditedLine = -1;
    isEditingLevel = 0;
    firstLineWithPendingOffsets = NSIntegerMax;
    [self numberOfLines];
    lineRanges = [NSMutableArray arrayWithCapacity:128];
    pendingNotificationObjects = [NSMutableArray arrayWithCapacity:2];
    pendingOffsetsForLines = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [lineRanges addObjectsFromArray:[self lineRangesInString:[self string] fromLocation:0]];
    
    isTCNotificationEnabled = YES;
    isNotificationTimerSet = NO;
}

- (NSInteger) numberOfLines {
    if (numberOfLines < 0) {
        numberOfLines = [self numberOfLinesInString:[self string]];
    }
    return numberOfLines;
}

- (NSInteger) numberOfLinesInString: (NSString*) aString {
    if ([aString length] == 0) {
        return 1;
    }
    __block NSInteger l = 0;
    [aString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        l++;
    }];
    if ([aString hasSuffix:@"\n"] || [aString hasSuffix:@"\r"]) {
        l++;
    }
    return l;    
}

- (NSRange) lineRangeOfLine: (NSInteger) theLine {
    
    if (theLine < 0 || theLine >= [lineRanges count]) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    BOOL didRecalculate = NO;
    
    if ([pendingOffsetsForLines count] > 0) {
        NSInteger stopLine = MIN(theLine + 100, [lineRanges count]); //stopLine itself is not recalculated
        
        if (firstLineWithPendingOffsets != stopLine) {
            didRecalculate = YES;
        }
        
        NSMutableDictionary* newOffsetsDict = [NSMutableDictionary dictionaryWithCapacity:[pendingOffsetsForLines count]];
        firstLineWithPendingOffsets = NSIntegerMax;
        NSArray* keyset = [pendingOffsetsForLines allKeys];
        for (NSNumber* keyLineNumber in keyset) {
            NSNumber* offsetNumber = pendingOffsetsForLines[keyLineNumber];
            NSInteger keyLine = [keyLineNumber integerValue];
            
            if (keyLine >= [lineRanges count]) {
                continue;
            }
            
            if (keyLine < stopLine) {                
                
                //////////////
                //add offsets to all lines between keyLine (inclusively) and stopline (exclusively)
                NSIndexSet* is = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(keyLine, stopLine - keyLine)];
                [lineRanges enumerateObjectsAtIndexes:is options:NSEnumerationConcurrent usingBlock: ^(NSValue* obj, NSUInteger idx, BOOL *stop) {
                    NSRange newRange = [obj rangeValue];
                    newRange.location += [offsetNumber integerValue];
                    NSValue* v = [NSValue valueWithRange:newRange];
                    lineRanges[idx] = v;
                }];
                ///////////////   
                
                if (stopLine < [lineRanges count]) {
                    newOffsetsDict[@(stopLine)] = offsetNumber;
                    firstLineWithPendingOffsets = MIN(firstLineWithPendingOffsets, stopLine );
                }
            } else {
                newOffsetsDict[keyLineNumber] = offsetNumber;
                firstLineWithPendingOffsets = MIN(firstLineWithPendingOffsets, keyLine);
            }
        }
        pendingOffsetsForLines = newOffsetsDict;
        
        if (firstLineWithPendingOffsets != stopLine && [pendingOffsetsForLines count] > 0) {
        }
    }
    if (didRecalculate) {
    }
    
    return [lineRanges[theLine] rangeValue];
}



//!! attention: ranges do not include the line break characters
- (NSMutableArray*) lineRangesInString: (NSString*) aString fromLocation: (NSInteger) loc {
    NSMutableArray* lRanges = [NSMutableArray arrayWithCapacity:2];
    
    NSInteger lineCnt = 0;
    NSInteger location = loc;
    
    NSString* myStr = [aString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\a\n"];
    //we replace r by \a (bell) because the length must stay the same
    myStr = [aString stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    
    NSArray* lines = [aString componentsSeparatedByString:@"\n"];
    for (NSString* l in lines) {
        NSRange lineRange = NSMakeRange(location, [l length]);
        
        if ([l hasSuffix:@"\a"]) {
            lineRange.length--; //windows new line \r\n
        }
        location += [l length] + 1; //also correct for \r\n because \r is part of l
        [lRanges addObject:[NSValue valueWithRange: lineRange]];
        lineCnt++;
    }
    return lRanges;
}


- (NSUInteger)lineNumberForLocation:(NSUInteger)theLoc {
    
    // Binary search
    NSUInteger left = 0;
    NSUInteger right = self.numberOfLines;
    
    //this will speed up search dramatically if pending ofssets dont need to be recalculated
    NSRange rangeOfLastLineWithoutPendingChanges = [self lineRangeOfLine:(firstLineWithPendingOffsets - 1)];
    if (theLoc <= rangeOfLastLineWithoutPendingChanges.location && rangeOfLastLineWithoutPendingChanges.location != NSNotFound) {
        right = firstLineWithPendingOffsets - 1;
        NSRange rightLineRange = [self lineRangeOfLine:right];
        if (theLoc <= NSMaxRange(rightLineRange) && theLoc >= rightLineRange.location) {
            return right;
        }
    } else {
        NSRange lastChangedLineRange = [self lineRangeOfLine:(lastEditedLine + 100)];
        if (theLoc <= NSMaxRange(lastChangedLineRange)) {
            right = lastEditedLine + 100;
        }
    }
    
    while ((right - left) > 1) {
        NSUInteger mid = (right + left) / 2;
        NSRange midLineRange = [self lineRangeOfLine:mid];
        
        if (theLoc < (midLineRange.location)) {
            right = mid;
        } else if (theLoc > (NSMaxRange(midLineRange))){ //+1 because of line break
            if ([lineRanges count] > (mid + 1)) {
                NSRange nextLineRange = [self lineRangeOfLine:mid + 1];
                if (theLoc < nextLineRange.location) {
                    //line end chars line \n are not part of the line range so must be checked
                    //therefore \n still counts as part of the line
                    return mid;
                }
            }
            left = mid;
        } else {
            return mid;
        }
    }
    return left;
}


//////////////////
- (void) beginEditing {
    isEditingLevel++;    
    [super beginEditing];
}

- (void) endEditing {
    isEditingLevel--;
    [super endEditing];
    if (isEditingLevel == 0 && isTCNotificationEnabled && !isNotificationTimerSet) {
        isNotificationTimerSet = YES;
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(postNotifications) userInfo:nil repeats:NO];
    }
}

- (void) postNotifications {
    isTCNotificationEnabled = NO; //maybe this is not necessary...
    for (NSArray* notifiObject in pendingNotificationObjects) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TCTextStorageDidChangeText" object:notifiObject];
    }
    [pendingNotificationObjects removeAllObjects];
    isTCNotificationEnabled = YES;
    isNotificationTimerSet = NO;
}


//methods need to be overwritten because they are abstract in superclass

- (NSString *)string {
    return [m_attributedString string];
}

- (NSDictionary *)attributesAtIndex:(unsigned)index effectiveRange:(NSRangePointer)aRangePtr {
    return [m_attributedString attributesAtIndex:index effectiveRange:aRangePtr];
}


- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)str {
    
    if (aRange.location > [[self string] length] || NSMaxRange(aRange) > [[self string] length]) {
        return;
    }
    NSInteger lengthChange = [str length] - aRange.length;

    //////////////Calculate line ranges
    NSMutableArray* lRanges = [self lineRangesInString:str fromLocation:aRange.location];
    NSInteger lineOfReplaceRange = [self lineNumberForLocation:aRange.location];
    lastEditedLine = lineOfReplaceRange;
    NSRange replaceLineRange = [self lineRangeOfLine:lineOfReplaceRange];
    
    
    ///////////line count
    NSInteger newLinesCount = [lRanges count];
    if (![TCAMiscHelper isRange:aRange inBoundOfString:self.string]) {
        NSLog(@"Some Ranges went horribly wrong in TextStorage!");
    }
    NSInteger oldLinesCount = [self numberOfLinesInString:[[self string] substringWithRange:aRange]];
    NSInteger changedLines = newLinesCount - oldLinesCount;
    numberOfLines += changedLines;
    ////////////

    
    if ([lRanges count] > 0) {
        //Calculates inserted lines, add to lineRanges
        NSRange nextLineRange  = NSMakeRange(NSNotFound, 0);
        if ((lineOfReplaceRange + 1) < self.numberOfLines) { 
            nextLineRange = [self lineRangeOfLine:lineOfReplaceRange + 1];
        }
        
        NSInteger nextLineAfterSelection = [self lineNumberForLocation:NSMaxRange(aRange)]; 
        NSRange lineRangeAfterSelection = [self lineRangeOfLine:nextLineAfterSelection];
        
        if (NSMaxRange(aRange) > NSMaxRange(lineRangeAfterSelection) && (nextLineAfterSelection + 1) < self.numberOfLines) {
            nextLineAfterSelection += 1;
            lineRangeAfterSelection = [self lineRangeOfLine:nextLineAfterSelection];
        }
        
        NSInteger prevLineRemainingLength = aRange.location - replaceLineRange.location;
        NSInteger nextLineRemainingLength = NSMaxRange(lineRangeAfterSelection) - NSMaxRange(aRange);
       
        replaceLineRange.length = prevLineRemainingLength  + [lRanges[0] rangeValue].length; //first line adds to current
        lRanges[0] = [NSValue valueWithRange:replaceLineRange];
        NSRange lastRange = [[lRanges lastObject] rangeValue];
        lastRange.length += nextLineRemainingLength; //first line adds to current
        lRanges[([lRanges count] -1)] = [NSValue valueWithRange:lastRange];
        
        for (NSInteger i = 0; i < oldLinesCount; i++) {
            if (lineOfReplaceRange < [lineRanges count]) {
                [lineRanges removeObjectAtIndex:lineOfReplaceRange];
            }
        }
        for (NSInteger i = 0; i < [lRanges count]; i++) {
            [lineRanges insertObject:lRanges[i] atIndex:lineOfReplaceRange + i];
        }
        
        // Caclculate Offsets for following line ranges
        NSNumber* lineNumber = [NSNumber numberWithInteger:lineOfReplaceRange + [lRanges count]];
        NSNumber* oldOffset = pendingOffsetsForLines[lineNumber];
        NSNumber* newOffset = @(lengthChange);
        
        if (oldOffset != nil) {
            newOffset = @( lengthChange + [oldOffset integerValue]);
        } 
        
        if (changedLines != 0) {
            firstLineWithPendingOffsets = NSIntegerMax;
            NSMutableDictionary* newOffsetsDict = [NSMutableDictionary dictionaryWithCapacity:[pendingOffsetsForLines count]];
            
            NSArray* keyset = [pendingOffsetsForLines allKeys];
            for (NSNumber* keyLineNumber in keyset) {
                NSNumber* offsetNumber = pendingOffsetsForLines[keyLineNumber];

                if ([keyLineNumber isGreaterThan:lineNumber]) {
                    NSInteger newKeyLine = [keyLineNumber integerValue] + changedLines;
                    newOffsetsDict[@(newKeyLine)] = offsetNumber;
                    firstLineWithPendingOffsets = MIN(firstLineWithPendingOffsets, newKeyLine); 
                } else {
                    newOffsetsDict[keyLineNumber] = offsetNumber;
                    firstLineWithPendingOffsets = MIN(firstLineWithPendingOffsets, [keyLineNumber integerValue]); 
                }
            }
            pendingOffsetsForLines = newOffsetsDict;
        } 
        pendingOffsetsForLines[lineNumber] = newOffset;
        firstLineWithPendingOffsets = MIN(firstLineWithPendingOffsets, [lineNumber integerValue]);
    }
    //end if lRanges > 0
    [m_attributedString replaceCharactersInRange:aRange withString:str];
    [self edited:NSTextStorageEditedCharacters range:aRange changeInLength:lengthChange];
    
    if (self.isTCNotificationEnabled) {
        NSRange rangeBefore = NSMakeRange(aRange.location, aRange.length);
        NSRange rangeAfter = NSMakeRange(aRange.location, [str length]);
        
        NSValue* rangeValueBefore = [NSValue valueWithRange:rangeBefore];
        NSValue* rangeValueAfter = [NSValue valueWithRange:rangeAfter];
        
        NSArray* notificationObject = @[self,rangeValueBefore, rangeValueAfter];
        
        [pendingNotificationObjects addObject:notificationObject]; //will be sent in end editing
    }
    
    //this is a bug in TextStorage: When text was only deleted, no begin and end editing is send
    if (isEditingLevel == 0) {
        if (isTCNotificationEnabled && !isNotificationTimerSet) {
            isNotificationTimerSet = YES;
            [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(postNotifications) userInfo:nil repeats:NO];
        }
    }
        
}//replace end

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange {
    if (m_attributedString == nil || aRange.location + aRange.length > m_attributedString.length)
    {
        return;
    }
    [m_attributedString setAttributes:attributes range:aRange];
    [self edited:NSTextStorageEditedAttributes range:aRange changeInLength:0];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
