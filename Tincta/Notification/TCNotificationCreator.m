//
//  TCNotificationCreator.m
//  tincta
//
//  Created by Mr. Fridge on 5/24/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import "TCNotificationCreator.h"
#import "TCNotificationBackground.h"

@implementation TCNotificationCreator

@synthesize displayTime;




- (id) init {
    if (self) {
        self.displayTime = 1.0;
    }
    [NSBundle loadNibNamed:@"Notification" owner:self];

    return self;
}

- (void) awakeFromNib {
    [[self window] setStyleMask:NSBorderlessWindowMask];
    [[self window] setBackgroundColor:[NSColor clearColor]];//this is important
    [[[[self window] contentView] layer] setOpacity:0];
    
    [[self window] setOpaque:NO]; //this is not important
    [[self window] orderFrontRegardless];
    
    [[self window] setLevel:NSNormalWindowLevel];
    [[self window] setIsVisible:NO];
    [[self window] setIgnoresMouseEvents:YES];
    self.displayTime = 1.0;
}

- (void) setNotificationSize: (NSSize) aSize {
    [[self window] setFrame: NSMakeRect(0, 0, aSize.width, aSize.height) display:YES];
    [[self window] center];
}

- (void) showNotificationWithMessage: (NSString*) msg andImage: (NSImage*) img {
    
    [messageLabel setStringValue:msg];
    [notificationImage setImage:img];
    [[self window] center];
    [[self window] setLevel:NSFloatingWindowLevel];

    [[self window] setIsVisible:YES];
    [[[[self window] contentView] layer] setOpacity:0.9];

    [NSTimer scheduledTimerWithTimeInterval: self.displayTime target:self selector:@selector(fadeNotification) userInfo:nil repeats:NO];
}

- (void) showNotificationWithMessage: (NSString*) msg andImage: (NSImage*) img centredInFrame: (NSRect) aFrame {
    [messageLabel setStringValue:msg];
    [notificationImage setImage:img];
    
    CGFloat xPos = aFrame.origin.x + (aFrame.size.width - [[self window] frame].size.width)/2;
    
    CGFloat yPos = aFrame.origin.y - (aFrame.size.height + [[self window] frame].size.height)/2;
    
    [[self window] setFrameOrigin:NSMakePoint(xPos, yPos)];
    [[self window] setLevel:NSFloatingWindowLevel];
    [[self window] setIsVisible:YES];
    [[[[self window] contentView] layer] setOpacity:0.9];

    [NSTimer scheduledTimerWithTimeInterval:self.displayTime target:self selector:@selector(fadeNotification) userInfo:nil repeats:NO];
}

- (void) fadeNotification {
    //[[self window] setLevel:NSNormalWindowLevel];

    [[[[self window] contentView] layer] setOpacity:0];
}

+ (TCNotificationCreator*)sharedManager {
    
    static TCNotificationCreator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TCNotificationCreator alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}



@end
