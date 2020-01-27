//
//  SearchController.m
//  Tincta
//
//  Created by Mr. Fridge on 5/19/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//


#import "TCASearchController.h"
#import "TCTextViewController.h"
#import "TCLineNumberView.h"
#import "TCNotificationCreator.h"
#import "MainWindowController.h"
#import "TCSideBarItem.h"
#import "TCAMiscHelper.h"

@implementation TCASearchController


- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        selectionColor = [TCADefaultsHelper getSelectionColor];
    }
    
    return self;
}



- (IBAction)showSearchView:(id)sender {
    if (self.isActive) {
        [self.window makeFirstResponder:self.searchBox];
    } else {
        [self.window setMinSize:NSMakeSize(800, 450)];
        if (self.window.frame.size.width < 800) {
            NSRect newSize = self.window.frame;
            newSize.size.width = 800;
            [self.window setFrame:newSize display:YES animate:YES];
        }

        self.isActive = YES;
        [self.rightSplitView addSubview:self.searchView];
        NSRect scrollR = [self.scrollView frame];
        NSRect searchR = [self.searchView frame];
        NSRect splitR = [self.rightSplitView frame];
        [self.searchView setFrame:NSMakeRect(0, splitR.size.height - searchR.size.height, splitR.size.width, searchR.size.height)];
        [self.scrollView setFrame:NSMakeRect(0, 2, scrollR.size.width, [self.scrollView frame].size.height - searchR.size.height)];
        [self.window makeFirstResponder:self.searchBox];
    }
}


- (IBAction)hideSearchView:(id)sender {
    if (self.isActive) {
        [self.window setMinSize:NSMakeSize(600, 450)];
        self.isActive = NO;
        NSRect scrollR = [self.scrollView frame];
        NSRect searchR = [self.searchView frame];
        NSRect splitR = [self.rightSplitView frame];
        
        [[self.textView layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, [[self.textView string] length])];
        
        [self.scrollView setFrame:NSMakeRect(0, 2, scrollR.size.width, [self.scrollView frame].size.height + searchR.size.height)];
        [self.searchView setFrame:NSMakeRect(0, splitR.size.height, splitR.size.width, searchR.size.height)];
        [self.searchView removeFromSuperview];
        if (foundRange.location != NSNotFound) {
            [self.textView setSelectedRange:foundRange];
        }
        [notificationCreator fadeNotification];
        [self resetNumberOfMatchesInSideBar];
        [self.window makeFirstResponder:self.textView];
        
    }
}

- (NSString*) unescapeString: (NSString*) aString {
    
    NSString* escapedString = aString;
    //returnString = [aString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
    
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\\\n" withString:@"\\n"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\\\r" withString:@"\\r"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\\\t" withString:@"\\t"];
    
    return escapedString;
}

- (NSString* )escapeString: (NSString* )aString {
    NSString* escapedString = aString;

    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"{" withString:@"\\{"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"}" withString:@"\\}"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"|" withString:@"\\|"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"*" withString:@"\\*"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"$" withString:@"\\$"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"^" withString:@"\\^"];

    return escapedString;
}


- (IBAction) search: (id) sender {
    
    if ((sender == self.searchBox) && [[self.searchBox stringValue] isEqualToString: lastSearchBoxValue]) {
        return;
    }
    lastSearchBoxValue = [self.searchBox stringValue];
    notificationCreator = [TCNotificationCreator sharedManager];
    
	BOOL isCaseSensitive = [self.caseCheckBox state] == NSOnState;
    NSStringCompareOptions option = NSCaseInsensitiveSearch;
    if (isCaseSensitive) {
        option = NSLiteralSearch;
    }
	NSString* searchTerm =  [self.searchBox stringValue];
    searchTerm = [self unescapeString:searchTerm];
    
    NSString* text = [self.textView string];
    
	if (searchTerm != nil && [searchTerm length] > 0) {
        NSInteger numberOfFound = [self markAllOccurrences];
        
        foundRange = [text rangeOfString:searchTerm options:option range:NSMakeRange([self.textView selectedRange].location, [text length] - [self.textView selectedRange].location)];
        NSString* msg = @"Not Found";
        if (numberOfFound > 0) {
            msg = [NSString stringWithFormat:@"%ld Found", numberOfFound];
        }
        //if search term is above cursor you have to wrap around
        if (foundRange.location != NSNotFound) {
            NSRect boundingRect =  [[self.textView layoutManager] boundingRectForGlyphRange:foundRange inTextContainer:[self.textView textContainer]];
            NSPoint scrollPoint = NSMakePoint(0, boundingRect.origin.y);        
            [self scrollToPoint:scrollPoint];
            
            
        } else {
            [self findNext:self];
        }
        [notificationCreator showNotificationWithMessage:msg andImage:[NSImage imageNamed:@"search_notification"] centredInFrame:[self absoluteTextViewFrame]];
        [self.textView showFindIndicatorForRange:foundRange];
	} else {
        // do nothing
	}
}

- (IBAction) searchForSelection: (id) sender {
    [self showSearchView:self];
    if(![TCAMiscHelper isRange:[self.textView selectedRange] inBoundOfString:[self.textView string]]) {
        return;
    }
    NSString* selectedString = [[self.textView string] substringWithRange:[self.textView selectedRange]];
    [self.searchBox setStringValue:selectedString];
    [self.searchBox selectText:self];
    [self.textView setSelectedRange:NSMakeRange([self.textView selectedRange].location, 0)];
    [self search: self];
}

- (IBAction) jumpToNextPreviousBySegmentedControl: (id) sender {
    if ([self.prevNextSegmentedControl selectedSegment] == 0) {
        [self findPrevious:self];
    } else {
        [self findNext:self];
    }
}


- (IBAction) findNext: (id) sender {
    [self markAllOccurrences];
    notificationCreator = [TCNotificationCreator sharedManager];
    BOOL isCaseSensitive = [self.caseCheckBox state] == NSOnState;

    NSRegularExpressionOptions option = 0;
    if (!isCaseSensitive) {
        option |= NSRegularExpressionCaseInsensitive;
    }

    NSError* error = NULL;
	NSString* searchTerm =  [self.searchBox stringValue];

    searchTerm = [self unescapeString:searchTerm];
    NSString* text = [self.textView string];

    if ([self.regexCheckBox state] == NSOffState) {
        searchTerm = [self escapeString:searchTerm];
    }
    
	if (searchTerm != nil && [searchTerm length] > 0) {
        NSRegularExpression *searchExp = [NSRegularExpression regularExpressionWithPattern:searchTerm options:option error:&error];
        if (error) {
            NSLog(@"error in creating regex!!!");
            return;
        }
        NSRange searchRange;
        if (foundRange.location == NSNotFound || foundRange.location >= [text length]) {
            searchRange = NSMakeRange(0, [text length]);
        } else {
            searchRange = NSMakeRange(NSMaxRange(foundRange), [text length] - NSMaxRange(foundRange));
        }
        foundRange = [searchExp rangeOfFirstMatchInString:self.textView.string options:0 range:searchRange];
        if (foundRange.location == NSNotFound) {
            //not found
            if (searchRange.location != 0) {
                [self findNext:self];
                [notificationCreator showNotificationWithMessage:@"Wrap around" andImage:[NSImage imageNamed:@"wrap_notification"]  centredInFrame:[self absoluteTextViewFrame]];
            } else {
                [notificationCreator showNotificationWithMessage:@"Not Found" andImage:[NSImage imageNamed:@"search_notification"]  centredInFrame:[self absoluteTextViewFrame]];
            }
            return;
        }
        NSRect boundingRect =  [[self.textView layoutManager] boundingRectForGlyphRange:foundRange inTextContainer:[self.textView textContainer]];
        NSPoint scrollPoint = NSMakePoint(0, boundingRect.origin.y);        
        [self scrollToPoint:scrollPoint];
        [self.textView showFindIndicatorForRange:foundRange];
	}
}

- (IBAction) findPrevious: (id) sender {
    [self markAllOccurrences];
    notificationCreator = [TCNotificationCreator sharedManager];
    BOOL isCaseSensitive = [self.caseCheckBox state] == NSOnState;

    NSRegularExpressionOptions option = 0;

    if (!isCaseSensitive) {
        option |= NSRegularExpressionCaseInsensitive;
    }

    NSString* searchTerm = [self.searchBox stringValue];
    if ([self.regexCheckBox state] == NSOffState) {
        searchTerm = [self escapeString:searchTerm];
    }
    NSString* text = [self.textView string];
	if (searchTerm != nil && [searchTerm length] > 0) {
        NSError* error = NULL;
        NSRange searchRange;
        if (foundRange.location == NSNotFound  || foundRange.location >= [text length]) {
            searchRange = NSMakeRange(0, [text length]);
        } else {
            searchRange = NSMakeRange(0, foundRange.location);
        }
        NSRegularExpression* searchExp = [NSRegularExpression regularExpressionWithPattern:searchTerm options:option error:&error];
        if (error) {
            NSLog(@"error in building regex");
            return;
        }
        NSArray* matches = [searchExp matchesInString:text options:0 range:searchRange];
        if ([matches count] == 0) {
            if (searchRange.length != [text length]) {
                foundRange.location = NSNotFound;
                [self findPrevious:self];

                [notificationCreator showNotificationWithMessage:@"Wrap around" andImage:[NSImage imageNamed:@"wrap_notification"]  centredInFrame:[self absoluteTextViewFrame]];
            } else {
                [notificationCreator showNotificationWithMessage:@"Not Found" andImage:[NSImage imageNamed:@"search_notification"]  centredInFrame:[self absoluteTextViewFrame]];
            }
            return;
        }
        if ([matches count] == 1) {
            foundRange = [[matches firstObject] range];
        } else {
            NSTextCheckingResult* match = matches[[matches count] -1];
            foundRange = match.range;
        }          NSRect boundingRect =  [[self.textView layoutManager] boundingRectForGlyphRange:foundRange inTextContainer:[self.textView textContainer]];
        NSPoint scrollPoint = NSMakePoint(0, boundingRect.origin.y);
        
        [self scrollToPoint: scrollPoint];
        
        [self.textView showFindIndicatorForRange:foundRange];        
	}
}

- (NSRect) absoluteTextViewFrame {
    NSRect textViewFrame = [self.scrollView frame];
    NSPoint absoluteTextOrigin = [self.scrollView convertPoint:textViewFrame.origin toView:nil];
    NSRect absoluteTextFrame = NSMakeRect(absoluteTextOrigin.x, absoluteTextOrigin.y, textViewFrame.size.width, textViewFrame.size.height);
    absoluteTextFrame = [self.window convertRectToScreen:absoluteTextFrame];
    return absoluteTextFrame;
}

- (IBAction) jumpToSelection: (id) sender {
    NSRect boundingRect =  [[self.textView layoutManager] boundingRectForGlyphRange:[self.textView selectedRange] inTextContainer:[self.textView textContainer]];
    NSPoint scrollPoint = NSMakePoint(0, boundingRect.origin.y);
    
    [self scrollToPoint: scrollPoint];    
}


- (IBAction) replaceAndFind: (id) sender {

    if (foundRange.location != NSNotFound && (NSMaxRange(foundRange) <= self.textView.string.length)) {
        BOOL isCaseSensitive = [self.caseCheckBox state] == NSOnState;
        NSStringCompareOptions option = NSCaseInsensitiveSearch;
        if (isCaseSensitive) {
            option = NSLiteralSearch;
        }
        NSString* searchTerm = [self.searchBox stringValue];
        searchTerm = [self unescapeString:searchTerm];
        
        NSString* replaceTerm = [self.replaceField stringValue];
        replaceTerm = [self unescapeString:replaceTerm];
        
        NSError* error = NULL;
        NSRegularExpression *searchExp = [NSRegularExpression regularExpressionWithPattern:searchTerm options:option error:&error];
        if (error) {
            NSLog(@"replace all > error in creating regex!!!");
            return;
        }
        
        NSMutableString* text = [NSMutableString stringWithString: self.textView.string];
        [searchExp replaceMatchesInString:text options:0 range:foundRange withTemplate:replaceTerm];
        [self setTextViewStringWithUndo:text];
        
        [self markAllOccurrences];
    }
    [self findNext:self];
}

- (IBAction) replaceAll: (id) sender {
    notificationCreator = [TCNotificationCreator sharedManager];
    
    BOOL isCaseSensitive = [self.caseCheckBox state] == NSOnState;
    NSStringCompareOptions option = NSCaseInsensitiveSearch;
    if (isCaseSensitive) {
        option = NSLiteralSearch;
    }
    NSMutableString* text = [NSMutableString stringWithString:[self.textView string]];
    
    NSString* searchTerm = [self.searchBox stringValue];
    searchTerm = [self unescapeString:searchTerm];
    
    NSString* replaceTerm = [self.replaceField stringValue];
    replaceTerm = [self unescapeString:replaceTerm];
    if ([self.regexCheckBox state] == NSOffState) {
        searchTerm = [self escapeString:searchTerm];
    }
    
    NSError* error = NULL;
    NSRegularExpression *searchExp = [NSRegularExpression regularExpressionWithPattern:searchTerm options:option error:&error];
    if (error) {
        NSLog(@"replace all > error in creating regex!!!");
        return;
    }
    
    NSInteger numberOfFound = [searchExp replaceMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:replaceTerm];
    
    [self setTextViewStringWithUndo:text];
    
    NSString* msg = @"Nothing replaced";
    if (numberOfFound > 0) {
        msg = [NSString stringWithFormat:@"%ld Replaced", numberOfFound];
    }
    [notificationCreator showNotificationWithMessage:msg andImage:[NSImage imageNamed:@"search_notification"]  centredInFrame:[self absoluteTextViewFrame]];
    
}


- (NSInteger) markAllOccurrences {
    NSInteger numberOfMatches = 0;
	BOOL isCaseSensitive = [self.caseCheckBox state] == NSOnState;
    NSRegularExpressionOptions option = 0;
    if (!isCaseSensitive) {
        option |= NSRegularExpressionCaseInsensitive;
    }
    NSDictionary* markAttributes = @{NSBackgroundColorAttributeName: selectionColor};
	NSString* searchTerm =  [self.searchBox stringValue];

    if ([self.regexCheckBox state] == NSOffState) {
        searchTerm = [self escapeString:searchTerm];
    }

    NSString* text = [self.textView string];
    if (searchTerm != nil && [searchTerm length] > 0) {
        NSError* error = NULL;
        NSRegularExpression* searchExp = [NSRegularExpression regularExpressionWithPattern:searchTerm options:option error:&error];
        if (error) {
            NSLog(@"error building regex to mark occurrences");
            return 0;
        } else {
            [[self.textView layoutManager] removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, [text length])];
            NSRange searchRange = NSMakeRange(0, [text  length]);
            [searchExp enumerateMatchesInString:text options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                [[self.textView layoutManager] setTemporaryAttributes:markAttributes forCharacterRange:result.range];
            }];
            numberOfMatches = [searchExp numberOfMatchesInString:text options:0 range:searchRange];
        }
    }
    TCSideBarController* sideBarController = [self.mainWindowController sidebarController];
    [sideBarController.selectedItem setNumberOfSearchResults:numberOfMatches];
    [sideBarController reload];
    return numberOfMatches;
}

- (void) scrollToPoint: (NSPoint) aPoint {
    NSPoint scrollPoint = aPoint;
    scrollPoint.x = -self.textViewController.lineNumberView.bounds.size.width;
    
    if (!NSPointInRect(scrollPoint, [self.textView visibleRect])) {
        
        CGFloat maxPoint = [[self.scrollView documentView] frame].size.height - [self.scrollView visibleRect].size.height;
        if (scrollPoint.y > maxPoint) {            
            scrollPoint.y = maxPoint;
        }
        
        [[self.scrollView contentView] scrollToPoint: scrollPoint];
        [self.scrollView reflectScrolledClipView: [self.scrollView contentView]];
    }
}

- (void) setTextViewStringWithUndo: (NSString*) aString {
    
    NSString *currentString = [NSString stringWithString:[self.textView string]];
    NSUndoManager* undoManager = [self.textView undoManager];
    [undoManager registerUndoWithTarget:self selector:@selector(setTextViewStringWithUndo:) object:currentString];
    [undoManager setActionName:@"Replace"];
    [self.textView setString:aString];
    if (self.mainWindowController != nil) {
        [self.mainWindowController textDidChange:nil];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    if (command == @selector(cancelOperation:)) {
        [self hideSearchView:self];
        return YES;
    }
    return NO;
}

- (void)clearSearchAndReplaceValues {
    self.searchBox.stringValue = @"";
    lastSearchBoxValue = @"";
    self.replaceField.stringValue = @"";
}

- (void)resetNumberOfMatchesInSideBar {
    TCSideBarController* sideBarController = self.mainWindowController.sidebarController;
    for (TCSideBarItem* item in sideBarController.items) {
        [item setNumberOfSearchResults:0];
    }
    [sideBarController reload];
}

@end
