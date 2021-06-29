//
//  TCADefaultsController.h
//  tincta
//
//  Created by Julius Peinelt on 2/24/13.
//
//

@interface TCADefaultsHelper : NSObject


/*****************************************************************************************
 *GETTER
 ****************************************************************************************/

// general preferences

+ (NSString*)getDefaultSyntaxDefinition;
+ (NSFont*)getEditorFont;
+ (NSInteger)getTabWidth;
+ (BOOL)getReplaceTabs;
+ (BOOL)getIndentNewLine;
+ (BOOL)getNotWrapLines;
+ (BOOL)getShowPageGuide;
+ (NSInteger)getPageGuideColumn;
+ (BOOL)getShowLineNumbers;
+ (BOOL)getHighlightCurrentLine;
+ (BOOL)getOpenLastFiles;
+ (BOOL)getAutoCompleteBrackets;
+ (BOOL)getAutoCompleteQuotations;
+ (BOOL)getDontShowBinaryWarning;
+ (BOOL)getUseGrayIcons;
+ (BOOL)getUseSmallSidebarIcons;

// color preferences

+ (NSColor*)getTextColor;
+ (NSColor*)getBackgroundColor;
+ (NSColor*)getCurrentLineColor;
+ (NSColor*)getSelectionColor;
+ (NSColor*)getAttributesColor;
+ (NSColor*)getVariablesColor;
+ (NSColor*)getCommentsColor;
+ (NSColor*)getKeywordsColor;
+ (NSColor*)getPredefinedColor;
+ (NSColor*)getStringsColor;
+ (NSColor*)getTagsColor;
+ (NSColor*)getBlocksColor;
+ (NSColor*)getInvisiblesColor;

// recent Items preferences

+ (NSArray*)getRecentItemsBookmarks;
+ (NSArray*)getOpenFilesToRestoreBookmarks;
+ (NSData*)getFileBrowserBaseBookmark;
+ (NSString*)getFileBrowserRootFolder;

// other preferences

+ (CGFloat)getDontShowProInfoForVersion;
+ (NSString*)getLastDisplayedWhatsNewVersion;
+ (BOOL)getIsNotFirstStart;
+ (NSInteger)getZenVersion;
+ (BOOL)hasImportedColorsFromPreviousVersion;

/****************************************************************************************
 *SETTER
 ***************************************************************************************/


// general preferences

+ (void)setDefaultSyntaxDefinition:(NSString*)defaultSyntaxDefinition;
+ (void)setEditorFont:(NSFont*)font;
+ (void)setTabWidth:(NSInteger)width;
+ (void)setReplaceTabs:(BOOL)replace;
+ (void)setIndentNewLine:(BOOL)indentNewLine;
+ (void)setNotWrapLines:(BOOL)notWrapLines;
+ (void)setShowPageGuide:(BOOL)pageGuide;
+ (void)setPageGuideColumn:(NSInteger)column;
+ (void)setShowLineNumbers:(BOOL)lineNumbers;
+ (void)setHighlightCurrentLine:(BOOL)highlight;
+ (void)setOpenLastFiles:(BOOL)open;
+ (void)setAutoCompleteBrackets:(BOOL)completeBrackets;
+ (void)setAutoCompleteQuotations:(BOOL)completeQuotations;
+ (void)setDontShowBinaryWarning:(BOOL)dontShow;
+ (void)setUseGrayIcons:(BOOL)grayIcons;
+ (void)setUseSmallSidebarIconsIcons:(BOOL)smallIcons;

// color preferences

+ (void)setTextColor:(NSColor*)color;
+ (void)setBackgroundColor:(NSColor*)color;
+ (void)setCurrentLineColor:(NSColor*)color;
+ (void)setSelectionColor:(NSColor*)color;
+ (void)setAttributesColor:(NSColor*)color;
+ (void)setVariablesColor:(NSColor*)color;
+ (void)setCommentsColor:(NSColor*)color;
+ (void)setKeywordsColor:(NSColor*)color;
+ (void)setPredefinedColor:(NSColor*)color;
+ (void)setStringsColor:(NSColor*)color;
+ (void)setTagsColor:(NSColor*)color;
+ (void)setBlocksColor:(NSColor*)color;
+ (void)setInvisiblesColor:(NSColor*)color;



// recent Items preferences

+ (void)setRecentItemsBookmarks:(NSArray*)recentItems;
+ (void)setOpenFilesToRestoreBookmarks:(NSArray*)openFiles;
+ (void)setFileBrowserBaseBookmark:(NSData*)browserBaseBookmark;
+ (void)setFileBrowserRootFolder:(NSString*)rootFolder;


// other preferences

+ (void)setDontShowProInfoForVersion:(CGFloat)version;
+ (void)setLastDisplayedWhatsNewVersion:(NSString*)lastVersion;
+ (void)setIsNotFirstStart:(BOOL)notFirstStart;
+ (void)setZenVersion:(NSInteger)version;
+ (void) setHasImportedColorsFromPreviousVersion: (BOOL) hasImported;

@end
