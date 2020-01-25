//
//  TextViewController.m
//  Tincta
//
//  Created by Mr. Fridge on 4/15/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "TCTextViewController.h"
#import "TCLineNumberView.h"
#import "TCSyntaxColoring.h"
#import "MainWindowController.h"
#import "TCSideBarController.h"
#import "TCSideBarItem.h"
#import "TCTextView.h"
#import "TCLayoutManager.h"
#import "TCEncodings.h"
#import "TCNotificationCreator.h"
#import "TCTextStorage.h"

#import "TCAMenuHelper.h"
#import "TCAMiscHelper.h"

@implementation TCTextViewController

@synthesize lineNumberView, syntaxColoring;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)awakeFromNib {
    notificationCreator = [TCNotificationCreator sharedManager];
    
    [self.textView setTextContainerInset:NSMakeSize(0, 5)];
    
    [self.textView setAllowsUndo:YES];
    [self.textView setRichText:NO];
    [self.textView setUsesFontPanel:NO];
    [self.textView setUsesFindPanel:NO];
    // [textView setUsesRuler:NO];
    
    [self.textView setEditable:YES];
    [self.textView setSelectable:YES];
    
    [self.textView setAutomaticLinkDetectionEnabled:NO];
    [self.textView setAutomaticQuoteSubstitutionEnabled:NO];
    [self.textView setAutomaticTextReplacementEnabled:NO];
    [self.textView setAutomaticDashSubstitutionEnabled:NO];
    [self.textView setAutomaticDataDetectionEnabled:NO];
        
    //user preferences changable
    [self.textView setAutomaticSpellingCorrectionEnabled:NO];
    
    [self.textView setImportsGraphics:NO];
    [self.textView setAllowsImageEditing:NO];     
    //[textView turnOffKerning:self];
    //[[textView layoutManager] setTypesetterBehavior:NSTypesetterBehavior_10_2_WithCompatibility];
    [[self.textView layoutManager] setShowsInvisibleCharacters:NO]; 
    
    syntaxColoring = [[TCSyntaxColoring alloc] initWithTextView:self.textView];
    NSMenu* syntaxDefMenu = [TCAMenuHelper syntaxDefinitionsMenu];
    for (NSMenuItem* item in [syntaxDefMenu itemArray]) {
        [item setTarget:self];
    }
    [self.textMenu setSubmenu:syntaxDefMenu forItem:self.syntaxColorMenuItem];
    [self.syntaxColorToolbarPopup setMenu:syntaxDefMenu];
        

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidScroll:)name:NSViewBoundsDidChangeNotification object:  [self.scrollView contentView]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidResize:)name:NSViewFrameDidChangeNotification object:self.scrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:)name:@"TCPreferencesDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChangeWrapping:)name:@"TCPreferencesDidChangeWrapping" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textStorageDidChangeText:)name: @"TCTextStorageDidChangeText" object:nil];

    
    encodingsController = [[TCEncodings alloc] init];
    encodingsController.target = self;
    NSMenu* encMenuConvert = [encodingsController encodingsMenuWithAction:@selector(menuConvertEncodingChange:)];
    NSMenu* encMenuReinterpret = [encodingsController encodingsMenuWithAction:@selector(menuReinterpredEncodingChange:)];
    
    [self.textMenu setSubmenu:encMenuConvert forItem:self.convertEncodingsMenuItem];
    [self.textMenu setSubmenu:encMenuReinterpret forItem:self.reinterpretEncodingsMenuItem];
    
    [[self.textView layoutManager] setDelegate:self];
}


#pragma mark -
#pragma mark text view methods

- (TCTextStorage*)textStorage {
    return (TCTextStorage*)[self.textView textStorage];
}

- (void)setTextStorage:(TCTextStorage *)newTextStorage {
    //[[self.textView layoutManager] replaceTextStorage:newTextStorage];
    [self setTextViewString:newTextStorage.string];
    [self.textView setFont:[TCADefaultsHelper getEditorFont]];
}


- (void)setTextViewString:(NSString*)aString {
    [(TCTextStorage*)[self.textView textStorage] setIsTCNotificationEnabled:NO];
    if (aString == nil) {
        [self.textView setString:@""];
    } else {
        [self.textView setString:aString];
    }
    [(TCTextStorage*)[self.textView textStorage] setIsTCNotificationEnabled:YES];
}

- (void)setTextViewStringWithUndo:(NSString*)aString {
    [self.textView setStringWithUndo:aString];
}

- (NSString*)textViewString {
    return [self.textView string];
}

- (void)scrollTextViewToPoint:(NSPoint)aPoint {
    NSPoint scrollPoint = aPoint;
        CGFloat maxPoint = [[self.scrollView documentView] frame].size.height - [self.scrollView visibleRect].size.height;
        if (scrollPoint.y > maxPoint) {
            scrollPoint.y = maxPoint;
        }
        [[self.scrollView contentView] scrollToPoint: scrollPoint];
        [self.scrollView reflectScrolledClipView: [self.scrollView contentView]];
}

- (NSPoint)textViewScrollPoint {
    return [[self.scrollView contentView] visibleRect].origin;//[scrollView documentVisibleRect].origin; 
}


- (void)setSelectedTextViewRanges:(NSArray *)ranges {   
    [self.textView setSelectedRanges:ranges];
}

- (NSArray *)selectedTextViewRanges {
    return [self.textView selectedRanges];
}

- (void)makeTextViewFirstResponder {
    [self.window makeFirstResponder: self.textView];
}


- (void)setSyntaxDefinitionByFileExtension:(NSString *)fileExtension {
    if (fileExtension == nil) {
        [syntaxColoring setSyntaxDefinitionByFileExtension: @""];
        
    } else {
        [syntaxColoring setSyntaxDefinitionByFileExtension:fileExtension];
    }
    selectedSideBarItem.syntaxColorName = syntaxColoring.syntaxDefinition;
    for (NSMenuItem* it in [[self.syntaxColorMenuItem submenu] itemArray]) {
        if ([[it title] isEqualToString:selectedSideBarItem.syntaxColorName]) {
            [it setState:NSOnState];
        } else {
            [it setState:NSOffState];
        }
    }
    [syntaxColoring colorDocument];
}



#pragma mark -
#pragma mark encoding methods

- (IBAction)menuReinterpredEncodingChange:(id)sender {
    NSInteger tag = [sender tag];
    NSStringEncoding newEncoding = CFStringConvertEncodingToNSStringEncoding((CFStringEncoding)tag);
    NSString* encodingName = [NSString localizedNameOfStringEncoding:newEncoding];
    
    if (selectedSideBarItem.isModified || selectedSideBarItem.filePath == nil) {
        NSInteger returnCode = NSRunAlertPanel(@"Better safe than sorry",  @"Your file has unsaved changes. If you reload it all changes will be lost.", @"Cancel", @"Reload anyway", nil);
        if (returnCode == NSAlertDefaultReturn) {
            return;
        }
    }
    NSData* theData = [NSData dataWithContentsOfFile:selectedSideBarItem.filePath];
    NSString* newString = nil;
    if (theData != nil) {
        newString = [[NSString alloc] initWithData:theData encoding:newEncoding];
    }
    //    NSData* theData = [theString dataUsingEncoding:selectedSideBarItem.encoding];
    if (newString == nil) {
        NSInteger returnCode = NSRunAlertPanel(@"Reinterpretation failed",@"Reinterpreting this text with %@ encoding failed because it only contains characters that have no counterparts in %@", @"OK", nil, nil, encodingName, encodingName);
        if (returnCode == NSAlertDefaultReturn) {
            return;
        }
    }
    selectedSideBarItem.isModified = YES;
    [self setTextEncodingWithUndo:newEncoding andString:newString];
    [self invalidateAllLineNumbers];
        
    //[self updateStatusText];
}

- (IBAction)menuConvertEncodingChange:(id)sender {
    NSInteger tag = [sender tag];

    NSStringEncoding newEncoding = CFStringConvertEncodingToNSStringEncoding((CFStringEncoding)tag);
    NSString* theString = [self textViewString];
    
    BOOL canConvertWithoutLoss = [theString canBeConvertedToEncoding:newEncoding];
    NSString* encodingName = [NSString localizedNameOfStringEncoding:newEncoding];
    if (!canConvertWithoutLoss) {
        NSRunAlertPanel(@"Will lose data", @"Converting this text to %@ encoding will probably lose data because it contains characters that have no counterparts in %@", @"Cancel", @"Convert anyway", nil, encodingName, encodingName);
            return;
    }
    
    NSData* theData = [theString dataUsingEncoding:newEncoding];
    NSString* newString = [[NSString alloc] initWithData:theData encoding:newEncoding];
    if (newString == nil) {
        NSRunAlertPanel(@"Conversion failed", @"Converting this text with %@ encoding failed because it only contains characters that have no counterparts in %@", @"OK", nil, nil, encodingName, encodingName);
            return;
    }
    selectedSideBarItem.isModified = YES;
    selectedSideBarItem.isDirty = YES;

    [self setTextEncodingWithUndo:newEncoding andString:newString];
    [self invalidateAllLineNumbers];
    //[self updateStatusText];
}

- (void)setTextEncodingWithUndo:(NSStringEncoding)newEnc andString:(NSString*)aString {
    
    NSString *currentString = [NSString stringWithString:[self.textView string]];
    NSStringEncoding currentEncoding = selectedSideBarItem.encoding;
    NSUndoManager* undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] setTextEncodingWithUndo:currentEncoding andString:currentString];
    [undoManager setActionName:@"Change Encoding"];
    [self.textView setString:aString];

    selectedSideBarItem.encoding = newEnc;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"TCShallUpdateStatusBar" object:self];
}



#pragma mark -
#pragma mark menu actions

- (void)goToLine:(NSInteger)aLine {
    TCTextStorage* ts = (TCTextStorage*)[self.textView textStorage];
    NSRange lineRange = [ts lineRangeOfLine:aLine];
    NSRect boundingRect =  [[self.textView layoutManager] boundingRectForGlyphRange:lineRange inTextContainer:[self.textView textContainer]];
    NSPoint scrollPoint = NSMakePoint(0, boundingRect.origin.y); 
    [self scrollTextViewToPoint:scrollPoint];
}

- (NSInteger)selectedLine {
    NSArray* selRanges = [self selectedTextViewRanges];
    NSRange lastRange = [[selRanges lastObject] rangeValue];
    NSInteger selectedLine = [(TCTextStorage*)[self.textView textStorage] lineNumberForLocation:NSMaxRange(lastRange)];
    return selectedLine;
}

- (NSInteger)selectedCharLocationInLine:(NSInteger)aLine {
    NSArray* selRanges = [self selectedTextViewRanges];
    NSRange lastSelRange = [[selRanges lastObject] rangeValue];
    NSInteger cursorPos = NSMaxRange(lastSelRange);
    NSRange lineRange = [(TCTextStorage*)[self.textView textStorage] lineRangeOfLine:aLine];
    return cursorPos- lineRange.location;
}


- (IBAction)menuSyntaxDefinitionChange:(id)sender {
    for (NSMenuItem* it in [[self.syntaxColorMenuItem submenu] itemArray]) {
        [it setState:NSOffState];
    }
    
    NSMenuItem* item = (NSMenuItem*)sender;
    [item setState:NSOnState];
    
    [self.syntaxColorToolbarPopup selectItem:item];
    
    [syntaxColoring setSyntaxDefinitionByName:[item title]];
    selectedSideBarItem.syntaxColorName = syntaxColoring.syntaxDefinition;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCShallUpdateStatusBar" object:self];
    [syntaxColoring colorDocument];
}

- (IBAction)print:(id)sender {
    //TODO: should not set file as modified
    //TODO: NSParagraphstyle and so on should be set
    //TODO: some DefaultColors, Font, FontSize and so on would be nice (in case user has strange color preferences)
    
    // create new view just for printing
    TCTextView *printView = [[TCTextView alloc] initWithFrame:[[self printInfo] imageablePageBounds]];
    [[printView layoutManager] replaceTextStorage:[[TCTextStorage alloc] init]];
    [printView setString:self.textView.string];
    TCSyntaxColoring* printColoring = [[TCSyntaxColoring alloc] initWithTextView:printView];
    [printColoring setSyntaxDefinitionByName:selectedSideBarItem.syntaxColorName];
    [printView setFont:[TCADefaultsHelper getEditorFont]];

    [printView setRichText:NO];
    [printView setUsesFontPanel:NO];
    [printView setUsesFindPanel:NO];
    [printView setBackgroundColor:[NSColor whiteColor]];
    
    // [textView setUsesRuler:NO];
    [printView setAutomaticLinkDetectionEnabled:NO];
    [printView setAutomaticQuoteSubstitutionEnabled:NO];
    [printView setAutomaticTextReplacementEnabled:NO];
    [printView setAutomaticDashSubstitutionEnabled:NO];
    [printView setAutomaticDataDetectionEnabled:NO];
    //user preferences changable
    [printView setAutomaticSpellingCorrectionEnabled:NO];
    [printView setImportsGraphics:NO];
    [printView setAllowsImageEditing:NO];     
    [printView turnOffKerning:self];
    //[[printView layoutManager] setTypesetterBehavior:NSTypesetterBehavior_10_2_WithCompatibility];
    
    [printColoring colorDocument];
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:printView printInfo:[self printInfo]];

    [op setShowsPrintPanel:YES];
    [op runOperationModalForWindow:self.window delegate:self didRunSelector:NULL contextInfo:nil];
}

- (NSPrintInfo* )printInfo {
    // set printing properties
    NSPrintInfo* pInfo = [NSPrintInfo sharedPrintInfo];
    [pInfo setHorizontalPagination:NSFitPagination];
    [pInfo setHorizontallyCentered:NO];
    [pInfo setVerticallyCentered:NO];
    [pInfo setLeftMargin:72.0];
    [pInfo setRightMargin:72.0];
    [pInfo setTopMargin:72.0];
    [pInfo setBottomMargin:90.0];
    return pInfo;
}


- (IBAction)setShowInvisibles:(id)sender {
    
    TCLayoutManager* layoutManager = (TCLayoutManager*)[self.textView layoutManager];
    BOOL showInvisibles = !layoutManager.isShowsInvisibles;
    layoutManager.isShowsInvisibles = showInvisibles;
    if (showInvisibles) {
        [self.showsInvisblesMenuItem setTitle:@"Hide Invisible Characters"];
    } else {
        [self.showsInvisblesMenuItem setTitle:@"Show Invisible Characters"];
    }
    
    [self.textView setNeedsDisplay:YES];
}



- (IBAction) showGoToLineSheet:(id)sender {
    [NSApp beginSheet:self.goToLinePanel modalForWindow:self.window modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction) goToLineOK:(id)sender {
    NSInteger line = [self.goToLineTextField integerValue];
    [self cancelGoToLine:self];
    [self goToLine:line];
}

- (IBAction) cancelGoToLine:(id)sender {
    [self.goToLinePanel orderOut:self];
    [NSApp endSheet:self.goToLinePanel];
}



//windows: \r\n
//macos 8: \r
//unix: \n
- (IBAction)changeLineEndingsToWindows:(id)sender {
    NSString* currentText = [self.textView string];
    NSString* newText = [currentText stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    //now windows are \n classic mac are still \r
    newText = [newText stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    //now all are \n
    newText = [newText stringByReplacingOccurrencesOfString:@"\n" withString:@"\r\n"];
    [self setTextViewStringWithUndo:newText];
}

- (IBAction)changeLineEndingsToMac:(id)sender {
    NSString* currentText = [self.textView string];
    NSString* newText = [currentText stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    //now windows are \n classic mac are still \r
    newText = [newText stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    [self setTextViewStringWithUndo:newText];
}

- (IBAction)changeTabsToSpaces:(id)sender {
    //TODO: get the right number of spaces
    NSString* newText = [[self.textView string]stringByReplacingOccurrencesOfString:@"\t" withString:[self getTablengthWithSpaces]];
    [self setTextViewStringWithUndo:newText];
}

- (IBAction)changeSpacesToTabs:(id)sender {
    //TODO: get the right number of spaces
    NSString* newText = [[self.textView string]stringByReplacingOccurrencesOfString:[self getTablengthWithSpaces] withString:@"\t"];
    [self setTextViewStringWithUndo:newText];
}


#pragma mark -
#pragma mark helpers

- (void)setLineWrapping:(BOOL)doWrap {
     [self scrollTextViewToPoint:NSZeroPoint];
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    [self.scrollView setHasVerticalScroller:YES];
    [self.scrollView setAutohidesScrollers:YES];
    [self.textView setHorizontallyResizable:YES];
    if (!doWrap) {
        [[self.textView textContainer] setWidthTracksTextView:NO];
        [[self.textView textContainer] setContainerSize: NSMakeSize(FLT_MAX, FLT_MAX)];
        [self.scrollView setHasHorizontalScroller:YES];

    } else {
        BOOL modfiedBackup = selectedSideBarItem.isModified;
        BOOL dirtyBackup = selectedSideBarItem.isDirty;
        
        NSString* syntaxBackup = [syntaxColoring syntaxDefinition];
        [syntaxColoring setSyntaxDefinitionByName:nil];
        NSString* textBackup = [NSString stringWithString: [self.textView string]];
        if ([[self.textView string] length] > 10) {
            [self setTextViewString:@"short string"];
            
        }
        //////
        
        [[self.textView textContainer] setWidthTracksTextView:YES];

        NSSize newSize = NSMakeSize([self.scrollView documentVisibleRect].size.width, FLT_MAX);
        [[self.textView textContainer] setContainerSize: newSize];
        [self.scrollView setHasHorizontalScroller:NO];

        //////
        [self setTextViewString: textBackup];
        [syntaxColoring setSyntaxDefinitionByName:syntaxBackup];
        [syntaxColoring colorDocument];
        selectedSideBarItem.isDirty = dirtyBackup;
        selectedSideBarItem.isModified = modfiedBackup;
    }
    
    [self.textView setNeedsDisplay:YES];
    [self.scrollView setNeedsDisplay:YES];
    
    lineNumberView.isWrappingDisabled = !doWrap;
    [self invalidateAllLineNumbers];
}


- (void)invalidateAllLineNumbers {
    //lineNumberView.lineWraps = nil;
    [lineNumberView resetLineNumbers];
    [lineNumberView setNeedsDisplayCapsule];
}


- (NSInteger)numberOfLines {
    //lineNumberView.numberOfLines begins with 0 so we add 1
    return lineNumberView.numberOfLines;
}


- (NSString*)lineEndingType {
    //do we need this?
    //NSString* currentText = [self.textView string];
    return nil;
}


- (NSString*)getTablengthWithSpaces {
    NSInteger tabBlankLength = [TCADefaultsHelper getTabWidth];
    NSMutableString *tempTabString = [NSMutableString stringWithCapacity:tabBlankLength];
    for (int i = 0; i < tabBlankLength; i++) {
        [tempTabString appendString:@" "];
    }
    return tempTabString;
}


- (void)clearUndoManager {
    [[self.window undoManager] removeAllActions];
    [[self.textView undoManager] removeAllActions];
}

- (NSUndoManager*)undoManager {
    return [self.textView undoManager];
}



#pragma mark -
#pragma mark delegates and notifications

- (void)layoutManager:(NSLayoutManager *)aLayoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)aTextContainer atEnd:(BOOL)flag {
    //scroll when done loading text
    if (needsScrolling && selectedSideBarItem != nil) {
        [self scrollTextViewToPoint:selectedSideBarItem.scrollPoint];
        needsScrolling = NO;
    }
}

- (NSRange)textView:(NSTextView *)aTextView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange {

    return newSelectedCharRange;
}

- (NSArray *)textView:(NSTextView *)aTextView willChangeSelectionFromCharacterRanges:(NSArray *)oldSelectedCharRanges toCharacterRanges:(NSArray *)newSelectedCharRanges {
        return newSelectedCharRanges;
}

- (void)textStorageDidChangeText:(NSNotification *)aNotification {
    
    if ([aNotification object][0] != [self.textView textStorage]) {
        return;
    }

}


- (void)changeSelectedSideBarItem:(TCSideBarItem*)theItem {

    selectedSideBarItem = theItem;
    if (selectedSideBarItem.syntaxColorName == nil) {
        NSString* fileExtension = [selectedSideBarItem.filePath pathExtension];
        [syntaxColoring setSyntaxDefinitionByFileExtension: fileExtension];
        selectedSideBarItem.syntaxColorName = syntaxColoring.syntaxDefinition;
    } else {
        [syntaxColoring setSyntaxDefinitionByName:selectedSideBarItem.syntaxColorName];
    }

    [self updateSyntaxDefinitionMenu];
    needsScrolling = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(invalidateAllLineNumbers)userInfo:nil repeats:NO];
    [syntaxColoring colorDocument];
}


- (void)updateSyntaxDefinitionMenu {
    for (NSMenuItem* it in [[self.syntaxColorMenuItem submenu] itemArray]) {
        if ([[it title] isEqualToString:selectedSideBarItem.syntaxColorName]) {
            [it setState:NSOnState];
            [self.syntaxColorToolbarPopup selectItem:it];
        } else {
            [it setState:NSOffState];
        }
    }
}


- (IBAction)menuSyntaxDefinitionChanged:(id)sender {
    for (NSMenuItem* it in [[self.syntaxColorMenuItem submenu] itemArray]) {
        [it setState:NSOffState];
    }
    
    NSMenuItem* item = (NSMenuItem*)sender;
    [item setState:NSOnState];
    
    [self.syntaxColorToolbarPopup selectItem:item];
    
    [self.syntaxColoring setSyntaxDefinitionByName:item.title];
    selectedSideBarItem.syntaxColorName = self.syntaxColoring.syntaxDefinition;
    
    [self.syntaxColoring colorDocument];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCShallUpdateStatusBar" object:self];
    
}

- (IBAction)toggleBlockComment:(id)sender {
    NSRange selRange = self.textView.selectedRange;
    NSString* textString = self.textView.string;
    NSInteger lineStart = [textString lineRangeForRange:selRange].location;
    NSString* commentToken = [self.syntaxColoring getSingleLineCommentToken];
    NSArray* multilineTokens = [self.syntaxColoring getMultiLineCommentToken];

    if (commentToken) {
        NSRange commentRange = NSMakeRange(lineStart, commentToken.length);
        if ([TCAMiscHelper isRange:commentRange inBoundOfString:textString]) {
            NSDictionary* parameters = @{@"selectionRange": NSStringFromRange(selRange),
                                         @"token": commentToken};
            if (![[textString substringWithRange:commentRange] isEqualToString:commentToken]) {
                [self.textView commentStringWithParameters:parameters];
            } else {
                [self.textView uncommentStringWithParameters:parameters];
            }
        }
    } else if (multilineTokens) {
        NSRange commentRange = NSMakeRange(selRange.location, [(NSString*)multilineTokens[0] length]);
        if ([TCAMiscHelper isRange:commentRange inBoundOfString:textString]) {
            NSDictionary* parameters = @{@"selectionRange": NSStringFromRange(selRange),
                                         @"multilineTokens": multilineTokens};
            if (![[textString substringWithRange:commentRange] isEqualToString:multilineTokens[0]]) {
                [self.textView commentStringWithParameters:parameters];
            } else {
                [self.textView uncommentStringWithParameters:parameters];
            }
        }
    }




}


- (void)textViewDidChangeSelection:(NSNotification *)aNotification {
    [self.textView colorCurrentLine];
    
    //short highlighting of opening braces when cursor is over closing brace
    NSRange selRange = [self.textView selectedRange];
    NSInteger cursorLocation = selRange.location; //was newCursorLocation

    NSString *textViewString = [self.textView string];

    if (cursorLocation == [textViewString length]) {
        return;
    }
    
    unichar charToCheck = [textViewString characterAtIndex:cursorLocation];
    //NSInteger charToCheckLocation = cursorLocation;
    NSInteger loc;
    if (charToCheck == ')' || charToCheck == ']' || charToCheck == '}' || charToCheck == '>') {
        loc = [self getOpeningBracketForBracket:charToCheck AtLocation:cursorLocation];
        if (loc != NSNotFound) {
            NSMutableArray* rangesToMark = [NSMutableArray arrayWithObjects:[NSValue valueWithRange:NSMakeRange(cursorLocation, 1)],[NSValue valueWithRange:NSMakeRange(loc, 1)], nil];
            [self.textView markRanges:rangesToMark];
            return;
        }
        
    } else if (charToCheck == '(' || charToCheck == '[' || charToCheck == '{' || charToCheck == '<') {
        loc = [self getClosingBracketForBracket:charToCheck AtLocation:cursorLocation];
        if (loc != NSNotFound) {
            NSMutableArray* rangesToMark = [NSMutableArray arrayWithObjects:[NSValue valueWithRange:NSMakeRange(cursorLocation, 1)],[NSValue valueWithRange:NSMakeRange(loc, 1)], nil];
            [self.textView markRanges:rangesToMark];
            return;
        }
    }
}



- (void)textViewDidScroll:(NSNotification *)aNotification {

}

- (void)textViewDidResize:(NSNotification *)aNotification {
}


//textView delegate
- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView{
    return selectedSideBarItem.undoManager;
}

- (void)preferencesDidChange:(NSNotification *)aNotification {
    if (![TCADefaultsHelper getShowLineNumbers]) {
        [self.scrollView setHasVerticalRuler:NO];
        self.lineNumberView = nil;
    } else {
        if (self.lineNumberView == nil) {
            lineNumberView = [[TCLineNumberView alloc] initWithScrollView:self.scrollView];            
            [self.scrollView setVerticalRulerView:lineNumberView];
            [self.scrollView setHasHorizontalRuler:NO];
            [self.scrollView setHasVerticalRuler:YES];
            [self.scrollView setRulersVisible:YES];
        } else {
            [self invalidateAllLineNumbers];
        }
    }
    [self.textView setFont:[TCADefaultsHelper getEditorFont]];
    [self.textView setTabWidthForCurrentFont];

    if ([TCADefaultsHelper getShowPageGuide]) {
        [self.textView setPageGuideColumn:[TCADefaultsHelper getPageGuideColumn]];
    }
    [self.textView setTabString];
    [self.textView toggleIndentNewLine:[TCADefaultsHelper getIndentNewLine]];
    [self.textView toggleAutocompleteBrackets:[TCADefaultsHelper getAutoCompleteBrackets]];
    [self.textView toggleAutocompleteQuotations:[TCADefaultsHelper getAutoCompleteQuotations]];

    [self.textView setInsertionPointColor:[TCADefaultsHelper getTextColor]];
    [self.textView setBackgroundColor:[TCADefaultsHelper getBackgroundColor]];
    [self.textView setSelectedTextColor:[TCADefaultsHelper getSelectionColor]];
    [self.textView setInvisiblesColor:[TCADefaultsHelper getInvisiblesColor]];
    
    [self.textView toggleColoringCurrentLine:[TCADefaultsHelper getHighlightCurrentLine]];
    
    [self.textView setCurrentLineColor:[TCADefaultsHelper getCurrentLineColor]];

    [syntaxColoring initSyntaxColors];
    [syntaxColoring colorDocument];
    
    [lineNumberView updateColors];
}

- (void)preferencesDidChangeWrapping:(NSNotification *)aNotification {
    [self setLineWrapping:![TCADefaultsHelper getNotWrapLines]];
}

- (IBAction)textViewUppercaseWord:(id)sender {
    [self.textView uppercaseWord:sender];
}

- (IBAction)toggleCaseForSelection:(id)sender {
    NSRange selRange = self.textView.selectedRange;
    NSString* textString = self.textView.string;
    if (![TCAMiscHelper isRange:selRange inBoundOfString:textString]) {
        [self.textView lowercaseWord:sender];
        return;
    }
    NSString* selectedString = [textString substringWithRange:selRange];
    if (selectedString.length < 1) {
           [self.textView lowercaseWord:sender];
           return;
       }
    BOOL isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[selectedString characterAtIndex:0]];
    if (isUppercase) {
        [self.textView lowercaseWord:sender];
    } else {
        [self.textView uppercaseWord:sender];
    }

}

- (IBAction)textViewLowercaseWord:(id)sender {
    [self.textView lowercaseWord:sender];
}

- (IBAction)textViewCapitalizeWord:(id)sender {
    [self.textView capitalizeWord:sender];
}


- (NSInteger)getClosingBracketForBracket:(unichar)bracket AtLocation:(NSInteger)location {
    unichar complement = ' ';
    unichar charToCheck;
    if (bracket == '(') {
        complement = ')';
    } else if (bracket == '[') {
        complement = ']';
    } else if (bracket == '{') {
        complement = '}';
    } else if (bracket == '<') {
        complement = '>';
    }
    NSString *textViewString = [self.textView string]; 
    NSInteger skipBrace = 0;
    location++;
    while (location < [textViewString length]) {
        charToCheck = [textViewString characterAtIndex:location];
        if (complement == charToCheck) {
            if (skipBrace == 0) {
                return location;
            } else {
                skipBrace--;
            }
        } else if (charToCheck == bracket) {
            skipBrace++;
        }
        location++;
    }
    return NSNotFound;
}

- (NSInteger)getOpeningBracketForBracket:(unichar)bracket AtLocation:(NSInteger)location {
    unichar complement = ' ';
    unichar charToCheck;
    if (bracket == ')') {
        complement = '(';
    } else if (bracket == ']') {
        complement = '[';
    } else if (bracket == '}') {
        complement = '{';
    } else if (bracket == '>') {
        complement = '<';
    }
    NSString *textViewString = [self.textView string]; 
    NSInteger skipBrace = 0;
    while (location--) {
        charToCheck = [textViewString characterAtIndex:location];
        if (complement == charToCheck) {
            if (skipBrace == 0) {
                return location;
            } else {
                skipBrace--;
            }
        } else if (charToCheck == bracket) {
            skipBrace++;
        }
    }
    return NSNotFound;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
