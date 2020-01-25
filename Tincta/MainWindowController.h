

#import <Cocoa/Cocoa.h>
#import "TCSideBarController.h"
#import "TCPreferencesController.h"
@class TCSideBarController, TCStatusView, TCTextViewController, TCSyntaxColoring, TCEncodings, TCASearchController;

@interface MainWindowController : NSWindowController <TCSideBarDelegate, NSWindowDelegate>
{
    
    TCPreferencesController *preferencesController;
    
    TCSideBarItem * selectedItem;

    CGFloat splitBarPosition;
    BOOL doIgnoreTextDidChangeNotifactions;
    BOOL needsToCloseAfterSave;
    BOOL shallCloseAllDocuments;
    BOOL isSavingUnderNewName;
    NSURL* lastUsedPath;

    BOOL appIsActive;
    BOOL isAwakeFromNib;

    NSMutableArray* recentItemsUrls;
    NSMutableArray* recentItemsBookmarks;
}

@property (assign) IBOutlet NSSplitView *mySplitView;
@property (assign) IBOutlet TCASearchController *searchController;
@property (assign) IBOutlet TCStatusView* statusView;
@property (assign) IBOutlet NSTextField* statusTextField;
@property (assign) IBOutlet NSMenu* textMenu;
@property (assign) IBOutlet NSMenuItem* encodingsMenuItem;

@property (assign) IBOutlet NSMenu* fileMenu;
@property (assign) IBOutlet NSMenuItem* recentItemsMenuItem;

@property (assign) IBOutlet NSMenu* tinctaMenu;

@property (assign) IBOutlet TCTextViewController* textViewController;
@property (assign) IBOutlet TCSideBarController* sidebarController;
@property (assign) IBOutlet NSToolbarItem* toolbarOpenItem;
@property (assign) IBOutlet NSButton* toolbarOpenItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarCloseItem;
@property (assign) IBOutlet NSButton* toolbarCloseItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarNewItem;
@property (assign) IBOutlet NSButton* toolbarNewItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarSaveItem;
@property (assign) IBOutlet NSButton* toolbarSaveItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarInvisiblesItem;
@property (assign) IBOutlet NSButton* toolbarInvisiblesItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarToggleCaseItem;
@property (assign) IBOutlet NSButton* toolbarToggleCaseItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarSearchItem;
@property (assign) IBOutlet NSButton* toolbarSearchItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarPrintItem;
@property (assign) IBOutlet NSButton* toolbarPrintItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarPreferencesItem;
@property (assign) IBOutlet NSButton* toolbarPreferencesItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarCustomizeItem;
@property (assign) IBOutlet NSButton* toolbarCustomizeItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarOpenBrowserItem;
@property (assign) IBOutlet NSButton* toolbarOpenBrowserItemCell;
@property (assign) IBOutlet NSToolbarItem* toolbarSyntaxColoringItem;

@property (assign) IBOutlet NSToolbar* toolbar;


@property (strong) NSMutableSet* openUrlBookmarks;
@property (strong) NSMutableArray* recentItems;
@property (strong) TCPreferencesController *preferencesController;

@property (strong) NSPopover* donationPopover;

- (IBAction) newFile: (id) sender;
- (IBAction) performClose1: (id) sender;
- (IBAction) closeFile: (id) sender;
- (IBAction) selectPreviousFile:(id)sender;
- (IBAction) selectNextFile:(id)sender;
- (IBAction) customizeToolbar: (id) sender;

- (BOOL) windowShouldClose:(NSWindow *)awindow;
- (IBAction) open: (id) sender;
- (IBAction) openInBrowser: (id) sender;

- (BOOL) loadFileForItem: (TCSideBarItem*) anItem;
- (IBAction) save: (id) sender;
- (IBAction) saveAs: (id) sender;
- (IBAction) revertToSaved:(id)sender;

- (IBAction) openRecentItem: (id) sender;
- (IBAction) showPreferences: (id) sender;
 - (IBAction) showWhatsNewInfo:(id)sender;

- (void) openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void) savePanelDidEnd:(NSSavePanel *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void) updateStatusText;
- (void) addRecentItem: (NSURL*) anUrl;
- (void) setToolbarItemColor;

- (void) textDidChange: (NSNotification*) aNotification;
- (void) textViewDidChangeSelection:(NSNotification *)aNotification;


- (void) bringWindowToFront;
- (void) animateInkIcon;
- (void) animateInkIconTwo;
- (void) animateInkIconThree;
- (void) animateInkIconFour;
- (void) animateInkIconReset;

@end
