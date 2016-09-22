//
//  TCLayoutManager.m
//  Tincta
//
//  Created by Mr. Fridge on 4/30/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "TCLayoutManager.h"
#import "TCTextStorage.h"

@implementation TCLayoutManager

@synthesize isShowsInvisibles;

- (id)init
{
    self = [super init];
    if (self) {
        
        newLineCharacter = @"\xe2\x86\x93";
        tabCharacter = @"\xe2\x86\x92";
        chariageReturnCharacter = @"\xe2\x86\x90";
        returnAndNewLineCharachter = @"\xe2\x86\xb5";
        bulletCharacter = @"\xe2\x80\xa2";
        NSFont *font = [NSFont fontWithName:@"Menlo Regular" size:11];
        attributes = [NSMutableDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        attributes[NSForegroundColorAttributeName] = [TCADefaultsHelper getInvisiblesColor];
        
        self.isShowsInvisibles = NO;
        // Initialization code here.
         
    }
    
    return self;
}


- (void) setShowsInvisibleCharacters:(BOOL)flag {
    [super setShowsInvisibleCharacters:NO];
    self.isShowsInvisibles = flag;
}


- (void)drawGlyphsForGlyphRange:(NSRange)range atPoint:(NSPoint)origin {
    
    if ([(TCTextStorage*)[self textStorage] isEditingLevel] > 0) {
        return;
    }
    [super drawGlyphsForGlyphRange:range atPoint:origin];
    
    if (isShowsInvisibles) {
        
        for (NSInteger i = range.location; i != range.location + range.length; i++) {
            NSUInteger charIndex = [self characterIndexForGlyphAtIndex:i];
            unichar c =[[[self textStorage] string] characterAtIndex:charIndex];
            
            if (c != ' ' && c != '\n' && c != '\r' && c != '\t') {
                //speed this up!
                continue;
            }
            
            unichar cNext =c;
            unichar cPrev =c;
            if (charIndex +1 < (range.location + range.length)) {
                cNext =[[[self textStorage] string] characterAtIndex:charIndex+1];
            }
            
            if (charIndex > range.location) {
                cPrev =[[[self textStorage] string] characterAtIndex:charIndex-1];
            }
            
            NSPoint pointToDrawAt = [self locationForGlyphAtIndex:i];
            NSRect glyphFragment = [self lineFragmentRectForGlyphAtIndex:i effectiveRange:NULL];
            pointToDrawAt.x += glyphFragment.origin.x;
            pointToDrawAt.y = glyphFragment.origin.y + glyphFragment.size.height/3;
            
            if (c == ' ') {
                [bulletCharacter drawAtPoint:pointToDrawAt withAttributes:attributes];
            } else if (c == '\r' && cNext == '\n') {
                [returnAndNewLineCharachter drawAtPoint:pointToDrawAt withAttributes:attributes];
            } else if (c == '\n' && cPrev != '\r') {
                [newLineCharacter drawAtPoint:pointToDrawAt withAttributes:attributes];
            } else if (c == '\r') {
                [chariageReturnCharacter drawAtPoint:pointToDrawAt withAttributes:attributes];
            } else if (c == '\t') {
                [tabCharacter drawAtPoint:pointToDrawAt withAttributes:attributes];
            }
            
        }
    }
}

- (void)setInvisiblesColor:(NSColor *)color {
    attributes[NSForegroundColorAttributeName] = color;
}

@end
