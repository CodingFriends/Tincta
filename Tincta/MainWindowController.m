

#import "MainWindowController.h"
#import "TCSideBarController.h"
#import "TCSideBarItem.h"
#import "TCStatusView.h"
#import "TCTextViewController.h"
#import "TCEncodings.h"
#import "TCSyntaxColoring.h"
#import "TCTextStorage.h"
#import "TCASearchController.h"
#import "TCABookmarkHelper.h"

@implementation MainWindowController

@synthesize sidebarController, preferencesController, textViewController;

- (void)awakeFromNib {
    
    isAwakeFromNib = YES;
    
    [[self window] setAllowsConcurrentViewDrawing:YES];
    
    self.openUrlBookmarks = [NSMutableSet set];
    recentItemsBookmarks = [NSMutableArray arrayWithArray:[TCADefaultsHelper getRecentItemsBookmarks]];
    recentItemsUrls = [NSMutableArray arrayWithCapacity:recentItemsBookmarks.count];
    for (NSData* bookmark in recentItemsBookmarks) {
        NSURL* itemUrl = [TCABookmarkHelper urlForBookmarkData:bookmark];
        if (itemUrl != nil) {
            [recentItemsUrls addObject:itemUrl];
        }
    }
    
    [self addRecentItem:nil]; //this updates the menu
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name: @"TCTextStorageDidChangeText" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusText) name:@"TCShallUpdateStatusBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeSelection:) name:@"NSTextViewDidChangeSelectionNotification" object:nil];

    preferencesController = [[TCPreferencesController alloc] init];
    

    NSFont* iconFont = [NSFont fontWithName:@"iconmonstr-iconic-font" size:18];
    [self.toolbarSearchItemCell setFont: iconFont];
    [self.toolbarNewItemCell setFont: iconFont];
    [self.toolbarOpenItemCell setFont: iconFont];
    [self.toolbarCloseItemCell setFont: iconFont];
    [self.toolbarSaveItemCell setFont: iconFont];
    [self.toolbarPreferencesItemCell setFont: iconFont];
    [self.toolbarOpenBrowserItemCell setFont: iconFont];
    [self.toolbarPrintItemCell setFont: iconFont];

    [self.toolbarSearchItemCell setTitle:[NSString stringWithFormat: @"%C", 0xe07a]];
    [self.toolbarNewItemCell setTitle:[NSString stringWithFormat: @"%C", 0xe072]];
    [self.toolbarOpenItemCell setTitle:[NSString stringWithFormat: @"%C", 0xe03a]];
    [self.toolbarCloseItemCell setTitle:[NSString stringWithFormat: @"%C", 0xe08c]];
    [self.toolbarSaveItemCell setTitle:[NSString stringWithFormat: @"%C", 0xe039]];
    [self.toolbarPreferencesItemCell setTitle:[NSString stringWithFormat: @"%C", 0xe09c]];
    [self.toolbarOpenBrowserItemCell setTitle:[NSString stringWithFormat: @"%C", 0xe0b0]];
    [self.toolbarPrintItemCell setTitle:[NSString stringWithFormat: @"%C", 0xe016]];


}


#pragma mark -
#pragma mark menu actions


- (IBAction) newFile: (id) sender {
    TCSideBarItem* item = [[TCSideBarItem alloc] initWithImage:[NSImage imageNamed:@"GenericDocumentIcon"] topTitle:@"Untitled"  andBottomTitle:@"swimming in unsaved waters"];
    item.encoding = NSUTF8StringEncoding;
    item.textStorage = [[TCTextStorage alloc] initWithString:@""];
    item.isDirty = YES;
    item.isModified = NO;
    [sidebarController addItem:item atIndex:0 andSelect:YES];
    [self updateStatusText];
    [[self window] setIsVisible:YES];
    
}

- (IBAction) performClose1: (id) sender {
    shallCloseAllDocuments = NO;
    [self closeFile:sender];
}



- (IBAction) closeFile: (id) sender {
    if ([sidebarController.items count] == 0) {
        [[self window] setIsVisible:NO];
        [NSApp replyToApplicationShouldTerminate:YES];
    } else {
        if (selectedItem.isModified) {
            NSString *fileName = @"untitled";
            if ([selectedItem.filePath lastPathComponent] != nil) {
                fileName = [selectedItem.filePath lastPathComponent];
            }
            [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_yelling.icns"]];
            NSAlert* alert = [NSAlert alertWithMessageText:@"Unsaved changes " defaultButton:@"Save" alternateButton:@"Don't save" otherButton:@"Cancel" informativeTextWithFormat:@"The document \"%@\" has unsaved changes. Do you want to save it before closing?", fileName];
            [alert setIcon:[NSImage imageNamed:@"app_icon_yelling"]];
            
            [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:@"SaveBeforeClose"];
        } else {
            NSURL* openUrl = nil;
            for (NSURL* u in self.openUrlBookmarks) {
                if ([u.path isEqualToString:selectedItem.fileUrl.path]) {
                    [TCABookmarkHelper stopAccessingBookmarkUrl:u];
                    openUrl = u;
                }
            }
            if (openUrl != nil) {
                [self.openUrlBookmarks removeObject:openUrl];
            }  else {
            }
            
            [sidebarController removeSelectedItem];
            if ([sidebarController.items count] == 0) {
                [[self window] setIsVisible:NO];
                shallCloseAllDocuments = NO;
                [NSApp replyToApplicationShouldTerminate:YES];
            } else {
                if (shallCloseAllDocuments) {
                    [self closeFile:self];
                }
            }
        }
    }
    
}



- (IBAction)selectNextFile:(id)sender {
    
    [sidebarController selectItemAtIndex:sidebarController.selectedIndex + 1];
    
}

- (IBAction)selectPreviousFile:(id)sender {
    
    [sidebarController selectItemAtIndex:sidebarController.selectedIndex - 1];
    
}

- (BOOL)windowShouldClose:(NSWindow *)awindow {
    if (!shallCloseAllDocuments) {
        // return NO;
    }
    if ([self.sidebarController.items count] > 1) {
        shallCloseAllDocuments = YES;
    }
    [self closeFile:nil];
    return NO;
}

- (IBAction) openRecentItem: (id) sender {
    
    if ([sender tag] > 10) {
        //clear menu
        [recentItemsUrls removeAllObjects];
        [recentItemsBookmarks removeAllObjects];
        [self addRecentItem:nil];
    } else if ([sender tag] >= recentItemsBookmarks.count) {
    } else {
        NSData* openBookmark = recentItemsBookmarks[[sender tag]];
        NSURL* openUrl = [TCABookmarkHelper urlForBookmarkData:openBookmark];
        if (openUrl == nil) {
            return;
        }
        [self addRecentItem:openUrl];
        if ([openUrl respondsToSelector:@selector(startAccessingSecurityScopedResource)]) {
            [openUrl startAccessingSecurityScopedResource];
            [self.openUrlBookmarks addObject:openUrl];
        }
        
        NSString* filePath = openUrl.path;
        TCSideBarItem* newSideBarItem = [[TCSideBarItem alloc] initWithFilePath:filePath];
        newSideBarItem.isDirty = NO;
        newSideBarItem.isModified = NO;
        [sidebarController addItem:newSideBarItem atIndex:0 andSelect:YES];
        lastUsedPath = openUrl;
    }
    
}

- (IBAction) showPreferences:(id)sender {
    
    if (self.preferencesController == nil) {
        preferencesController = [[TCPreferencesController alloc] init];
    }
    [preferencesController showWindow:self];
    
}

- (IBAction) open: (id) sender {
    
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setMessage:@"Press \"cmd + shift + .\" to show/hide hidden files."];
    [oPanel setAllowsMultipleSelection:YES];
    [oPanel setCanChooseDirectories:NO];
    [oPanel setCanChooseFiles:YES];
    [oPanel setCanCreateDirectories:NO];
    if ([[self window] isVisible] == NO) {
        //no file open
        textViewController.textStorage = [[TCTextStorage alloc] initWithString:@""];
        
    }
    [oPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        [self openPanelDidEnd:oPanel returnCode:result contextInfo:nil];
    }];
    
}


- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    
	if (returnCode == NSFileHandlingPanelOKButton) {
        
        NSArray* selectedUrls = [sheet URLs];
        for (NSURL* url in selectedUrls) {
            NSString* filePath = [url path];
            TCSideBarItem* newSideBarItem = [[TCSideBarItem alloc] initWithFilePath:filePath];
            newSideBarItem.isDirty = NO;
            newSideBarItem.isModified = NO;
            [sidebarController addItem:newSideBarItem atIndex:0 andSelect:YES];
            lastUsedPath = url;
        }
        
	} else if (returnCode == NSFileHandlingPanelCancelButton) {
        
        if ([[sidebarController items] count] == 0) {
            [self newFile:self];
        }
        
    }
    
}


- (IBAction) saveAs: (id) sender {
    //first save
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setMessage:@"Press \"cmd + shift + .\" to show/hide hidden files."];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setExtensionHidden:NO];
    
    
    NSString* openPath = NSHomeDirectory();
    if (selectedItem.filePath != nil) {
        openPath = [selectedItem.filePath stringByDeletingLastPathComponent];
    }
    [savePanel setDirectoryURL:[NSURL fileURLWithPath:openPath]];
    
    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        [self savePanelDidEnd:savePanel returnCode:result contextInfo:nil];
    }];
    
    if (selectedItem.filePath == nil) {
        NSString* extension = [textViewController.syntaxColoring fileExtensionFollowingSyntaxDefinition];
        [savePanel setNameFieldStringValue:[NSString stringWithFormat:@"%@.%@", selectedItem.topTitle, extension]];
    } else {
        [savePanel setNameFieldStringValue:[NSString stringWithFormat:@"%@", selectedItem.topTitle]];
    }
}

- (IBAction) save: (id) sender {
    
    BOOL syntaxDefNeedsUpdate = NO;
    
    if (selectedItem.filePath == nil) {
        //first save
        syntaxDefNeedsUpdate = YES;
        NSSavePanel* savePanel = [NSSavePanel savePanel];
        [savePanel setTitle:@"Where do you want to save this file?"];
        [savePanel setCanCreateDirectories:YES];
        [savePanel setExtensionHidden:NO];
        NSString* extension = [textViewController.syntaxColoring fileExtensionFollowingSyntaxDefinition];
        
        [savePanel setNameFieldStringValue:[NSString stringWithFormat:@"%@.%@", selectedItem.topTitle, extension]];
        NSString* openPath = NSHomeDirectory();
        if (lastUsedPath != nil) {
            openPath = [[lastUsedPath path] stringByDeletingLastPathComponent];
        }
        [savePanel setDirectoryURL:[NSURL fileURLWithPath:openPath]];
        
        [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
            [self savePanelDidEnd:savePanel returnCode:result contextInfo:nil];
        }];
        
        NSText* editor = [savePanel fieldEditor:NO forObject:nil];
        if (editor != nil) {
            NSString* nameFieldString = [savePanel nameFieldStringValue];
            NSString* nameFieldExt = [nameFieldString pathExtension];
            if (nameFieldExt != nil && [nameFieldExt length] > 0) {
                NSInteger newLength = [nameFieldString length]-[nameFieldExt length]-1;
                [editor setSelectedRange:NSMakeRange(0, newLength)];
            }
        }
        
    } else {

        NSFileManager* fm = [NSFileManager defaultManager];

        NSError* error;
        BOOL success = YES;
        //appstore has sandbox. sandbox will always return no access for fm methods

        //we have permissions
        if (!isSavingUnderNewName && [fm fileExistsAtPath:selectedItem.filePath]) {
            //this is to update an existing file so label and creation date are preserved (as well as rights?)
            isSavingUnderNewName = NO;
            NSData* textData = [[textViewController textViewString] dataUsingEncoding:selectedItem.encoding];
            if (textData == nil) {
                success = NO;
                NSDictionary* dict = @{NSLocalizedDescriptionKey: @"Sorry, but the file could not be saved because the text encoding does not match the text. Please convert the file to an UTF encoding and try again."};
                error = [NSError errorWithDomain:@"TinctaError" code:41 userInfo:dict];

            } else {
                NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:selectedItem.filePath];
                @try {
                    [fileHandle writeData:textData];
                    [fileHandle truncateFileAtOffset:[fileHandle offsetInFile]];
                    [fileHandle closeFile];
                }
                @catch (NSException *exception) {
                    success = NO;
                    NSDictionary* dict = @{NSLocalizedDescriptionKey: @"Sorry, but the file could not be saved for unknown reason. Try using the \"Save as...\" command"};
                    error = [NSError errorWithDomain:@"TinctaError" code:42 userInfo:dict];
                }
            }
        } else {
            syntaxDefNeedsUpdate = YES;
            isSavingUnderNewName = NO;
            success = [[textViewController textViewString] writeToFile:selectedItem.filePath atomically:YES encoding:selectedItem.encoding error:&error];
        }


        if (NO == success) {

            [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_yelling.icns"]];
            NSAlert* alert = [NSAlert alertWithError:error];
            [alert setIcon:[NSImage imageNamed:@"app_icon_yelling"]];
            [alert runModal];
            [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];
            return;
        }
        //if success
        
        selectedItem.isDirty = NO;
        selectedItem.isModified = NO;
        NSDictionary* attributes = [fm attributesOfItemAtPath:selectedItem.filePath error:NULL];
        NSDate* modDate = attributes[NSFileModificationDate];
        selectedItem.lastSaveDate = modDate;       
        selectedItem.textStorage = textViewController.textStorage;
        
        if (selectedItem.syntaxColorName == nil) {
            [textViewController setSyntaxDefinitionByFileExtension: [[sidebarController.selectedItem filePath] pathExtension]];
        }
        
        [self addRecentItem:[selectedItem fileUrl]];
        
        if (needsToCloseAfterSave) {
            needsToCloseAfterSave = NO;
            [self closeFile:self];
        }
        [[self window] setTitle:[NSString stringWithFormat:@"Tincta - %@", selectedItem.filePath]];
        
        BOOL isAllSaved = YES;
        for (TCSideBarItem* sbItem in sidebarController.items) {
            if (sbItem.isDirty) {
                isAllSaved = NO;
                break;
            }
        }
        [[self window] setDocumentEdited:!isAllSaved];
        
        [sidebarController reload];
        [self animateInkIcon];
    }
    
    if (syntaxDefNeedsUpdate) {
        //set right syntax definition and recolor document
        //TODO: syntaxDef update only at one position
        [textViewController.syntaxColoring setSyntaxDefinitionByFileExtension:[[sidebarController.selectedItem filePath] pathExtension]];
        selectedItem.syntaxColorName = [textViewController.syntaxColoring syntaxDefinition];
        [textViewController.syntaxColoring colorDocument];
        [textViewController updateSyntaxDefinitionMenu];
    }
    
    [self updateStatusText];
    
}


- (IBAction) revertToSaved:(id)sender {
    
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_app_icon_yelling.icns"]];
    NSAlert* alert = [NSAlert alertWithMessageText:@"Really Revert?" defaultButton:@"Cancel" alternateButton:@"Revert" otherButton:nil informativeTextWithFormat:@"Reerting your document will restore the last saved version from your disk. Any unsaved changes will be lost."];
    [alert setIcon:[NSImage imageNamed:@"app_app_icon_yelling"]];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:@"RevertToSavedAlert"];
    
}


- (IBAction) openInBrowser: (id) sender {
    
    if (selectedItem == nil) {
        //first save
        [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_app_icon_yelling.icns"]];
        NSAlert* alert = [NSAlert alertWithMessageText:@"No file" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You have no file selected. This should never have happended. I don't tell if you don't tell, or else..."];
        [alert setIcon:[NSImage imageNamed:@"app_app_icon_yelling"]];
        [alert runModal];
        [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];
        
    } else if (selectedItem.filePath == nil) {
        //first save
        [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_app_icon_yelling.icns"]];
        
        NSAlert* alert = [NSAlert alertWithMessageText:@"Better safe than sorry" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You need to save your file before you can open it in the browser."];
        [alert setIcon:[NSImage imageNamed:@"app_app_icon_yelling"]];
        [alert runModal];
        
        [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];
        
    } else {
            
        char *URL = "https://www.apple.com";
        FSRef appRef;
        CFURLRef appURL;
        CFStringRef urlStr = CFStringCreateWithCString(NULL, URL, kCFStringEncodingASCII);
        CFURLRef inURL = CFURLCreateWithString(NULL, urlStr, NULL);
        
        OSStatus err = LSGetApplicationForURL(inURL, kLSRolesEditor, &appRef, &appURL);
        if (inURL != nil) {
            CFRelease(inURL);
        }
        if (urlStr != nil) {
            CFRelease(urlStr);
        }
        
        if (err) {
            NSLog(@"caught error opening file in browser");
            NSRunAlertPanel(@"Could not open", @"Sorry, but Tincta could not find your default browser. Please make sure you have set up a default browser.\nTo do so go to your browser's preferences and change your default browser to another browser and then back again.", @"OK", nil, nil);
            return;
        }
        NSURL* defaultBrowserURL = (__bridge NSURL*)appURL;
        NSString* defaultBrowserName = [[defaultBrowserURL path] lastPathComponent];
        
        if (appURL != nil) {
            CFRelease(appURL);
        }
        [[NSWorkspace sharedWorkspace] openFile:selectedItem.filePath withApplication:defaultBrowserName];
    }
}


- (BOOL)validateMenuItem:(NSMenuItem *)item {
    
    if ([item action] == @selector(openInBrowser:)) {
        return (selectedItem != nil) && (selectedItem.fileUrl != nil);
    }
    
    return YES;
    
}



- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    
	if (returnCode == NSFileHandlingPanelOKButton) {
        selectedItem.fileUrl = [NSURL fileURLWithPath:[[sheet URL] path]];
        lastUsedPath = selectedItem.fileUrl;
        isSavingUnderNewName = YES;
        [self save:self];
        
    } else {
        [NSApp replyToApplicationShouldTerminate:NO];
    }
    
}


- (IBAction) showWhatsNewInfo:(id)sender {
    NSString* whatsNewPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/WhatsNew.txt"];
    NSString* whatsNewHelp = [NSString stringWithContentsOfFile:whatsNewPath encoding:NSUTF8StringEncoding error:NULL];
    [self newFile:self];
    [textViewController setTextViewString: whatsNewHelp];
    selectedItem.isDirty = YES;
    selectedItem.isModified = NO;
    selectedItem.topTitle = @"What's New";
}


#pragma mark -
#pragma mark did end methods
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];
    NSString* context = (__bridge NSString*) contextInfo;
    if ([context isEqualToString:@"SaveBeforeClose"]) {
        if (returnCode == NSAlertDefaultReturn) {
            //save
            [[alert window] orderOut:[alert window]];
            needsToCloseAfterSave = YES;
            [self save:self];
        } else if (returnCode == NSAlertAlternateReturn) {
            //discard
            [[alert window] orderOut:[alert window]];
            [sidebarController removeSelectedItem];
            if ([sidebarController.items count] == 0) {
                [[self window] setIsVisible:NO];
                shallCloseAllDocuments = NO;
                [NSApp replyToApplicationShouldTerminate:YES];
            } else if (shallCloseAllDocuments) {
                [self closeFile:self];
            }
        } else {
            //cancel
            shallCloseAllDocuments = NO;
            [NSApp replyToApplicationShouldTerminate:NO];
        }
    }

    if ([context isEqualToString:@"FileModifiedAlert"]) {
        if (returnCode == NSAlertDefaultReturn) {
            //do nothing
            self.sidebarController.selectedItem.lastSaveDate = [NSDate date];
        } else if (returnCode == NSAlertAlternateReturn) {
            [self loadFileForItem:self.sidebarController.selectedItem];

            textViewController.textStorage = self.sidebarController.selectedItem.textStorage;
            [textViewController setSelectedTextViewRanges: self.sidebarController.selectedItem.selectedRanges];
            [textViewController scrollTextViewToPoint: self.sidebarController.selectedItem.scrollPoint];
            [textViewController makeTextViewFirstResponder];
            [self updateStatusText];
            [textViewController invalidateAllLineNumbers];
            [textViewController changeSelectedSideBarItem:selectedItem];
            selectedItem.isDirty = NO;
            selectedItem.isModified = NO;
            
            [sidebarController reload];
        }
        if (shallCloseAllDocuments) {
            [NSApp replyToApplicationShouldTerminate:NO];
            shallCloseAllDocuments = NO;
        }
    }
    
    if ([context isEqualToString:@"RevertToSavedAlert"]) {
        if (returnCode == NSAlertDefaultReturn) {
            //do nothing
        } else {
            [self loadFileForItem:self.sidebarController.selectedItem];
            textViewController.textStorage = self.sidebarController.selectedItem.textStorage;
            
            [textViewController setSelectedTextViewRanges: self.sidebarController.selectedItem.selectedRanges];
            [textViewController scrollTextViewToPoint: self.sidebarController.selectedItem.scrollPoint];
            [textViewController makeTextViewFirstResponder];
            [self updateStatusText];
            [textViewController invalidateAllLineNumbers];
            [textViewController changeSelectedSideBarItem:selectedItem];
            selectedItem.isDirty = NO;
            selectedItem.isModified = NO;
            [sidebarController reload];
        }
    }

    //set window close dot if necessary
    BOOL isAllSaved = YES;
    for (TCSideBarItem* sbItem in sidebarController.items) {
        if (sbItem.isDirty) {
            isAllSaved = NO;
            break;
        }
    }
    [[self window] setDocumentEdited:!isAllSaved];
    
}



#pragma mark -
#pragma mark notifcations




- (void) textDidChange: (NSNotification*) aNotification {
    
    [self updateStatusText];
    BOOL isAlreadyDirty = sidebarController.selectedItem.isDirty;
    
    sidebarController.selectedItem.isDirty = YES;
    sidebarController.selectedItem.isModified = YES;
    [[self window] setDocumentEdited:YES];
    if (!isAlreadyDirty) {
        [sidebarController reload];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateStatusText) userInfo:nil repeats:NO];
    
}


- (void)textViewDidChangeSelection:(NSNotification *)aNotification {
    
    [self updateStatusText];
    
}


- (void) sideBarItemsDidChange {
}


- (void) sideBarSelectionDidChange:(NSInteger)selectedIndex {
    

    //!!! caution with the order, selectedIndex could be out of bounds!
    
    TCSideBarItem* item = nil;
    if (selectedIndex >= 0 && selectedIndex < [sidebarController.items count]) {
        item = (sidebarController.items)[selectedIndex];
        
    }
    
    if (item == selectedItem) {
        return;
    }
    
    //save changes to last selected
    if (selectedItem != nil) {
        //@performace copy only when changed -> item flag with textview did change delegate?
        
        // Has to be done everytime since we can not replace the TextStorage in Mavericks

        selectedItem.textStorage = [[textViewController textStorage] copy];

        selectedItem.selectedRanges = [textViewController selectedTextViewRanges];
        selectedItem.scrollPoint = [textViewController textViewScrollPoint];
    }
    //load file
    if (item == nil) {
        return;
    }
    selectedItem = item;
    
    if (selectedItem.textStorage != nil && selectedItem.filePath != nil && selectedItem.lastSaveDate != nil) {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSDictionary* attributes = [fm attributesOfItemAtPath:selectedItem.filePath error:NULL];
        NSDate* modDate = attributes[NSFileModificationDate];
        if ([modDate isGreaterThan:selectedItem.lastSaveDate]) {
            if (item.isModified) {
                
                [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_yelling.icns"]];
                NSAlert* alert = [NSAlert alertWithMessageText:@"File modified" defaultButton:@"Keep this version" alternateButton:@"Load modified version" otherButton:nil informativeTextWithFormat:@"The file \"%@\" has been modified by another application. Do you want to load the new version from disk? (All unsaved changes will be lost.)", [selectedItem.filePath lastPathComponent]];
                [alert setIcon:[NSImage imageNamed:@"app_icon_yelling"]];
                [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:@"FileModifiedAlert"];
                
                textViewController.textStorage = self.sidebarController.selectedItem.textStorage;
                [textViewController setSelectedTextViewRanges: item.selectedRanges];
                [self updateStatusText];
                [textViewController changeSelectedSideBarItem:selectedItem];
                
                return;
            } else {
                [self loadFileForItem:self.sidebarController.selectedItem];
                
            }
        }
    }
    
    if (selectedItem.textStorage == nil) {
        BOOL success = [self loadFileForItem: selectedItem];
        if (!success) {
            return;
        }
    }
    
    NSMutableString* title = [NSMutableString stringWithString: @"Untitled"];
    if (selectedItem.fileUrl != nil) {
        
        NSArray* otherComponents = [[selectedItem fileUrl] pathComponents];
        title = [NSMutableString stringWithCapacity:32];
        int c = 0;
        for (NSInteger i = ([otherComponents count] - 1); i >= 0; i--) {
            [title insertString:[NSString stringWithFormat:@"%@/",otherComponents[i]] atIndex:0];
            c++;
            if (c == 3) {
                [title deleteCharactersInRange:NSMakeRange([title length]-1, 1)];
                break;
            }
        }
    }
    [[self window] setTitle:[NSString stringWithFormat:@"Tincta - %@", title]];

    textViewController.textStorage = selectedItem.textStorage;
    [textViewController setSelectedTextViewRanges: selectedItem.selectedRanges];

    [textViewController makeTextViewFirstResponder];
    [textViewController changeSelectedSideBarItem:selectedItem];

    if ([self.searchController isActive]) {
        [self.searchController markAllOccurrences];
    }
    
    [self updateStatusText];
}


- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    return frameSize;
}


- (void)windowDidResignKey:(NSNotification *)notification {
    appIsActive = NO;
    [self.statusView setActive:NO];
}


- (void)windowDidBecomeKey:(NSNotification *)notification {
    [self.statusView setActive:YES];
    if (!appIsActive && selectedItem != nil) {
        TCSideBarItem* item = selectedItem;
        
        if (item.textStorage != nil && selectedItem.filePath != nil && selectedItem.lastSaveDate != nil) {
            NSFileManager* fm = [NSFileManager defaultManager];
            NSDictionary* attributes = [fm attributesOfItemAtPath:selectedItem.filePath error:NULL];
            NSDate* modDate = attributes[NSFileModificationDate];
            if ([modDate isGreaterThan:selectedItem.lastSaveDate]) {
                if (item.isModified) {
                    
                    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_yelling.icns"]];
                    NSAlert* alert = [NSAlert alertWithMessageText:@"File modified" defaultButton:@"Keep this version" alternateButton:@"Load modified version" otherButton:nil informativeTextWithFormat:@"The file \"%@\" has been modified by another application. Do you want to load the new version from disk? (All unsaved changes will be lost.)", [selectedItem.filePath lastPathComponent]];
                    [alert setIcon:[NSImage imageNamed:@"app_icon_yelling"]];
                    
                    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:@"FileModifiedAlert"];
                    appIsActive = YES;
                    
                    return;
                } else {
                    [self loadFileForItem:self.sidebarController.selectedItem];
                    textViewController.textStorage = self.sidebarController.selectedItem.textStorage;
                    
                }
                [textViewController.syntaxColoring colorDocument];
            }
            
            
            [textViewController makeTextViewFirstResponder];
        }
        
    }
    appIsActive = YES;
    
}



#pragma mark -
#pragma mark helpers


- (IBAction) customizeToolbar: (id) sender {
    [self.toolbar runCustomizationPalette:sender];
}


- (void) addRecentItem: (NSURL*) anUrl {
    
    if (recentItemsUrls == nil) {
        recentItemsUrls = [NSMutableArray arrayWithCapacity:11];
    }
    if (recentItemsBookmarks == nil) {
        recentItemsBookmarks = [NSMutableArray arrayWithCapacity:11];
    }
    if (anUrl != nil) {
        //find if existing (check for equal not identity!)
        NSInteger urlIndex = NSNotFound;
        for (NSInteger i = 0; i < recentItemsUrls.count; i++) {
            NSURL* u = recentItemsUrls[i];
            if ([u.path isEqualTo:anUrl.path]) {
                urlIndex = i;
                break;
            }
        }
        NSData* bookmark = nil;
        if (urlIndex != NSNotFound) {
            bookmark = recentItemsBookmarks[urlIndex];
            [recentItemsUrls removeObjectAtIndex:urlIndex];
            [recentItemsBookmarks removeObjectAtIndex:urlIndex];
        } else {
            bookmark = [TCABookmarkHelper bookmarkForUrl: anUrl];
        }
        if (bookmark != nil) {
            [recentItemsUrls insertObject:anUrl atIndex:0];
            [recentItemsBookmarks insertObject:bookmark atIndex:0];
            if ([recentItemsUrls count] > 10) {
                [recentItemsUrls removeObjectAtIndex:(recentItemsUrls.count - 1)];
                [recentItemsBookmarks removeObjectAtIndex:(recentItemsBookmarks.count - 1)];
            }
        } else {
            NSLog(@"mwc > addRecentItem %@ > could not create bookmark", anUrl);
        }
    }
    
    
    NSMenu* recentMenu = [[NSMenu alloc] initWithTitle:@"Open Recent"];
    NSInteger tag = 0;
    for (NSURL* recentUrl in recentItemsUrls) {
        NSArray* otherComponents = [recentUrl pathComponents];
        NSMutableString* title = [NSMutableString stringWithCapacity:32];
        int c = 0;
        for (NSInteger i = ([otherComponents count] - 1); i >= 0; i--) {
            [title insertString:[NSString stringWithFormat:@"%@/",otherComponents[i]] atIndex:0];
            c++;
            if (c == 3) {
                [title deleteCharactersInRange:NSMakeRange([title length]-1, 1)];
                break;
            }
        }
        
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:@selector(openRecentItem:) keyEquivalent:@""];
        [item setTag:tag];
        [recentMenu addItem:item];
        tag++;
    }
    
    [recentMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:@"Clear Menu" action:@selector(openRecentItem:) keyEquivalent:@""];
    [item setTag:11];
    [recentMenu addItem:item];
    [self.fileMenu setSubmenu:recentMenu forItem:self.recentItemsMenuItem];
    

    [TCADefaultsHelper setRecentItemsBookmarks:recentItemsBookmarks];
}


- (void) updateStatusText {
    
    if (selectedItem == nil) {
        [self.statusTextField setStringValue:@"No file open, how did you do this?"];
        return;
    }
    
    NSString* encodingText = [NSString localizedNameOfStringEncoding:selectedItem.encoding];
    NSInteger linesCount = [textViewController numberOfLines];
    NSInteger charCount = [[textViewController textViewString] length];
    NSInteger lineNumber = [textViewController selectedLine];
    NSInteger posInLine = [textViewController selectedCharLocationInLine:lineNumber];
    NSInteger selPos = [[textViewController selectedTextViewRanges][0] rangeValue].location;
    NSInteger selLength = [[textViewController selectedTextViewRanges][0] rangeValue].length;
    NSString* statusText;
    if (selLength == 0) {
        statusText = [NSString stringWithFormat:@"Char: %ld / %ld     Line: %ld:%ld / %ld     Encoding: %@     Syntax: %@", selPos, charCount, (lineNumber + 1),posInLine,  linesCount, encodingText, selectedItem.syntaxColorName];
    } else {
        statusText = [NSString stringWithFormat:@"Char: (%ld,%ld) / %ld     Line: %ld:%ld / %ld     Encoding: %@     Syntax: %@", selPos, selLength, charCount, (lineNumber + 1),posInLine,  linesCount, encodingText, selectedItem.syntaxColorName];
    }
    [self.statusTextField setStringValue:statusText];

}


- (BOOL) loadFileForItem: (TCSideBarItem*) anItem {
    
    NSString* path = anItem.filePath;
    
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError* error;
    NSString* fileContent;
    if (path != nil) {
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSMutableDictionary* attDict = [NSMutableDictionary dictionaryWithDictionary:[fm attributesOfItemAtPath:path error:NULL]];
        if (attDict[(NSString*)kLSItemQuarantineProperties] != nil) {
            NSLog(@"loadind file in quarantine");
            [attDict removeObjectForKey:(NSString*)kLSItemQuarantineProperties];
            [fm setAttributes:attDict ofItemAtPath:path error:NULL];
        }
        
        if ([fm fileExistsAtPath:path] && ![fm isReadableFileAtPath:path]) {
            [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_yelling.icns"]];
            NSAlert* alert = [NSAlert alertWithMessageText:@"Permission needed" defaultButton:@"Cancel" alternateButton:@"Authenticate" otherButton:nil informativeTextWithFormat:@"You do not have sufficient rights to open the file \"%@\". You can authenticate as another user or admin to gain access.\nBe careful modifying system files as this might cause severe demage.", [path lastPathComponent]];
            [alert setIcon:[NSImage imageNamed:@"app_icon_yelling"]];
            NSInteger returnValue = [alert runModal];
            [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];
            if (returnValue == NSAlertAlternateReturn) {
                NSTask *task = [[NSTask alloc] init];
                NSPipe *pipe = [[NSPipe alloc] init];
                NSFileHandle *fileHandle = [pipe fileHandleForReading];
                
                [task setLaunchPath:@"/usr/libexec/authopen"];
                [task setArguments:@[path]];
                [task setStandardOutput:pipe];
                
                [task launch];
                
                NSData *data = [[NSData alloc] initWithData:[fileHandle readDataToEndOfFile]];;
                
                [task waitUntilExit];
                NSInteger status = [task terminationStatus];
                
                if (status != 0) {
                    NSRunAlertPanel(@"Error", @"Could not open the file. Please check permissions.", @"OK", nil, nil);
                    [sidebarController removeItem:anItem];
                    anItem.textStorage = nil;
                    return NO;
                }
                fileContent = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            } else {
                [sidebarController removeItem:anItem];
                anItem.textStorage = nil;
                return NO;
            }
        } else {
            
            fileContent = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
        }
        
        lastUsedPath = [NSURL fileURLWithPath:path];
        [self addRecentItem:lastUsedPath];
        
        
        if ([fileContent length] > 5000000) {
            //over 5mb
            
            if (NO == [TCADefaultsHelper getDontShowBinaryWarning]) {
                
                [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_yelling.icns"]];
                NSAlert* alert = [NSAlert alertWithMessageText:@"Wow, that's a big one!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat: @"The file \"%@\" is very large. If you encounter performance problems disabling line numbering or line wrapping in the preferences will help. \n(You can disable this warning in the Preferences)", [path lastPathComponent]];
                [alert setIcon:[NSImage imageNamed:@"app_icon_yelling"]];
                
                [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
            }
        }
        
        NSDictionary* attributes = [fm attributesOfItemAtPath:selectedItem.filePath error:NULL];
        NSDate* modDate = attributes[NSFileModificationDate];
        anItem.lastSaveDate = modDate;
    } else {
        //new file has no path
        fileContent = @"";
    }
    
    if (fileContent == nil) {
        //probably binary file that can't be opened
        //load data
        NSInteger returnValue = NSAlertAlternateReturn;
        if (NO == [TCADefaultsHelper getDontShowBinaryWarning]) {
            [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_yelling.icns"]];
            
            NSAlert* alert = [NSAlert alertWithMessageText:@"Really open binary?" defaultButton:@"Cancel" alternateButton:@"I said, open it!" otherButton:nil informativeTextWithFormat:@"The file \"%@\" appears to be in binary format. Loading might take some time and probably you won't be able to read the contents anyway. \n(You can disable this warning in the Preferences)", [path lastPathComponent]];
            [alert setIcon:[NSImage imageNamed:@"app_icon_yelling"]];
            returnValue = [alert runModal];
            [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];
        }
        if (returnValue == NSAlertAlternateReturn) {
            NSData* data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&error];
            if (data == nil) {
                //error reading dataaor
                [sidebarController removeItem:anItem];
                anItem.textStorage = nil;
                [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_yelling.icns"]];
                NSAlert* alert = [NSAlert alertWithError:error];
                [alert setIcon:[NSImage imageNamed:@"app_icon_yelling"]];
                [alert runModal];
                [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];
                return NO;
            } else {
                fileContent = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                encoding = NSASCIIStringEncoding;
                anItem.isBinary = YES;
                
                [textViewController makeTextViewFirstResponder];
            }
        } else {
            //clicked cancel -> don't load
            [sidebarController removeItem:anItem];
            anItem.textStorage = nil;
            return NO;
        }
    }
    anItem.encoding = encoding;
    anItem.textStorage = [[TCTextStorage alloc] initWithString:fileContent];
    anItem.undoManager = [[NSUndoManager alloc] init];
    
    return YES;
    
}


- (void) bringWindowToFront {
    [[self window] setIsVisible:YES];
	[[self window] orderFront:[self window]];
}


#pragma mark -
#pragma mark SplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    
    if ([[splitView subviews][0] isEqualTo:subview]) {
        return YES;
    }
    return NO;
    
}


- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
    
    if (dividerIndex == 0) {
        return proposedMax/3;
    }
    return proposedMax;
    
}


- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    
    if (dividerIndex == 0) {
        return proposedMin + 50;
    }
    return proposedMin;
    
}


- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    
    if ([[splitView subviews][0]isEqualTo:subview]) {
        return YES;
    }
    return NO;
    
}


- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    
    if (!isAwakeFromNib) {
        [splitView adjustSubviews];
        return;
    }
    NSSize splitViewSize = [splitView frame].size;
    NSSize sideBarSize = [[splitView subviews][0]frame].size;
    
    if ([splitView isSubviewCollapsed:[splitView subviews][0]]) {
        sideBarSize.width = 0;
    }
    
    sideBarSize.height = splitViewSize.height;
    
    NSSize textViewSize;
    textViewSize.height = splitViewSize.height;
    textViewSize.width = splitViewSize.width - [splitView dividerThickness] -
    sideBarSize.width;
    [[splitView subviews][0] setFrameSize:sideBarSize];
    [[splitView subviews][1] setFrameSize:textViewSize];
    
}


- (void) animateInkIcon {
    
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_ink1.icns"]];
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(animateInkIconTwo) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(animateInkIconThree) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(animateInkIconFour) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(animateInkIconReset) userInfo:nil repeats:NO];
    
}


- (void) animateInkIconTwo {
    
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_ink2.icns"]];
    
}


- (void) animateInkIconThree {
    
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_ink3.icns"]];
    
}


- (void) animateInkIconFour {
    
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_ink4.icns"]];
    
}


- (void) animateInkIconReset {
    
    [NSApp setApplicationIconImage:[NSImage imageNamed:@"app_icon_running.icns"]];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
