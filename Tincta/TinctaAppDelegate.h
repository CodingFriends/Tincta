//
//  TinctaAppDelegate.h
//  Tincta
//
//  Created by Mr. Fridge on 4/15/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController;

@interface TinctaAppDelegate : NSObject <NSApplicationDelegate> {
    
@private
    NSWindow *__strong window;
    
}

@property (assign) IBOutlet MainWindowController *mainWindowController;
@property (strong) IBOutlet NSWindow *window;

//- (id)init;
- (void)setUserDefaultValues;
- (void)applicationWillTerminate:(NSNotification *)aNotification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (IBAction) openRecentItem: (id) sender;
-(BOOL)isInternetAvail;
- (IBAction)openWebsite:(id)sender;

+ (BOOL)isInternetAvailable;

@end
