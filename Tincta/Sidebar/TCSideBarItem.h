//
//  NSSideBarItem.h
//  Watersnake
//
//  Created by Mr. Fridge on 3/25/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <Foundation/Foundation.h>
@class TCTextStorage;

@interface TCSideBarItem : NSObject <NSCopying> {

    NSImage* image;
    NSString* topTitle;
    NSString* bottomTitle;
    NSURL* fileUrl;
    NSString* filePath;
    
    BOOL isCreatingImage;
    
    //Tincta data
    //NSString* fileContent;
    TCTextStorage* textStorage;
    NSStringEncoding encoding;
    //NSRange selectedRange;
    NSArray *__strong selectedRanges;
    BOOL isBinary;
    NSString* syntaxColorName;
    NSPoint scrollPoint;
    BOOL isDirty;
    BOOL isModified;
    NSDate* lastSaveDate;
    NSDictionary* fileAttributes;
    NSUndoManager* undoManager;
}


@property (strong, nonatomic) NSImage* image;
@property (strong) NSString* topTitle;
@property (strong) NSString* bottomTitle;
@property (strong, nonatomic) NSURL* fileUrl;
@property (strong, nonatomic) NSString* filePath;
@property (strong) NSDictionary* fileAttributes;
@property (strong) NSUndoManager* undoManager;

//@property (retain) NSString* fileContent;
@property (strong) TCTextStorage* textStorage;

@property (assign) NSStringEncoding encoding;
//@property (assign) NSRange selectedRange;
@property (strong) NSArray *selectedRanges;
@property (assign) BOOL isBinary;
@property (strong) NSString* syntaxColorName;
@property (assign) NSPoint scrollPoint;
@property (assign) BOOL isDirty;
@property (assign) BOOL isModified;
@property (strong) NSDate* lastSaveDate;
@property (assign, nonatomic) NSInteger numberOfSearchResults;

- (void) loadAttributesOfFile;
- (id)initWithImage: (NSImage*) theImage topTitle: (NSString*) theTopTitle andBottomTitle: (NSString*) theBottomTitle;
- (id)initWithFilePath: (NSString*) theFilePath;


@end
