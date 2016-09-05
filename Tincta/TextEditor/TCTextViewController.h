//
//  TextViewController.h
//  Tincta
//
//  Created by Mr. Fridge on 4/15/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <Foundation/Foundation.h>

@class TCLineNumberView;
@class TCSyntaxColoring, TCSideBarItem, TCTextView, TCEncodings, TCNotificationCreator, TCTextStorage;
@interface TCTextViewController : NSObject <NSLayoutManagerDelegate, NSTextViewDelegate> {

    TCEncodings* encodingsController;

    TCSideBarItem* selectedSideBarItem;

    
    BOOL needsScrolling;
   
    TCNotificationCreator* notificationCreator;
}
@property (assign) IBOutlet TCTextView* textView;
@property (assign) IBOutlet NSScrollView* scrollView;
@property (assign) IBOutlet NSWindow* window;

@property (assign) IBOutlet NSMenuItem* showsInvisblesMenuItem;
@property (assign) IBOutlet NSMenuItem* syntaxColorMenuItem;
@property (assign) IBOutlet NSPopUpButton* syntaxColorToolbarPopup;

@property (assign) IBOutlet NSMenu* textMenu;
@property (assign) IBOutlet NSMenuItem* convertEncodingsMenuItem;
@property (assign) IBOutlet NSMenuItem* reinterpretEncodingsMenuItem;

@property (assign) IBOutlet NSPanel* goToLinePanel;
@property (assign) IBOutlet NSTextField* goToLineTextField;


@property (strong) TCLineNumberView* lineNumberView;
@property (strong) TCSyntaxColoring* syntaxColoring;

- (TCTextStorage*) textStorage;

- (void) setTextStorage:(TCTextStorage *)newTextStorage;


- (void) setTextViewString: (NSString*) aString;
- (void) setTextViewStringWithUndo: (NSString*) aString;
- (void) setTextEncodingWithUndo: (NSStringEncoding) enc andString: (NSString*) aString;

- (NSString*) textViewString;
- (void) scrollTextViewToPoint: (NSPoint) aPoint;
- (void)setSyntaxDefinitionByFileExtension:(NSString *)fileExtension;
- (NSPoint) textViewScrollPoint;

- (NSArray *) selectedTextViewRanges;
- (void) setSelectedTextViewRanges: (NSArray *) ranges;
- (void) makeTextViewFirstResponder;
- (void) invalidateAllLineNumbers;
- (NSInteger) numberOfLines;

- (void) setLineWrapping: (BOOL) doWrap;

- (void) changeSelectedSideBarItem: (TCSideBarItem*) theItem;
- (void)updateSyntaxDefinitionMenu;
- (void)textViewDidResize:(NSNotification *)aNotification;
- (void)textViewDidScroll:(NSNotification *)aNotification;
- (void)textViewDidChangeSelection:(NSNotification *)aNotification;

- (void)preferencesDidChange:(NSNotification *)aNotification ;
- (void) preferencesDidChangeWrapping:(NSNotification *)aNotification;

- (NSPrintInfo* ) printInfo;

- (void)goToLine:(NSInteger)aLine;
- (NSInteger) selectedLine;
- (NSInteger) selectedCharLocationInLine: (NSInteger) aLine;

- (IBAction) menuConvertEncodingChange: (id) sender;
- (IBAction) menuReinterpredEncodingChange: (id) sender;

- (IBAction) changeLineEndingsToWindows:(id) sender;
- (IBAction) changeLineEndingsToMac:(id) sender;
- (IBAction) changeTabsToSpaces:(id)sender;
- (IBAction) changeSpacesToTabs:(id)sender;
- (IBAction) setShowInvisibles: (id) sender;
- (IBAction) menuSyntaxDefinitionChange: (id) sender;
- (IBAction)toggleBlockComment:(id)sender;
- (void)clearUndoManager;
- (NSUndoManager*) undoManager;

- (IBAction)textViewUppercaseWord:(id)sender;
- (IBAction)textViewLowercaseWord:(id)sender;
- (IBAction)textViewCapitalizeWord:(id)sender;

- (IBAction) goToLineOK:(id)sender;
- (IBAction) showGoToLineSheet:(id)sender;
- (IBAction) cancelGoToLine:(id)sender;

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView;

- (NSInteger)getClosingBracketForBracket:(unichar)bracket AtLocation:(NSInteger) location;
- (NSInteger)getOpeningBracketForBracket:(unichar)bracket AtLocation:(NSInteger) location;

@end
