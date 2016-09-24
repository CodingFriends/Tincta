//
//  WSSideBarController.m
//  Watersnake
//
//  Created by Mr. Fridge on 3/25/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)

#import "TCSideBarController.h"
#import "TCSideBarItem.h"
#import "TCSyntaxColoring.h"

#import "TCAMenuHelper.h"

@implementation TCSideBarController

@synthesize items, selectedItem, selectedIndex, delegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray arrayWithCapacity:4];
        self.selectedIndex = -1;
        self.selectedItem = nil;
    }
    
    return self;
}

#define WSSideBarDataType @"WSSideBarDataType"


- (void) awakeFromNib {
    [sideBarTableView registerForDraggedTypes: @[WSSideBarDataType, @"public.file-url", @"public.url", NSURLPboardType, NSFilenamesPboardType] ];
    [sideBarTableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

#pragma mark add remove
- (void) addItem: (TCSideBarItem*) anItem {
    [self.items addObject:anItem];
    [sideBarTableView reloadData];
    [self.delegate sideBarItemsDidChange];
    
}

- (NSInteger) indexOfItemUrlEqualToItem: (TCSideBarItem*) anItem {
    for (int i = 0; i < [self.items count]; i++) {
        TCSideBarItem* currentItem = (self.items)[i];
        if (anItem.fileUrl != nil && currentItem.fileUrl != nil) {
            if ([anItem.fileUrl isEqualTo:currentItem.fileUrl]) {
                return i;
            }
        }
    }
    return NSNotFound;
}

- (void) addItem: (TCSideBarItem*) anItem atIndex: (NSInteger) insertIndex andSelect: (BOOL) select {
    NSInteger existingIndex = [self indexOfItemUrlEqualToItem:anItem];
    if (existingIndex != NSNotFound) {
        if (select) {
            [self selectItemAtIndex:existingIndex];
        }
    } else {
        insertIndex = insertIndex <= self.items.count ? insertIndex : self.items.count;
        [self.items insertObject:anItem atIndex:insertIndex];
        
        if (self.selectedItem != nil && !select) {
            NSInteger indexOfItem = [self.items indexOfObject:self.selectedItem];
            if (indexOfItem > -1 && indexOfItem < [self.items count]) {
                self.selectedIndex = indexOfItem;
                [sideBarTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.selectedIndex] byExtendingSelection:NO];
            } else {
                [sideBarTableView deselectAll:self];
            }
        }
        
        [sideBarTableView reloadData];
        [self.delegate sideBarItemsDidChange];
        if (select) {
            [self selectItemAtIndex:insertIndex];
        }
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reload) userInfo:nil repeats:NO];
    
}


- (void) addItemWithImage: (NSImage*) anImage topTitle: (NSString*) aTopTitle andBottomTitle: (NSString*) aBottomTitle {
    TCSideBarItem* newItem = [[TCSideBarItem alloc] initWithImage:anImage topTitle:aTopTitle andBottomTitle:aBottomTitle];
    [self addItem:newItem];
}

- (void) removeItem: (TCSideBarItem*) anItem {
    NSInteger removeIndex = [self.items indexOfObject:anItem];
    if (removeIndex < 0) {
        return;
    }
    
    [self.items removeObject:anItem];
    
    if (self.selectedIndex >= removeIndex) {
        if (self.selectedIndex >= [self.items count]) {
            self.selectedIndex--;
        }
        if (self.selectedIndex < 0) {
            if ([self.items count] > 0) {
                self.selectedIndex = 0;
                self.selectedItem = (self.items)[0];
            } else {
                self.selectedItem = nil;
            }
        } else {
            self.selectedItem = (self.items)[self.selectedIndex];
        }
        if (self.selectedIndex > -1 && self.selectedIndex < [self.items count]) {
            [sideBarTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.selectedIndex] byExtendingSelection:NO];
        } else {
            [sideBarTableView deselectAll:self];
        }
        [self.delegate sideBarItemsDidChange];
        [self.delegate sideBarSelectionDidChange:self.selectedIndex];
    } else {
        [self.delegate sideBarItemsDidChange];
    }
    [sideBarTableView reloadData];
}

- (void) removeItemAtIndex: (NSInteger) theIndex {
    if ((theIndex < 0) || theIndex >= [self.items count]) {
        return;
    }
    [self removeItem:(self.items)[theIndex]];
}

- (void) removeSelectedItem {
    if (self.selectedItem == nil) {
        return;
    }
    [self removeItem:self.selectedItem];
}


- (void) selectItem: (TCSideBarItem*) anItem {
    NSInteger indexOfItem = [self.items indexOfObject:anItem];
    if (indexOfItem > -1 && indexOfItem < [self.items count]) {
        self.selectedIndex = indexOfItem;
        self.selectedItem = anItem;
        [sideBarTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.selectedIndex] byExtendingSelection:NO];
        [sideBarTableView reloadData];
        [self.delegate sideBarSelectionDidChange:self.selectedIndex];    
    }
}

- (void) selectItemAtIndex: (NSInteger) theIndex {
    if ((theIndex < 0) || theIndex >= [self.items count]) {
        return;
    }
    [self selectItem:(self.items)[theIndex]];
}

- (void) deselectAll {
    self.selectedIndex = -1;
    self.selectedItem = nil;
    [sideBarTableView deselectAll:self];
    [self.delegate sideBarSelectionDidChange:self.selectedIndex];
}

- (void) moveItem: (NSInteger) fromIndex toIndex: (NSInteger) toIndex {
    if (fromIndex == toIndex) {
        return;
    }
    
    TCSideBarItem* theItem = (self.items)[fromIndex];
    
    [self.items removeObject: theItem];
    if (toIndex >= fromIndex) {
        [self.items insertObject:theItem atIndex:(toIndex-1)];
    } else {
        [self.items insertObject:theItem atIndex:(toIndex)];
    }
    
    
    if (self.selectedItem != nil) {
        NSInteger indexOfItem = [self.items indexOfObject:self.selectedItem];
        if (indexOfItem > -1 && indexOfItem < [self.items count]) {
            self.selectedIndex = indexOfItem;
            [sideBarTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.selectedIndex] byExtendingSelection:NO];
        }
    }
    
    [self.delegate sideBarItemsDidChange];
    [sideBarTableView reloadData];
}


- (void) reload {
    [sideBarTableView reloadData];
}

#pragma mark Tableview delegate methods

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
    if (row < 0 || row >= [self.items count]) {
        return nil;
    }
    return [(self.items)[row] filePath];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (rowIndex < 0 || rowIndex >= [self.items count]) {
        return nil;
    }
    return (self.items)[rowIndex];
}


- (void) tableViewSelectionDidChange: (NSNotification *) aNotification {
	self.selectedIndex = [sideBarTableView selectedRow];
    if (self.selectedIndex < 0 || self.selectedIndex >= [self.items count]) {
        self.selectedIndex = -1;
        self.selectedItem = nil;
    } else {
        self.selectedItem = (self.items)[self.selectedIndex];
    }
    [self.delegate sideBarSelectionDidChange:self.selectedIndex];
    [sideBarTableView scrollRowToVisible:self.selectedIndex];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.items count];
}





#pragma mark drag and drop

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:@[WSSideBarDataType, @"public.file-url"] owner:self];
    [pboard setData:data forType:WSSideBarDataType];  
    
    NSInteger dragRow = [rowIndexes firstIndex];
    
    TCSideBarItem* draggedItem = (self.items)[dragRow];
    NSURL* fileUrl = draggedItem.fileUrl;
    if (fileUrl != nil) {
        [pboard setString: [fileUrl absoluteString] forType:@"public.file-url"];  
        [pboard setString: [fileUrl absoluteString] forType:@"public.url"];  
        [pboard setString: [fileUrl absoluteString] forType:NSURLPboardType];
    }
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
    
    if (op == NSTableViewDropOn) {
        return NSDragOperationNone;
    }    
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)dropRow dropOperation:(NSTableViewDropOperation)operation {
    
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:WSSideBarDataType];
    TCSideBarItem* draggedItem;
    NSInteger dragRow;
    if (rowData != nil) {
        NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
        dragRow = [rowIndexes firstIndex];
        [self moveItem:dragRow toIndex:dropRow];
        
    } else {
        
        NSArray* dropFileNames = [pboard propertyListForType:NSFilenamesPboardType];
        NSInteger i = dropRow;
        NSFileManager* fm = [NSFileManager defaultManager];
        NSArray* acceptedFileTypes = [TCAMenuHelper allFileExtensions];

        for (NSString* fn in dropFileNames) {
            BOOL isDirectory = NO;
            [fm fileExistsAtPath:fn isDirectory:&isDirectory];
            if (isDirectory) {
                NSArray* directoryContent = [fm contentsOfDirectoryAtPath:fn error:NULL];
                for (NSString* dirFileName in directoryContent) {
                    NSString* extension = [dirFileName pathExtension];
                    if ([acceptedFileTypes containsObject:extension]) {
                        draggedItem = [[TCSideBarItem alloc] initWithFilePath:[fn stringByAppendingPathComponent:dirFileName]];
                        NSInteger existingIndex = [self indexOfItemUrlEqualToItem:draggedItem];
                        if (existingIndex == NSNotFound) {
                            [self.items insertObject:draggedItem atIndex:(i)];
                            i++;
                        } 
                    }
                }
            } else {
                draggedItem = [[TCSideBarItem alloc] initWithFilePath:fn];
                NSInteger existingIndex = [self indexOfItemUrlEqualToItem:draggedItem];
                if (existingIndex == NSNotFound) {
                    [self.items insertObject:draggedItem atIndex:(i)];
                    i++;
                } 
            }
           
        }
        
        [sideBarTableView reloadData];
        
        //for moving this happens in the movemethod 
        if (self.selectedItem != nil) {
            NSInteger indexOfItem = [self.items indexOfObject:self.selectedItem];
            if (indexOfItem > -1 && indexOfItem < [self.items count]) {
                self.selectedIndex = indexOfItem;
                [sideBarTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.selectedIndex] byExtendingSelection:NO];
            }
        }
        [self.delegate sideBarItemsDidChange];
    }
    
    return YES;
}

@end
