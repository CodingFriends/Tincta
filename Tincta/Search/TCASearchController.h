//
//  SearchController.h
//  Tincta
//
//  Created by Mr. Fridge on 5/19/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <Foundation/Foundation.h>

@class TCNotificationCreator, MainWindowController;
@interface TCASearchController : NSObject {

    NSRange foundRange;
    TCNotificationCreator* notificationCreator;
    NSColor *selectionColor;

    NSString* lastSearchBoxValue; //only so search is not performed when clicking away from searchbox
}

@property (assign) IBOutlet NSView* searchView;
@property (assign) IBOutlet NSView* rightSplitView;
@property (assign) IBOutlet NSScrollView* scrollView;
@property (assign) IBOutlet NSTextView* textView;

@property (assign) IBOutlet NSTextField* replaceField;
@property (assign) IBOutlet NSSearchField* searchBox;
@property (assign) IBOutlet NSButton* caseCheckBox;
@property (assign) IBOutlet NSButton* regexCheckBox;
@property (assign) IBOutlet NSSegmentedControl* prevNextSegmentedControl;
@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet MainWindowController* mainWindowController;

@property (assign) BOOL isActive;


- (void) scollToPoint: (NSPoint) aPoint;
- (NSString* )unescapeString: (NSString* )aString;
- (NSString* )escapeString: (NSString* )aString;

- (IBAction)showSearchView:(id)sender;
- (IBAction)hideSearchView:(id)sender;

- (IBAction)findNext:(id)sender;
- (IBAction)findPrevious:(id)sender;
- (IBAction)jumpToNextPreviousBySegmentedControl:(id)sender;
- (IBAction)replaceAndFind:(id)sender;
- (IBAction)replaceAll:(id)sender;
- (IBAction)searchForSelection:(id)sender;
- (IBAction)jumpToSelection:(id)sender;
- (NSInteger)markAllOccurrences;

- (void)setTextViewStringWithUndo:(NSString* )aString;
- (NSRect)absoluteTextViewFrame;
- (BOOL)control:(NSControl* )control textView:(NSTextView* )textView doCommandBySelector:(SEL)command;
- (void)clearSearchAndReplaceValues;
- (void)resetNumberOfMatchesInSideBar;

@end
