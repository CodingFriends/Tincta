//
//  WSSideBarController.h
//  Watersnake
//
//  Created by Mr. Fridge on 3/25/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//  v1.1

#import <Foundation/Foundation.h>

@class TCSideBarItem;

@protocol TCSideBarDelegate

@optional
- (void)sideBarSelectionDidChange: (NSInteger) selectedIndex;
- (void)sideBarItemsDidChange;

@end


@interface TCSideBarController : NSObject <NSTableViewDelegate, NSTableViewDataSource> {

    NSMutableArray* items;
    TCSideBarItem* selectedItem;
    NSInteger selectedIndex;
    IBOutlet NSTableView* sideBarTableView;
    
    IBOutlet id<TCSideBarDelegate> __strong delegate;
}

@property (strong) NSMutableArray* items;
@property (strong) TCSideBarItem* selectedItem;
@property (assign) NSInteger selectedIndex;
@property (strong) id<TCSideBarDelegate> delegate;

- (NSInteger) indexOfItemUrlEqualToItem: (TCSideBarItem*) anItem;


- (void) addItem: (TCSideBarItem*) anItem;
- (void) addItemWithImage: (NSImage*) anImage topTitle: (NSString*) aTopTitle andBottomTitle: (NSString*) aBottomTitle;
- (void) addItem: (TCSideBarItem*) anItem atIndex: (NSInteger) insertIndex andSelect: (BOOL) select;

- (void) removeItem: (TCSideBarItem*) anItem;
- (void) removeItemAtIndex: (NSInteger) theIndex;
- (void) removeSelectedItem;

- (void) selectItem: (TCSideBarItem*) anItem;
- (void) selectItemAtIndex: (NSInteger) theIndex;
- (void) deselectAll;
- (void) moveItem: (NSInteger) fromIndex toIndex: (NSInteger) toIndex;

//drag drop operations
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation;
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard;
- (void) reload;

// tableview methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (void) tableViewSelectionDidChange: (NSNotification *) aNotification;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
@end

