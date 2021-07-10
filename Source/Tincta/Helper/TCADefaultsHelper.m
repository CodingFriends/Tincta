//
//  TCADefaultsController.m
//  tincta
//
//  Created by Julius Peinelt on 2/24/13.
//
//

#import "TCADefaultsHelper.h"
#import "TCAMenuHelper.h"

@implementation TCADefaultsHelper



/*****************************************************************************************
 * GETTER
 ****************************************************************************************/

#pragma mark - GETTER

#pragma mark general preferences

+ (NSString*)getDefaultSyntaxDefinition {
    NSString* ret = [TCADefaults objectForKey:@"defaultSyntaxDefinition"];
    if (!ret
        || ![[TCAMenuHelper createSyntaxDefinitionsArray] containsObject:ret]) {
        return @"Plain Text";
    }
    return ret;
}


+ (NSFont*)getEditorFont {
    NSData* retData = [TCADefaults objectForKey:@"editorFont"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
         return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    return [NSFont fontWithName:@"Menlo Regular" size:11.0f];
}


+ (NSInteger)getTabWidth {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        return 4;
    }
    NSInteger width = [TCADefaults integerForKey:@"tabWidth"];
    if (width <= 0) {
        return 4;
    }
    return width;
}


+ (BOOL)getReplaceTabs {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setReplaceTabs:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"replaceTabs"];
}


+ (BOOL)getIndentNewLine {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setIndentNewLine:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"indentNewLine"];
}


+ (BOOL)getNotWrapLines {
    return [TCADefaults boolForKey:@"notWrapLines"];
}


+ (BOOL)getShowPageGuide {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setShowPageGuide:NO];
        return NO;
    }
    return [TCADefaults boolForKey:@"showPageGuide"];
}


+ (NSInteger)getPageGuideColumn {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setPageGuideColumn:80];
        return 80;
    }
    NSInteger column = [TCADefaults integerForKey:@"pageGuideColumn"];
    if (column <= 0) {
        return 80;
    }
    return column;
}


+ (BOOL)getShowLineNumbers {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setShowLineNumbers:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"showLineNumbers"];
}


+ (BOOL)getHighlightCurrentLine {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setHighlightCurrentLine:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"highlightCurrentLine"];
}


+ (BOOL)getOpenLastFiles {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setOpenLastFiles:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"openLastFiles"];
}


+ (BOOL)getAutoCompleteBrackets {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setAutoCompleteBrackets:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"autocompleteBrackets"];
}

+ (BOOL)getAutoCompleteQuotations {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setAutoCompleteQuotations:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"autocompleteQuotations"];
}


+ (BOOL)getDontShowBinaryWarning {
    return [TCADefaults boolForKey:@"dontShowBinaryWarning"];
}


+ (BOOL)getUseGrayIcons {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setUseGrayIcons:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"useGrayIcons"];
}


+ (BOOL)getUseSmallSidebarIcons {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setUseSmallSidebarIconsIcons:YES];
        return YES;
    }
    return [TCADefaults boolForKey:@"useSmallerSidebarIcons"];
}


#pragma mark color preferences

+ (NSColor*)getTextColor {
    NSData* retData = [TCADefaults objectForKey:@"textColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceWhite:0.0f alpha:1.0f];
}


+ (NSColor*)getBackgroundColor {
    NSData* retData = [TCADefaults objectForKey:@"backgroundColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceWhite:1.0f alpha:1.0f];
}


+ (NSColor*)getCurrentLineColor {
    NSData* retData = [TCADefaults objectForKey:@"currentLineColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:1.0f green:1.0f blue:0.84f alpha:1.0f];
}


+ (NSColor*)getSelectionColor {
    NSData* retData = [TCADefaults objectForKey:@"selectionColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor selectedTextBackgroundColor];
}


+ (NSColor*)getAttributesColor {
    NSData* retData = [TCADefaults objectForKey:@"attributesColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.48f green:0.0f blue:0.72f alpha:1.0f];
}


+ (NSColor*)getVariablesColor {
    NSData* retData = [TCADefaults objectForKey:@"variablesColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.7f green:0.17f blue:0.65f alpha:1.0f];
}


+ (NSColor*)getCommentsColor {
    NSData* retData = [TCADefaults objectForKey:@"commentsColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.28f green:0.65f blue:0.29f alpha:1.0f];
}


+ (NSColor*)getKeywordsColor {
    NSData* retData = [TCADefaults objectForKey:@"keywordsColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.46f green:0.65f blue:0.77f alpha:1.0f];
}


+ (NSColor*)getPredefinedColor {
    NSData* retData = [TCADefaults objectForKey:@"predefinedColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.52f green:0.39f blue:0.17f alpha:1.0f];
}


+ (NSColor*)getStringsColor {
    NSData* retData = [TCADefaults objectForKey:@"stringsColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.72f green:0.13f blue:0.12f alpha:1.0f];
}


+ (NSColor*)getTagsColor {
    NSData* retData = [TCADefaults objectForKey:@"tagsColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.15f green:0.58f blue:0.67f alpha:1.0f];
}


+ (NSColor*)getBlocksColor {
    NSData* retData = [TCADefaults objectForKey:@"blocksColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.66f green:0.66f blue:0.66f alpha:1.0f];
}


+ (NSColor*)getInvisiblesColor {
    NSData* retData = [TCADefaults objectForKey:@"invisiblesColor"];
    
    if (retData
        && [NSUnarchiver unarchiveObjectWithData:retData] != nil) {
        return [NSUnarchiver unarchiveObjectWithData:retData];
    }
    
    return [NSColor colorWithDeviceRed:0.0f green:0.0f blue:1.0f alpha:1.0f];
}

#pragma mark recent Items preferences

+ (NSArray*)getRecentItemsBookmarks {
    NSArray* recentArrayData = [TCADefaults arrayForKey:@"RecentItemsBookmarks"];
    if (!recentArrayData) {
        recentArrayData = [NSMutableArray arrayWithCapacity:16];
    }
    return recentArrayData;
}


+ (NSArray*)getOpenFilesToRestoreBookmarks {
    NSData* data =  [TCADefaults objectForKey:@"openFilesToRestoreBookmarks"];
    NSArray* bookmarks = [NSArray array];
    if (data
        && [NSUnarchiver unarchiveObjectWithData:data] != nil) {
        bookmarks = [NSUnarchiver unarchiveObjectWithData:data];
    }
    return bookmarks;
}


+ (NSData*)getFileBrowserBaseBookmark {
    return [TCADefaults dataForKey:@"fileBrowserBaseBookmark"];
}


+ (NSString*)getFileBrowserRootFolder {
    NSString* ret = [TCADefaults objectForKey:@"fileBrowserRootFolder"];
    if (!ret) {
        [TCADefaultsHelper setFileBrowserRootFolder:@""];
        return @"";
    }
    return ret;
}


#pragma mark other preferences

+ (CGFloat)getDontShowProInfoForVersion {
    return [TCADefaults floatForKey:@"dontShowProInfoForVersion"];
}


+ (NSString*)getLastDisplayedWhatsNewVersion {
    return [TCADefaults stringForKey:@"lastDisplayedWhatsNewVersion"];
}


+ (BOOL)getIsNotFirstStart {
    return [TCADefaults boolForKey:@"isNotFirstStart"];
}

+ (NSInteger)getZenVersion {
    return [TCADefaults integerForKey:@"ZenVersion"];
}

+ (BOOL)hasImportedColorsFromPreviousVersion {
    return [TCADefaults boolForKey:@"hasImportedColorsFromPreviousVersion"];
}

/****************************************************************************************
 * SETTER
 ***************************************************************************************/

#pragma mark - SETTER

#pragma mark general preferences

+ (void)setDefaultSyntaxDefinition:(NSString*)defaultSyntaxDefinition {
    [TCADefaults setObject:defaultSyntaxDefinition forKey:@"defaultSyntaxDefinition"];
    [TCADefaults synchronize];
}


+ (void)setEditorFont:(NSFont*)font {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:font] forKey:@"editorFont"];
    [TCADefaults synchronize];
}


+ (void)setTabWidth:(NSInteger)width {
    [TCADefaults setInteger:width forKey:@"tabWidth"];
    [TCADefaults synchronize];
}


+ (void)setReplaceTabs:(BOOL)replace {
    [TCADefaults setBool:replace forKey:@"replaceTabs"];
    [TCADefaults synchronize];
}


+ (void)setIndentNewLine:(BOOL)indentNewLine {
    [TCADefaults setBool:indentNewLine forKey:@"indentNewLine"];
    [TCADefaults synchronize];
}


+ (void)setNotWrapLines:(BOOL)notWrapLines {
    [TCADefaults setBool:notWrapLines forKey:@"notWrapLines"];
    [TCADefaults synchronize];
}


+ (void)setShowPageGuide:(BOOL)pageGuide {
    [TCADefaults setBool:pageGuide forKey:@"showPageGuide"];
    [TCADefaults synchronize];
}


+ (void)setPageGuideColumn:(NSInteger)column {
    [TCADefaults setInteger:column forKey:@"pageGuideColumn"];
    [TCADefaults synchronize];
}


+ (void)setShowLineNumbers:(BOOL)lineNumbers {
    [TCADefaults setBool:lineNumbers forKey:@"showLineNumbers"];
    [TCADefaults synchronize];
}


+ (void)setHighlightCurrentLine:(BOOL)highlight {
    [TCADefaults setBool:highlight forKey:@"highlightCurrentLine"];
    [TCADefaults synchronize];
}


+ (void)setOpenLastFiles:(BOOL)open {
    [TCADefaults setBool:open forKey:@"openLastFiles"];
    [TCADefaults synchronize];
}


+ (void)setAutoCompleteBrackets:(BOOL)completeBrackets {
    [TCADefaults setBool:completeBrackets forKey:@"autocompleteBrackets"];
    [TCADefaults synchronize];
}

+ (void)setAutoCompleteQuotations:(BOOL)completeQuotations {
    [TCADefaults setBool:completeQuotations forKey:@"autocompleteQuotations"];
    [TCADefaults synchronize];
}


+ (void)setDontShowBinaryWarning:(BOOL)dontShow {
    [TCADefaults setBool:dontShow forKey:@"dontShowBinaryWarning"];
    [TCADefaults synchronize];
}


+ (void)setUseGrayIcons:(BOOL)grayIcons {
    [TCADefaults setBool:grayIcons forKey:@"useGrayIcons"];
    [TCADefaults synchronize];
}


+ (void)setUseSmallSidebarIconsIcons:(BOOL)smallIcons {
    [TCADefaults setBool:smallIcons forKey:@"useSmallerSidebarIcons"];
    [TCADefaults synchronize];
}


#pragma mark color preferences

+ (void)setTextColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"textColor"];
    [TCADefaults synchronize];
}


+ (void)setBackgroundColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"backgroundColor"];
    [TCADefaults synchronize];
}


+ (void)setCurrentLineColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"currentLineColor"];
    [TCADefaults synchronize];
}


+ (void)setSelectionColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"selectionColor"];
    [TCADefaults synchronize];
}


+ (void)setAttributesColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"attributesColor"];
    [TCADefaults synchronize];
}


+ (void)setVariablesColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"variablesColor"];
    [TCADefaults synchronize];
}


+ (void)setCommentsColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"commentsColor"];
    [TCADefaults synchronize];
}


+ (void)setKeywordsColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"keywordsColor"];
    [TCADefaults synchronize];
}


+ (void)setPredefinedColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"predefinedColor"];
    [TCADefaults synchronize];
}


+ (void)setStringsColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"stringsColor"];
    [TCADefaults synchronize];
}


+ (void)setTagsColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"tagsColor"];
    [TCADefaults synchronize];
}


+ (void)setBlocksColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"blocksColor"];
    [TCADefaults synchronize];
}


+ (void)setInvisiblesColor:(NSColor*)color {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:color] forKey:@"invisiblesColor"];
    [TCADefaults synchronize];
}


#pragma mark recent Items preferences

+ (void)setRecentItemsBookmarks:(NSArray*)recentItems {
    [TCADefaults setObject:recentItems forKey:@"RecentItemsBookmarks"];
    [TCADefaults synchronize];
}


+ (void)setOpenFilesToRestoreBookmarks:(NSArray*)openFiles {
    [TCADefaults setObject:[NSArchiver archivedDataWithRootObject:openFiles]
                   forKey:@"openFilesToRestoreBookmarks"];
    [TCADefaults synchronize];
}


+ (void)setFileBrowserBaseBookmark:(NSData*)browserBaseBookmark {
    [TCADefaults setObject:browserBaseBookmark forKey:@"fileBrowserBaseBookmark"];
}


+ (void)setFileBrowserRootFolder:(NSString *)rootFolder {
    [TCADefaults setObject:rootFolder forKey:@"fileBrowserRootFolder"];
}


#pragma mark other preferences

+ (void)setDontShowProInfoForVersion:(CGFloat)version {
    [TCADefaults setDouble:version forKey:@"dontShowProInfoForVersion"];
    [TCADefaults synchronize];
}


+ (void)setLastDisplayedWhatsNewVersion:(NSString*)lastVersion {
    [TCADefaults setObject:lastVersion forKey:@"lastDisplayedWhatsNewVersion"];
    [TCADefaults synchronize];
}


+ (void)setIsNotFirstStart:(BOOL)notFirstStart {
    [TCADefaults setBool:notFirstStart forKey:@"isNotFirstStart"];
    [TCADefaults synchronize];
}


+ (void)setZenVersion:(NSInteger)version {
    [TCADefaults setInteger:version forKey:@"ZenVersion"];
    [TCADefaults synchronize];
}

+ (void) setHasImportedColorsFromPreviousVersion: (BOOL) hasImported {
    return [TCADefaults setBool:hasImported forKey:@"hasImportedColorsFromPreviousVersion"];
}

@end
