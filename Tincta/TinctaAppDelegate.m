//
//  TinctaAppDelegate.m
//  Tincta
//
//  Created by Mr. Fridge on 4/15/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#ifdef RELEASE_BUILD
#import <HockeySDK/HockeySDK.h>
#import "HockeyConfig.h"
#endif

#import "TinctaAppDelegate.h"
#import "MainWindowController.h"
#import "TCSideBarController.h"
#import "TCSideBarItem.h"
#import "TCTextViewController.h"
#import "Reachability.h"
#import "TCABookmarkHelper.h"


@implementation TinctaAppDelegate

@synthesize window;

- (id)init {
    self = [super init];
    if (self) {
        [self setUserDefaultValues];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#ifdef RELEASE_BUILD
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier: HOCKEYAPPID];
    // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif
    NSArray* savedBookmarks = [TCADefaultsHelper getOpenFilesToRestoreBookmarks];
    
    NSInteger addIndex = [self.mainWindowController.sidebarController.items count];
    NSFileManager* fm = [NSFileManager defaultManager];

    for (NSData* bookmark in savedBookmarks) {
        NSURL* url = [TCABookmarkHelper urlForBookmarkData:bookmark];
        if (url != nil && [fm fileExistsAtPath: url.path]) {
            TCSideBarItem* item = [[TCSideBarItem alloc] initWithFilePath: [url path]];
            [TCABookmarkHelper startAccessingBookmarkUrl:url];
            [self.mainWindowController.openUrlBookmarks addObject:url];
            
            [self.mainWindowController.sidebarController addItem:item atIndex:addIndex andSelect:YES];

            addIndex++;
        }
    }
    
    if ([[self.mainWindowController sidebarController] items] == nil || [[[self.mainWindowController sidebarController] items] count] == 0) {
        [self.mainWindowController newFile:self];
    }
    [[self.mainWindowController sidebarController] selectItemAtIndex:0];


    
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];

    [self.mainWindowController.preferencesController awakeFromNib];
    //hotfix
    [self.mainWindowController.textViewController preferencesDidChange:nil];
    [self.mainWindowController.textViewController preferencesDidChangeWrapping:nil];
    
}


- (void)setUserDefaultValues {
    if (![TCADefaultsHelper getIsNotFirstStart]) {
        [TCADefaultsHelper setShowLineNumbers:YES];
        [TCADefaultsHelper setUseGrayIcons:YES];
        [TCADefaultsHelper setReplaceTabs:YES];
        [TCADefaultsHelper setIndentNewLine:YES];
        [TCADefaultsHelper setPageGuideColumn:80];
        [TCADefaultsHelper setShowPageGuide:YES];
        [TCADefaultsHelper setHighlightCurrentLine:YES];
        [TCADefaultsHelper setOpenLastFiles:YES];
        [TCADefaultsHelper setAutoCompleteBrackets:YES];
        [TCADefaultsHelper setAutoCompleteQuotations:YES];

    }
    [TCADefaultsHelper setIsNotFirstStart:YES];
}



- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    TCSideBarItem* newSideBarItem = [[TCSideBarItem alloc] initWithFilePath:filename];
    newSideBarItem.isDirty = NO;
    newSideBarItem.isModified = NO;
    [self.mainWindowController.sidebarController addItem:newSideBarItem atIndex:0 andSelect:YES];
    [self.mainWindowController bringWindowToFront];
    return YES;
}


- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    for (NSString *filename in filenames) {
        TCSideBarItem* newSideBarItem = [[TCSideBarItem alloc] initWithFilePath:filename];
        newSideBarItem.isDirty = NO;
        newSideBarItem.isModified = NO;
        [self.mainWindowController.sidebarController addItem:newSideBarItem atIndex:0 andSelect:YES];
    }
    [self.mainWindowController bringWindowToFront];
}


- (BOOL) applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [self.mainWindowController newFile:self];
    } else {
        if ([self.mainWindowController.sidebarController.items count] == 0 || self.mainWindowController.sidebarController.items == nil) {
            [self.mainWindowController newFile:self];
        }
        [self.mainWindowController bringWindowToFront];
    }
    return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    //termination is definitely done
    [self.mainWindowController windowShouldClose:window];
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon.icns"]];
}

+ (BOOL)isInternetAvailable {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    //return yes if can terminate; no if terminate later
    NSArray* sideBarItems = self.mainWindowController.sidebarController.items;
    NSMutableArray* bookmarksToSave = [NSMutableArray arrayWithCapacity:[sideBarItems count]];
    
    if ([TCADefaultsHelper getOpenLastFiles]) {
        for (TCSideBarItem* item in sideBarItems) {
            if (item.fileUrl != nil) {
                NSData* bookmark = [TCABookmarkHelper bookmarkForUrl:item.fileUrl];
                if (bookmark != nil) {
                    [bookmarksToSave addObject:bookmark];
                }
            }
        }
    }
    [TCADefaultsHelper setOpenFilesToRestoreBookmarks:bookmarksToSave];
    [self.mainWindowController windowShouldClose:window];
    return NSTerminateLater;
}


- (IBAction)openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mr-fridge.de/software/tincta"]];
}

-(BOOL)isInternetAvail {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    } 
    return YES;
}


- (IBAction) openRecentItem: (id) sender {
    [self.mainWindowController openRecentItem:sender];
    [self.mainWindowController bringWindowToFront];
}


- (void) dealloc {
    self.window = nil;
}


@end
