//
//  TCLayoutManager.h
//  Tincta
//
//  Created by Mr. Fridge on 4/30/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Foundation/Foundation.h>


@interface TCLayoutManager : NSLayoutManager {

    NSString* newLineCharacter;
    NSString* tabCharacter;
    NSString* chariageReturnCharacter;
    NSString* returnAndNewLineCharachter;

    NSString* bulletCharacter;
    NSMutableDictionary* attributes;
    BOOL isShowsInvisibles;
}

@property (assign) BOOL isShowsInvisibles;
- (void)drawGlyphsForGlyphRange:(NSRange)range atPoint:(NSPoint)origin;
- (void)setInvisiblesColor:(NSColor *)color;

@end
