//
//  TCPreferencesController.m
//  Tincta
//
//  Created by Julius on 28.04.11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "TCPreferencesController.h"
#import "TCAColorScheme.h"
#import "TCAApplicationSupportHelper.h"

@implementation TCPreferencesController


- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        _colorProfiles = [NSMutableArray array];
    }
    return self;
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    [self loadColorProfiles];
    [self setProfileGUI];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [[self window] center];

    [self createSyntaxDefinitionsArrays];
    [self.syntaxDefinitionPopUp addItemsWithTitles:availableSyntaxDefinitions];
    [self.syntaxDefinitionPopUp setTitle:[TCADefaultsHelper getDefaultSyntaxDefinition]];
        
    NSFont *editorFont = [TCADefaultsHelper getEditorFont];
    NSFont *panelFont = [NSFont fontWithName:[editorFont fontName] size:11.0];
    if (panelFont == nil) {
        panelFont = [NSFont fontWithName:@"Menlo Regular" size:11.0];
    }
    [self.fontTextField setFont:panelFont];
    [self.fontTextField setStringValue:[NSString stringWithFormat:@"%@ - %1.1f",[panelFont fontName], [editorFont pointSize]]];
    [self.replaceTabsCheckBox setState:[TCADefaultsHelper getReplaceTabs]];
    [self.tabWidthTextField setIntegerValue:[TCADefaultsHelper getTabWidth]];
    if ([self.replaceTabsCheckBox state] == 0) {
        [self.tabWidthTextField setEnabled:NO];
    } else {
        [self.tabWidthTextField setEnabled:YES];
    }
    [self.indentNewLineCheckBox setState:[TCADefaultsHelper getIndentNewLine]];
    [self.wrapLinesCheckBox setState:![TCADefaultsHelper getNotWrapLines]];
    [self.pageGuideCheckBox setState:[TCADefaultsHelper getShowPageGuide]];
    [self.pageGuideTextField setIntegerValue:[TCADefaultsHelper getPageGuideColumn]];
    [self.showLineNumbersCheckBox setState:[TCADefaultsHelper getShowLineNumbers]];
    [self.highlightCurrentLineCheckBox setState:[TCADefaultsHelper getHighlightCurrentLine]];
    [self.openLastFilesCheckBox setState:[TCADefaultsHelper getOpenLastFiles]];
    [self.autocompleteBracketsCheckBox setState:[TCADefaultsHelper getAutoCompleteBrackets]];
    [self.autocompleteQuotationsCheckBox setState:[TCADefaultsHelper getAutoCompleteQuotations]];
    [self.showBinaryWarningCheckBox setState:![TCADefaultsHelper getDontShowBinaryWarning]];
    
    [self loadColorProfiles];
    [self importColorsFromPreviousVersion]; //load colors from old tincta if set there
    [self.toolbar setSelectedItemIdentifier:@"General"];
    [self setProfileGUI];
    [[self window] setIsVisible:NO];
}




- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] setHidesOnDeactivate:NO];
    [[self window] setExcludedFromWindowsMenu:YES];
}


- (BOOL)windowShouldClose:(NSWindow *)awindow {
    [self setPageGuideColumn:nil];
    [self setTabWidth:self];
    [[self window] setIsVisible:NO];
    return NO;
}

- (IBAction)performClose1:(id)sender {
    [self setPageGuideColumn:nil];
    [self setTabWidth:self];
    [[self window] setIsVisible:NO];
}

#pragma mark toolbar

- (IBAction)changeToGeneralTab:(id)sender {
    [self.tabView selectTabViewItemWithIdentifier:@"General"];
}


- (IBAction)changeToColorsTab:(id)sender {
    [self.tabView selectTabViewItemWithIdentifier:@"Colors"];
    [self.window makeFirstResponder:self.colorProfileDummyField];
}

#pragma mark general

- (IBAction)setDefaultSyntaxDefinition:(id)sender {
    NSString *defaultSyntax = [[self.syntaxDefinitionPopUp selectedItem]title];
    [self.syntaxDefinitionPopUp setTitle:defaultSyntax];
    [TCADefaultsHelper setDefaultSyntaxDefinition:defaultSyntax];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setFont:(id)sender {
    [[self window] makeFirstResponder:self.setFontButton];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [fontManager setSelectedFont:[TCADefaultsHelper getEditorFont] isMultiple:NO];
	[fontManager orderFrontFontPanel:nil];
}


- (void)changeFont:(id)sender {
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *panelFont = [fontManager convertFont:[fontManager selectedFont]];
    [self.fontTextField setFont:[NSFont fontWithName:[panelFont fontName] size:12.0]];
    [self.fontTextField setStringValue:[NSString stringWithFormat:@"%@ - %1.1f",[panelFont fontName], [panelFont pointSize]]];
    [TCADefaultsHelper setEditorFont:panelFont];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setTabWidth:(id)sender {
    NSInteger width = [self.tabWidthTextField intValue];
    width = width > 0 ? width : 4;
    [TCADefaultsHelper setTabWidth:width];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)toggleReplaceTabs:(id)sender {
    BOOL replace = [self.replaceTabsCheckBox state] == 1;
    [TCADefaultsHelper setReplaceTabs:replace];
    [self.tabWidthTextField setEnabled:replace];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)toggleIndentNewLine:(id)sender {
    [TCADefaultsHelper setIndentNewLine:([self.indentNewLineCheckBox state] == 1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)toggleWrapLines:(id)sender {
    [TCADefaultsHelper setNotWrapLines:([self.wrapLinesCheckBox state] == 0)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChangeWrapping" object:self];
}


- (IBAction)togglePageGuide:(id)sender {
    [TCADefaultsHelper setShowPageGuide:([self.pageGuideCheckBox state] == 1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setPageGuideColumn:(id)sender {
    NSInteger pageGuide = [self.pageGuideTextField intValue];
    pageGuide = pageGuide > 0 ? pageGuide : 120;
    [TCADefaultsHelper setPageGuideColumn:pageGuide];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)toggleLineNumbers:(id)sender {
    [TCADefaultsHelper setShowLineNumbers:([self.showLineNumbersCheckBox state] == 1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)toggleHighlightCurrentLine:(id)sender {
    [TCADefaultsHelper setHighlightCurrentLine:([self.highlightCurrentLineCheckBox state] == 1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)toggleOpenWithLastUsedFiles:(id)sender {
    [TCADefaultsHelper setOpenLastFiles:([self.openLastFilesCheckBox state] == 1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)toggleAutocompleteBrackets:(id)sender {
    [TCADefaultsHelper setAutoCompleteBrackets:([self.autocompleteBracketsCheckBox state] == 1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}

- (IBAction)toggleAutocompleteQuotations:(id)sender {
    [TCADefaultsHelper setAutoCompleteQuotations:([self.autocompleteQuotationsCheckBox state] == 1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}

- (IBAction)toggleShowBinaryWarning:(id)sender {
    [TCADefaultsHelper setDontShowBinaryWarning:([self.showBinaryWarningCheckBox state] == 0)];
    
}




#pragma mark - color profiles

- (void) loadColorProfiles {
    [self.colorProfiles removeAllObjects];
    [self.colorProfiles addObjectsFromArray: [TCAColorScheme builtInColorSchemes]];
    [self.colorProfiles addObjectsFromArray: [TCAColorScheme userColorSchemes]];

    
    self.selectedColorProfile = self.colorProfiles.firstObject;
    NSString* savedFilePath = [TCADefaults objectForKey:@"selectedColorProfilePath"];
    for (TCAColorScheme* profile in self.colorProfiles) {
        if ([savedFilePath isEqualToString:profile.fileUrl.path]) {
            self.selectedColorProfile = profile;
        }
    }
    [TCADefaults setObject:self.selectedColorProfile.fileUrl.path forKey:@"selectedColorProfilePath"];
}

- (void) importColorsFromPreviousVersion {
    if (self.selectedColorProfile == nil) {
        NSLog(@"TCPreferencesController > loadColorsFromPreviousVersion > no selected profile");
        return;
    }
    
    if ([TCADefaultsHelper hasImportedColorsFromPreviousVersion]) {
        return;
    }
    [TCADefaults setBool:YES forKey:@"hasImportedColorsFromPreviousVersion"];
    [TCADefaults synchronize];


    if (CGColorEqualToColor([TCADefaultsHelper getBackgroundColor].CGColor, [NSColor colorWithDeviceWhite:1.0f alpha:1.0f].CGColor)
        && CGColorEqualToColor([TCADefaultsHelper getTextColor].CGColor, [NSColor colorWithDeviceWhite:0.0f alpha:1.0f].CGColor)
        && CGColorEqualToColor([TCADefaultsHelper getSelectionColor].CGColor, [NSColor selectedTextBackgroundColor].CGColor)) {
        return;
    }
    self.selectedColorProfile.colorText = [TCADefaultsHelper getTextColor];
    self.selectedColorProfile.colorBackground = [TCADefaultsHelper getBackgroundColor];
    self.selectedColorProfile.colorCurrentLine = [TCADefaultsHelper getCurrentLineColor];
    self.selectedColorProfile.colorSelection = [TCADefaultsHelper getSelectionColor];
    self.selectedColorProfile.colorAttributes = [TCADefaultsHelper getAttributesColor];
    self.selectedColorProfile.colorVariables = [TCADefaultsHelper getVariablesColor];
    self.selectedColorProfile.colorComments = [TCADefaultsHelper getCommentsColor];
    self.selectedColorProfile.colorKeywords = [TCADefaultsHelper getKeywordsColor];
    self.selectedColorProfile.colorPredefined = [TCADefaultsHelper getPredefinedColor];
    self.selectedColorProfile.colorStrings = [TCADefaultsHelper getStringsColor];
    self.selectedColorProfile.colorTags = [TCADefaultsHelper getTagsColor];
    self.selectedColorProfile.colorBlocks = [TCADefaultsHelper getBlocksColor];
    self.selectedColorProfile.colorInvisibles = [TCADefaultsHelper getInvisiblesColor];
    [self.selectedColorProfile save];
}


- (void) setColorsFromSelectedProfile {
    if (self.selectedColorProfile == nil) {
        NSLog(@"TCPreferencesController > setColorsFromProfile > no selected profile");
        return;
    }
    
    self.textColorWell.color = self.selectedColorProfile.colorText;
    [TCADefaultsHelper setTextColor:self.selectedColorProfile.colorText];
    
    self.backgroundColorWell.color = self.selectedColorProfile.colorBackground;
    [TCADefaultsHelper setBackgroundColor:self.selectedColorProfile.colorBackground];

    self.currentLineColorWell.color = self.selectedColorProfile.colorCurrentLine;
    [TCADefaultsHelper setCurrentLineColor:self.selectedColorProfile.colorCurrentLine];

    self.selectionColorWell.color = self.selectedColorProfile.colorSelection;
    [TCADefaultsHelper setSelectionColor:self.selectedColorProfile.colorSelection];

    self.attributesColorWell.color = self.selectedColorProfile.colorAttributes;
    [TCADefaultsHelper setAttributesColor:self.selectedColorProfile.colorAttributes];

    self.variablesColorWell.color = self.selectedColorProfile.colorVariables;
    [TCADefaultsHelper setVariablesColor:self.selectedColorProfile.colorVariables];

    self.commentsColorWell.color = self.selectedColorProfile.colorComments;
    [TCADefaultsHelper setCommentsColor:self.selectedColorProfile.colorComments];

    self.keywordsColorWell.color = self.selectedColorProfile.colorKeywords;
    [TCADefaultsHelper setKeywordsColor:self.selectedColorProfile.colorKeywords];

    self.predefinedColorWell.color = self.selectedColorProfile.colorPredefined;
    [TCADefaultsHelper setPredefinedColor:self.selectedColorProfile.colorPredefined];

    self.stringsColorWell.color = self.selectedColorProfile.colorStrings;
    [TCADefaultsHelper setStringsColor:self.selectedColorProfile.colorStrings];

    self.tagsColorWell.color = self.selectedColorProfile.colorTags;
    [TCADefaultsHelper setTagsColor:self.selectedColorProfile.colorTags];

    self.blocksColorWell.color = self.selectedColorProfile.colorBlocks;
    [TCADefaultsHelper setBlocksColor:self.selectedColorProfile.colorBlocks];

    self.invisiblesColorWell.color = self.selectedColorProfile.colorInvisibles;
    [TCADefaultsHelper setInvisiblesColor:self.selectedColorProfile.colorInvisibles];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}




- (void) setProfileGUI {
    [self setColorsFromSelectedProfile];
    
    NSMenu* colorProfileMenu = [self.colorProfilePopup menu];
    [colorProfileMenu removeAllItems];
    NSMenuItem* selectedMenuItem = nil;
    for (TCAColorScheme* profile in self.colorProfiles) {
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:profile.name action:@selector(changeColorProfile:) keyEquivalent:@""];
        
        if ([profile isEqualTo:self.selectedColorProfile]) {
            selectedMenuItem = item;
            item.state = NSOnState;
        }
        [colorProfileMenu addItem:item];
    }
    [self.colorProfilePopup setMenu:colorProfileMenu];
    [self.colorProfilePopup selectItem:selectedMenuItem];
    [self.colorProfilePopup setEnabled: true];

    [self.colorProfileDuplicateButton setEnabled: true];
    [self.colorProfileDuplicateButton setHidden: false];

    BOOL isUserGenerated = self.selectedColorProfile.isUserGenerated;
    [self.colorProfileDeleteButton setHidden: !isUserGenerated];
    [self.colorProfileDeleteButton setEnabled: isUserGenerated];
    
    [self.colorProfileNameField setEnabled: isUserGenerated];
    
    self.colorProfileNameField.stringValue = self.selectedColorProfile.name;
}


- (IBAction)changeColorProfile:(id)sender {

    NSMenuItem* item = (NSMenuItem*)sender;
    NSMenu* colorProfileMenu = [self.colorProfilePopup menu];
    
    NSInteger selectedIndex = [colorProfileMenu indexOfItem:item];
    self.selectedColorProfile = self.colorProfiles[selectedIndex];
    [TCADefaults setObject:self.selectedColorProfile.fileUrl.path forKey:@"selectedColorProfilePath"];

    [self setProfileGUI];
    [self.window makeFirstResponder:self.colorProfileDummyField];
}



- (IBAction)duplicateColorProfile:(id)sender {
    NSURL* newUrl = [self.selectedColorProfile duplicateWithName:nil];
    if (newUrl == nil) {
        NSRunAlertPanel(@"Could not duplicate", @"An error occurred when duplicating the profile. Please restart Tincta and try again.", @"OK", nil, nil);
    } else {
        [TCADefaults setObject:newUrl.path forKey:@"selectedColorProfilePath"];
        //color profile will be set to this in loadColorProfiles
    }
    [self loadColorProfiles];
    [self setProfileGUI];
    [self.window makeFirstResponder:self.colorProfileDummyField];
}


- (IBAction)deleteColorProfile:(id)sender {
    if (self.selectedColorProfile.isUserGenerated) {
        NSInteger returnValue = NSRunAlertPanel(@"Really delete?", @"Do you really want to delete the selected color profile? This cannot be undone.", @"Cancel", @"Delete", nil);
        if (returnValue != NSAlertDefaultReturn) {
            NSFileManager* fm = [NSFileManager defaultManager];
            [fm removeItemAtURL:self.selectedColorProfile.fileUrl error:NULL];
            [self loadColorProfiles];
            [self setProfileGUI];
            [self.window makeFirstResponder:self.colorProfileDummyField];
        }
    }
}

- (IBAction)renameColorProfile:(id)sender {
    NSURL* newUrl = [self.selectedColorProfile rename:self.colorProfileNameField.stringValue];
    if (newUrl == nil) {
        NSRunAlertPanel(@"Could not rename", @"An error occurred when renaming the profile. Please restart Tincta and try again.", @"OK", nil, nil);
    } else {
        [TCADefaults setObject:newUrl.path forKey:@"selectedColorProfilePath"];
        //color profile will be set to this in loadColorProfiles
    }
    [self loadColorProfiles];
    [self setProfileGUI];
    [self.window makeFirstResponder:self.colorProfileDummyField];
}

- (void) saveSelectedProfile {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        return;
    }
    if (_colorProfileSaveTimer != nil) {
        [_colorProfileSaveTimer invalidate];
        _colorProfileSaveTimer = nil;
    }
    _colorProfileSaveTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self.selectedColorProfile selector:@selector(save) userInfo:nil repeats:NO];
}


#pragma mark -
#pragma mark colors

- (IBAction)setTextColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorText isEqualTo: self.textColorWell.color]) {
        self.selectedColorProfile.colorText = self.textColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setTextColor:[self.textColorWell color]];
    [TCADefaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
    
}


- (IBAction)setBackgroundColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorBackground isEqualTo: self.backgroundColorWell.color]) {
        self.selectedColorProfile.colorBackground = self.backgroundColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setBackgroundColor:[self.backgroundColorWell color]];
    [TCADefaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setCurrentLineColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorCurrentLine isEqualTo: self.currentLineColorWell.color]) {
        self.selectedColorProfile.colorCurrentLine = self.currentLineColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setCurrentLineColor:[self.currentLineColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setSelectionColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorSelection isEqualTo: self.selectionColorWell.color]) {
        self.selectedColorProfile.colorSelection = self.selectionColorWell.color;
        [self saveSelectedProfile];
    }

    [TCADefaultsHelper setSelectionColor:[self.selectionColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setAttributesColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorAttributes isEqualTo: self.attributesColorWell.color]) {
        self.selectedColorProfile.colorAttributes = self.attributesColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setAttributesColor:[self.attributesColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setVariablesColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorVariables isEqualTo: self.variablesColorWell.color]) {
        self.selectedColorProfile.colorVariables = self.variablesColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setVariablesColor:[self.variablesColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setCommentsColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorComments isEqualTo: self.commentsColorWell.color]) {
        self.selectedColorProfile.colorComments = self.commentsColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setCommentsColor:[self.commentsColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setKeywordsColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorKeywords isEqualTo: self.keywordsColorWell.color]) {
        self.selectedColorProfile.colorKeywords = self.keywordsColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setKeywordsColor:[self.keywordsColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setPredefinedColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorPredefined isEqualTo: self.predefinedColorWell.color]) {
        self.selectedColorProfile.colorPredefined = self.predefinedColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setPredefinedColor:[self.predefinedColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setStringsColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorStrings isEqualTo: self.stringsColorWell.color]) {
        self.selectedColorProfile.colorStrings = self.stringsColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setStringsColor:[self.stringsColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setTagsColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorTags isEqualTo: self.tagsColorWell.color]) {
        self.selectedColorProfile.colorTags = self.tagsColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setTagsColor:[self.tagsColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setBlocksColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorBlocks isEqualTo: self.blocksColorWell.color]) {
        self.selectedColorProfile.colorBlocks = self.blocksColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setBlocksColor:[self.blocksColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}


- (IBAction)setInvisiblesColor:(id)sender {
    if (NO == self.selectedColorProfile.isUserGenerated) {
        [self duplicateColorProfile:self];
    }
    if (NO == [self.selectedColorProfile.colorInvisibles isEqualTo: self.invisiblesColorWell.color]) {
        self.selectedColorProfile.colorInvisibles = self.invisiblesColorWell.color;
        [self saveSelectedProfile];
    }
    [TCADefaultsHelper setInvisiblesColor:[self.invisiblesColorWell color]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPreferencesDidChange" object:self];
}





#pragma mark -
#pragma mark helper

- (void) createSyntaxDefinitionsArrays {
    NSMutableArray* availableDefinitions = [NSMutableArray arrayWithCapacity:128];
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *syntaxDefFolderPath = [NSString stringWithFormat:@"%@/Contents/Resources/Syntax Definitions", mainBundlePath];
    NSFileManager *fileManager = [NSFileManager defaultManager]; 
    if ([fileManager fileExistsAtPath: syntaxDefFolderPath] == NO) { 
        return;
    } 
    NSArray *syntaxDefPathList = [fileManager contentsOfDirectoryAtPath:syntaxDefFolderPath error:NULL];
    
    for (NSString *filePath in syntaxDefPathList) {
        NSString *fileNameWithExtension = [filePath lastPathComponent];
        NSString *fileExtension = [filePath pathExtension];
        NSString *fileName = [fileNameWithExtension substringToIndex:[fileNameWithExtension length]-([fileExtension length]+1)];
        [availableDefinitions addObject:fileName];
    }
    availableSyntaxDefinitions = [NSArray arrayWithArray:availableDefinitions];
}












@end
