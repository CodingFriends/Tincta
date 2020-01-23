//
//  TCPreferencesController.h
//  Tincta
//
//  Created by Julius on 28.04.11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Cocoa/Cocoa.h>

@class TCAColorScheme;

@interface TCPreferencesController : NSWindowController {
    
    //Helper
    NSArray *availableSyntaxDefinitions;
    NSTimer* _colorProfileSaveTimer;
}

@property (weak, nonatomic)IBOutlet NSTabView *tabView;
@property (weak, nonatomic) IBOutlet NSToolbar *toolbar;

@property (weak, nonatomic) IBOutlet NSToolbarItem *toolbarGeneralItem;
@property (weak, nonatomic) IBOutlet NSToolbarItem *toolbarColorsItem;
@property (assign) IBOutlet NSButton* toolbarGeneralItemCell;
@property (assign) IBOutlet NSButton* toolbarColorsItemCell;

    //General
@property (weak, nonatomic) IBOutlet NSTextField *fontTextField;
@property (weak, nonatomic) IBOutlet NSButton *setFontButton;
@property (weak, nonatomic) IBOutlet NSPopUpButton *syntaxDefinitionPopUp;
    
@property (weak, nonatomic) IBOutlet NSTextField *tabWidthLabel;
@property (weak, nonatomic) IBOutlet NSTextField *tabWidthTextField;
@property (weak, nonatomic) IBOutlet NSButton *replaceTabsCheckBox;
@property (weak, nonatomic) IBOutlet NSButton *indentNewLineCheckBox;
@property (weak, nonatomic) IBOutlet NSButton *wrapLinesCheckBox;
@property (weak, nonatomic) IBOutlet NSButton *pageGuideCheckBox;
@property (weak, nonatomic) IBOutlet NSTextField *pageGuideTextField;
@property (weak, nonatomic) IBOutlet NSButton *showLineNumbersCheckBox;
@property (weak, nonatomic) IBOutlet NSButton *highlightCurrentLineCheckBox;
@property (weak, nonatomic) IBOutlet NSButton *openLastFilesCheckBox;
@property (weak, nonatomic) IBOutlet NSButton *autocompleteBracketsCheckBox;
@property (weak, nonatomic) IBOutlet NSButton *autocompleteQuotationsCheckBox;
    
@property (weak, nonatomic) IBOutlet NSButton *showBinaryWarningCheckBox;

    
    //Colors
@property (weak, nonatomic) IBOutlet NSColorWell* textColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* backgroundColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* currentLineColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* selectionColorWell;
    
@property (weak, nonatomic) IBOutlet NSColorWell* attributesColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* variablesColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* commentsColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* keywordsColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* predefinedColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* stringsColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* tagsColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* blocksColorWell;
@property (weak, nonatomic) IBOutlet NSColorWell* invisiblesColorWell;

@property (weak, nonatomic) IBOutlet NSPopUpButton* colorProfilePopup;
@property (weak, nonatomic) IBOutlet NSButton* colorProfileDuplicateButton;
@property (weak, nonatomic) IBOutlet NSButton* colorProfileDeleteButton;
@property (weak, nonatomic) IBOutlet NSTextField* colorProfileNameField;
@property (weak, nonatomic) IBOutlet NSTextField* colorProfileDummyField;

/////////////////////

@property (strong, nonatomic) TCAColorScheme* selectedColorProfile;
@property (strong, nonatomic) NSMutableArray* colorProfiles;


- (BOOL)windowShouldClose:(NSWindow *)awindow;
- (IBAction)performClose1:(id)sender;

- (IBAction)changeToGeneralTab:(id)sender;
- (IBAction)changeToColorsTab:(id)sender;

- (IBAction)setDefaultSyntaxDefinition:(id)sender;
- (IBAction)setFont:(id)sender;
- (IBAction)setTabWidth:(id)sender;
- (IBAction)toggleReplaceTabs:(id)sender;
- (IBAction)toggleIndentNewLine:(id)sender;
- (IBAction)toggleWrapLines:(id)sender;
- (IBAction)togglePageGuide:(id)sender;
- (IBAction)setPageGuideColumn:(id)sender;
- (IBAction)toggleLineNumbers:(id)sender;
- (IBAction)toggleHighlightCurrentLine:(id)sender;
- (IBAction)toggleOpenWithLastUsedFiles:(id)sender;
- (IBAction)toggleAutocompleteBrackets:(id)sender;
- (IBAction)toggleAutocompleteQuotations:(id)sender;
- (IBAction)toggleShowBinaryWarning:(id)sender;


- (IBAction)duplicateColorProfile:(id)sender;
- (IBAction)deleteColorProfile:(id)sender;
- (IBAction)renameColorProfile:(id)sender;


- (IBAction)setTextColor:(id)sender;
- (IBAction)setBackgroundColor:(id)sender;
- (IBAction)setCurrentLineColor:(id)sender;
- (IBAction)setSelectionColor:(id)sender;
- (IBAction)setAttributesColor:(id)sender;
- (IBAction)setVariablesColor:(id)sender;
- (IBAction)setCommentsColor:(id)sender;
- (IBAction)setKeywordsColor:(id)sender;
- (IBAction)setPredefinedColor:(id)sender;
- (IBAction)setStringsColor:(id)sender;
- (IBAction)setTagsColor:(id)sender;
- (IBAction)setBlocksColor:(id)sender;
- (IBAction)setInvisiblesColor:(id)sender;


- (void) createSyntaxDefinitionsArrays;


@end
