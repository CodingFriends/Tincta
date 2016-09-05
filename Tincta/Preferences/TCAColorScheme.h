//
//  TCAColorProfile.h
//  tincta
//
//  Created by Gabriel Reimers on 11/01/15.
//
//

#import <Foundation/Foundation.h>

@interface TCAColorScheme : NSObject


@property (readonly, nonatomic) NSString* name;
@property (assign, nonatomic) BOOL isUserGenerated;
@property (strong, nonatomic) NSURL* fileUrl;


@property (strong, nonatomic) NSColor* colorBackground;
@property (strong, nonatomic) NSColor* colorText;
@property (strong, nonatomic) NSColor* colorCurrentLine;
@property (strong, nonatomic) NSColor* colorSelection;

@property (strong, nonatomic) NSColor* colorComments;
@property (strong, nonatomic) NSColor* colorInvisibles;

@property (strong, nonatomic) NSColor* colorAttributes;
@property (strong, nonatomic) NSColor* colorVariables;
@property (strong, nonatomic) NSColor* colorStrings;
@property (strong, nonatomic) NSColor* colorKeywords;
@property (strong, nonatomic) NSColor* colorTags;
@property (strong, nonatomic) NSColor* colorPredefined;
@property (strong, nonatomic) NSColor* colorBlocks;

- (id) initWithContentsOfURL: (NSURL*) theUrl;
- (void) writeToUrl: (NSURL*) theUrl;
- (void) save;
- (NSURL*)duplicateWithName:(NSString*)name;
- (NSURL*)rename: (NSString*) newName;
+ (NSArray*) builtInColorSchemes;
+ (NSArray*) userColorSchemes;


@end
