//
//  TCNotificationCreator.h
//  tincta
//
//  Created by Mr. Fridge on 5/24/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Foundation/Foundation.h>


@interface TCNotificationCreator : NSWindowController {

    IBOutlet NSTextField* messageLabel;
    IBOutlet NSImageView* notificationImage;
    
    CGFloat displayTime;
}


@property (assign)     CGFloat displayTime;

- (void) showNotificationWithMessage: (NSString*) msg andImage: (NSImage*) img;

- (void) showNotificationWithMessage: (NSString*) msg andImage: (NSImage*) img centredInFrame: (NSRect) aFrame;

- (void) setNotificationSize: (NSSize) aSize;
- (void) fadeNotification;
- (id) init;
+ (TCNotificationCreator*)sharedManager;



@end
