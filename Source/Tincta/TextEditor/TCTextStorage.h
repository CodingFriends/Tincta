//
//  TCTextStorage.h
//  Tincta Pro
//
//  Created by Mr. Fridge on 10/29/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt) 
//

#import <AppKit/AppKit.h>

@interface TCTextStorage : NSTextStorage {
    NSMutableAttributedString *m_attributedString;
    
    NSInteger numberOfLines;
    NSInteger tempNumberOfLines;
    NSInteger isEditingLevel; 
    
    BOOL isTCNotificationEnabled;
    BOOL isNotificationTimerSet;
    NSMutableArray* lineRanges;
    
    NSMutableDictionary* pendingOffsetsForLines; 
    NSTimer* offsetTimer;
    NSInteger firstLineWithPendingOffsets;
    NSInteger firstLocationWithPendingOffsets;
    
    NSInteger lastEditedLine;
    BOOL isOffsetTimer;
    
    NSMutableArray* pendingNotificationObjects;
}

@property (assign) BOOL isTCNotificationEnabled;
@property (assign) NSInteger isEditingLevel; 

- (id) initWithAttributedString:(NSAttributedString *)attrStr;
- (id) initWithString:(NSString *)str;
- (id) initWithString:(NSString *)str attributes:(NSDictionary *)attrs;
- (void) doInitStuff;
- (NSRange) lineRangeOfLine: (NSInteger) theLine;
- (NSUInteger)lineNumberForLocation:(NSUInteger)index;
//- (void) addOffset: (NSInteger) offset toLineRangesFrom: (NSInteger) lineIndex  upToLine: (NSInteger) stopLine;
- (NSMutableArray*) lineRangesInString: (NSString*) aString fromLocation: (NSInteger) loc;

- (void) postNotifications;
//- (void) applyAllPendingOffsets;

//methods need to be overwritten because they are abstract in superclass
- (NSString *)string;
- (NSDictionary *)attributesAtIndex:(unsigned)index effectiveRange:(NSRangePointer)aRange;
- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)str;
//- (void)replaceCharactersInRange:(NSRange)aRange withAttributedString:(NSAttributedString *)attrString;

//- (void)insertAttributedString:(NSAttributedString *)attributedString atIndex:(NSUInteger)index;

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange;
//- (void)deleteCharactersInRange:(NSRange)aRange;


- (NSInteger) numberOfLines;
//helpers
- (NSInteger) numberOfLinesInString: (NSString*) aString;
@end
