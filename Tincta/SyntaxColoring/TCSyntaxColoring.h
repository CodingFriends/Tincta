//
//  TCSyntaxColoring.h
//  TCSyntaxColoring
//
//  Created by Julius Peinelt on 11.12.11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import <Foundation/Foundation.h>

@class TCAScanner, TCTextView, TCTextStorage, LexicalState, TCStateFactory, TCTextAttributesFactory;

@interface TCSyntaxColoring : NSObject {
    
    TCAScanner* scanner;
    TCTextView* textView;
    TCStateFactory* stateFactory;
    TCTextAttributesFactory* attributesFactory;
    
    NSString* textViewString;
    NSMutableArray* parsedTextStates;
        
    NSString* syntaxDefinition;

    LexicalState* lexicalState;
    
    NSMutableArray* availableSyntaxDefinitions;
    
    NSSet* keywordSet;
    BOOL isKeywordsCaseInsensitive;
    
    NSSet* predefinedDelimSet;
    NSMutableSet *predefinedSet;
    
    NSSet* attributesDelimSet;
    BOOL isAttributesOnlyInTagsAndBlocks;
    
    NSArray *singleLineStrings;
    NSArray *multiLineStrings;
    NSArray* charStrings;
    
    NSArray* singleLineComments;
    NSArray* multiLineComments;
    
    NSArray* tags;
    NSArray* blocks;
    
    NSArray* variablesDelimArray;
    NSMutableSet* variablesSet;
    BOOL isVariablesDelimPartOfVar;
    
    BOOL isColoringOnlyInBlocksAndTags;
    
    BOOL isAttributeColoringInBlocks;

    NSDictionary* textColor;
    NSDictionary* keywordsColor;
    NSDictionary* predefinedColor;
    NSDictionary* stringsColor;
    NSDictionary* commentsColor;
    NSDictionary* tagsColor;
    NSDictionary* blocksColor;
    NSDictionary* attributesColor;
    NSDictionary* variablesColor;
     
    NSMutableCharacterSet* wordBeginningSet;
    NSCharacterSet* wordEndingSet;
    NSMutableCharacterSet* attributesCharSet;
    NSMutableCharacterSet* stringBeginningSet;
    NSMutableCharacterSet* commentBeginningSet;
    NSMutableCharacterSet* tagBlockBeginningSet;
    NSMutableCharacterSet* tagBlockEndingSet;
    
    //recoloring help objects/variables
    NSTimer* recolorTimer;
    BOOL timerSet;
    NSInteger lastBeginningOfColoring;
    
    NSRange dragNdropRange;
    
}

@property (strong) NSString* syntaxDefinition;

//init
- (id)initWithTextView:(TCTextView* )aTextView;
- (void)initSyntaxColors;
- (void)setSyntaxDefinitionByName:(NSString* )definitionName;
- (void)loadDefinitionDictionary:(NSDictionary* )syntDict;
- (NSArray* )getValidSyntaxArray:(NSArray* )syntArray;
- (void)fillSyntaxCharacterSets;
- (void)fillWordCharacterSets;
- (void)fillStringCharacterSets;
- (void)fillCommentCharacterSets;
- (void)fillTagAndBlockCharacterSets;
- (void)setSyntaxDefinitionByFileExtension:(NSString* )fileExtension;

//coloring
- (void)textStorageDidChangeText:(NSNotification* )aNotification;
- (NSRange) getColoringRangeForChangedText:(NSRange)changedRange;
- (NSInteger)getLocationOfLastVisibleCharacter;
- (void)colorDocument;
- (NSInteger)colorRange:(NSRange)r;
- (void)colorWords;
- (void)parseNewPredefined;
- (void)parseNewVariable;
- (void)colorStrings;
- (void)colorOpenMultiLineString;
- (void)colorComments;
- (void)colorOpenMultiLineComment;
- (void)colorTagsAndBlocksBeginning;
- (void)colorTagsAndBlocksEnding;

//coloring intern
- (void)colorizeWithColor:(NSDictionary* )color inRange:(NSRange)range;
- (void)addCurrentStateToParsedStatesInRange:(NSRange)range;

//intern helpers
- (NSString* )fileExtensionFollowingSyntaxDefinition;

// extern helpers
- (NSString*)getSingleLineCommentToken;
- (NSArray*)getMultiLineCommentToken;


@end
