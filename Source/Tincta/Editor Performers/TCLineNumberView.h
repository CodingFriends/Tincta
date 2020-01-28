

#import <Cocoa/Cocoa.h>

@interface TCLineNumberView : NSRulerView
{

    NSInteger lastStringLength;
    
    BOOL needsRecalculateVisible;
	NSColor* textColor;
	NSColor* backgroundColor;
    NSTimer* redrawTimer;
    BOOL timerSet;
    BOOL capsuleSet;
    NSMutableString *tabInSpaces;
    
    BOOL isWrappingDisabled;
    NSString* biggestStringFound;
    NSInteger lastLineLocation;
    NSTextView* linesTextView;
    
    NSInteger lastLineCount;
    
}
@property (readonly, nonatomic) NSInteger charsPerLine;
@property (readonly) NSUInteger numberOfLines;
@property (strong) NSMutableDictionary *lineWraps; //array with number of wraps for each line. 0: no wrap 1: line breaks in 2 lines

@property (assign) BOOL isWrappingDisabled;


- (void) resetLineNumbers;
- (void) updateColors;
- (NSUInteger) lineNumberForCharacterIndex:(NSUInteger)index;
- (NSInteger) calculateLineWrapsForString: (NSString* )aLine;
- (NSDictionary* )textAttributes;
- (NSInteger) wrapsOfLine: (NSInteger) aLineNumber;

- (void) setNeedsDisplayCapsule;
- (void) redrawAfterScroll: (NSNotification* )aNotification;
- (void) redrawAfterTyping: (NSNotification* )aNotification;
- (void) textViewDidResize: (NSNotification* )aNotification;
- (void) textStorageDidChangeText: (NSNotification* )aNotification;

- (id)initWithScrollView:(NSScrollView* )aScrollView;

@end
