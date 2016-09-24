//
//  NSSideBarItem.m
//  Watersnake
//
//  Created by Mr. Fridge on 3/25/11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "TCSideBarItem.h"
#import "TCTextStorage.h"
#import <QuickLook/QuickLook.h>

@implementation TCSideBarItem

@synthesize image, topTitle, bottomTitle, fileUrl, filePath;
@synthesize encoding, selectedRanges, isBinary;
@synthesize syntaxColorName, scrollPoint, isDirty, isModified, lastSaveDate;
@synthesize fileAttributes, undoManager, textStorage;
@synthesize numberOfSearchResults;

- (id)initWithImage: (NSImage*) theImage topTitle: (NSString*) theTopTitle andBottomTitle: (NSString*) theBottomTitle {
    self = [super init];
    if (self) {
        self.image = theImage;
        
        self.topTitle = theTopTitle;
        self.bottomTitle = theBottomTitle;
        
        self.textStorage = nil;
        NSStringEncoding enc = NSUTF8StringEncoding;
        self.encoding = enc;
        self.selectedRanges = @[[NSValue valueWithRange:NSMakeRange(0, 0)]];
        self.isBinary = NO;
        self.syntaxColorName = nil;
        self.scrollPoint = NSZeroPoint;
        self.isDirty = NO;
        self.isModified = NO;
        self.lastSaveDate = nil;
        self.fileAttributes = nil;
        self.undoManager = [[NSUndoManager alloc] init];
        self.numberOfSearchResults = 0;
    }
    return self;
}

- (id)initWithFilePath: (NSString*) theFilePath {
    self = [super init];
    if (self) {
        self.filePath = theFilePath;
        self.topTitle = [self.filePath lastPathComponent];
        NSRange lastOccurenceLoc = [self.filePath rangeOfString:self.topTitle options:NSBackwardsSearch];
        self.bottomTitle = [self.filePath stringByReplacingCharactersInRange:lastOccurenceLoc withString:@""];
        
        self.textStorage = nil;
        NSStringEncoding enc = NSUTF8StringEncoding;
        self.encoding = enc;
        self.selectedRanges = @[[NSValue valueWithRange:NSMakeRange(0, 0)]];
        self.isBinary = NO;
        self.syntaxColorName = nil;
        self.scrollPoint = NSZeroPoint;
        self.isDirty = NO;
        self.isModified = NO;
        self.lastSaveDate = nil;
        self.undoManager = [[NSUndoManager alloc] init];
        self.numberOfSearchResults = 0;
    }
    return self;
}


- (NSImage*) image {
    if (image == nil) {
        image = [NSImage imageNamed:@"GenericDocumentIcon"];
    }
    if (!isCreatingImage) {
        isCreatingImage = YES;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^{
            CGFloat iconSize = 46;
            NSDictionary* quickLookOptions = @{(NSString*)kQLThumbnailOptionIconModeKey: @YES};
            
            if (self.fileUrl != nil) {
                CGImageRef quickLookImage = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)self.fileUrl, CGSizeMake(iconSize, iconSize), (__bridge CFDictionaryRef)quickLookOptions);
                if (quickLookImage == nil) {
                    image = [[NSWorkspace sharedWorkspace] iconForFile:self.filePath];
                } else {
                    image = [[NSImage alloc] initWithCGImage:quickLookImage size:NSMakeSize(128, 128)];
                    CFRelease(quickLookImage);   //aenderung
                }
            }
            isCreatingImage = NO;
        });
    }
    return image;
}


- (void) loadAttributesOfFile {
    if (self.filePath != nil) {
        NSFileManager* fm = [NSFileManager defaultManager];
        self.fileAttributes = [fm attributesOfItemAtPath:self.filePath error:NULL];
    }
}

- (void) setFileUrl:(NSURL *)aFileUrl {
    fileUrl = aFileUrl;
    filePath = [fileUrl path];
    self.topTitle = [filePath lastPathComponent];
    NSRange lastOccurenceLoc = [self.filePath rangeOfString:self.topTitle options:NSBackwardsSearch];
    self.bottomTitle = [self.filePath stringByReplacingCharactersInRange:lastOccurenceLoc withString:@""];
    [self loadAttributesOfFile];
}

- (void) setFilePath:(NSString *)aFilePath {
    fileUrl = [NSURL fileURLWithPath:aFilePath];
    filePath = aFilePath;
    self.topTitle = [filePath lastPathComponent];
    NSRange lastOccurenceLoc = [self.filePath rangeOfString:self.topTitle options:NSBackwardsSearch];
    self.bottomTitle = [self.filePath stringByReplacingCharactersInRange:lastOccurenceLoc withString:@""];
    [self loadAttributesOfFile];
}

- copyWithZone:(NSZone *)zone {

    return self;
    /*
	TCSideBarItem *copy = [[TCSideBarItem alloc] initWithImage:self.image topTitle:self.topTitle andBottomTitle:self.bottomTitle];
    if (self.filePath != nil) {
        copy.filePath = [self.filePath copyWithZone:zone];
	}
    if (self.fileContent != nil) {
     copy.fileContent = [NSString stringWithString: self.fileContent];
     }
    
    if (self.textStorage != nil) {
        copy.textStorage = self.textStorage;
    }
    
    if (self.syntaxColorName != nil) {
        copy.syntaxColorName = [NSString stringWithString:self.syntaxColorName];
    }
    copy.encoding = self.encoding;
    //copy.selectedRange = NSMakeRange(self.selectedRange.location, self.selectedRange.length);
    copy.selectedRanges = [NSArray arrayWithArray:self.selectedRanges];
    copy.isBinary = self.isBinary && YES;
    copy.scrollPoint = self.scrollPoint;
    copy.isDirty = self.isDirty && YES;
    copy.isModified = self.isModified && YES;
    copy.lastSaveDate = [self.lastSaveDate copy];
    
    return copy;
     */
}

@end
