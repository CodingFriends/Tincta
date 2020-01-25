//
//  TCSyntaxColoring.m
//  TCSyntaxColoring
//
//  Created by Julius Peinelt on 11.12.11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//


#import "TCSyntaxColoring.h"
#import "TCAScanner.h"
#import "TCTextView.h"
#import "TCTextStorage.h"
#import "LexicalState.h"
#import "TCStateFactory.h"
#import "TCTextAttributesFactory.h"

#import "TCAApplicationSupportHelper.h"
#import "TCAMiscHelper.h"

@implementation TCSyntaxColoring

@synthesize syntaxDefinition;


#pragma mark INIT

- (id)initWithTextView:(TCTextView *)aTextView {
    self = [super init];
    if (self) {        
        textView = aTextView;
        textViewString = [textView string];
        parsedTextStates = [NSMutableArray arrayWithCapacity:textViewString.length];
        lexicalState = [[LexicalState alloc] init];
        for (NSInteger i = 0; i  < textViewString.length; i++) {
            [parsedTextStates insertObject:lexicalState atIndex:i];
        }
        scanner = [TCAScanner scannerWithString:textViewString];
        
        stateFactory = [[TCStateFactory alloc] init];
        attributesFactory = [[TCTextAttributesFactory alloc] init];
        
        syntaxDefinition = @"Plain Text";
        availableSyntaxDefinitions = [@[] mutableCopy];
        
        [self initSyntaxColors];
        lastBeginningOfColoring = 0;
        
        dragNdropRange = NSMakeRange(0, -1);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textStorageDidChangeText:) name: @"TCTextStorageDidChangeText" object:nil];
        
    }
    return self;
}


//set colors for text coloring
- (void)initSyntaxColors {
    [attributesFactory reset];
    textColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getTextColor], NSForegroundColorAttributeName, nil];
    keywordsColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getKeywordsColor], NSForegroundColorAttributeName, nil];
    predefinedColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getPredefinedColor], NSForegroundColorAttributeName, nil];
    stringsColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getStringsColor], NSForegroundColorAttributeName, nil];
    commentsColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getCommentsColor], NSForegroundColorAttributeName, nil];
	tagsColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getTagsColor], NSForegroundColorAttributeName, nil];
    blocksColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getBlocksColor], NSForegroundColorAttributeName, nil];
	attributesColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getAttributesColor], NSForegroundColorAttributeName, nil];
    variablesColor = [[NSDictionary alloc] initWithObjectsAndKeys:[TCADefaultsHelper getVariablesColor], NSForegroundColorAttributeName, nil];
}


//first look at app sup dir then in mainbundle so users can 'override' definitions
- (void)setSyntaxDefinitionByName:(NSString *)definitionName {
    
    if (definitionName == nil) {
        syntaxDefinition = @"Plain Text";
    } else {
        syntaxDefinition = definitionName;
    }

    NSString* appSupportDefDir = [TCAApplicationSupportHelper applicationSupportSyntaxDefinitionsDirectory];
    NSDictionary* syntaxDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",appSupportDefDir, syntaxDefinition]];
    
    //if the needed syntaxdef is not in appSupportDefDir
    if (syntaxDictionary == nil) {
        syntaxDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:syntaxDefinition ofType:@"plist" inDirectory:@"Syntax Definitions"]];
    }
    
    //If all fails, let's do it again in the mainbundle with "Plain Text"
    if (syntaxDictionary == nil) {
        syntaxDefinition = @"Plain Text";
        syntaxDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:syntaxDefinition ofType:@"plist" inDirectory:@"Syntax Definitions"]];
    }
    [self loadDefinitionDictionary:syntaxDictionary];
    [self fillSyntaxCharacterSets];
    
}


- (void)loadDefinitionDictionary:(NSDictionary *)syntDict {
    
    isKeywordsCaseInsensitive = [[syntDict valueForKey:@"keywordsCaseInsensitive"] boolValue];
    NSArray* values;
    if ((values = [syntDict objectForKey:@"keywords"])) {
        if (isKeywordsCaseInsensitive) {
            NSMutableArray* lowercaseValues = [NSMutableArray arrayWithCapacity:128];
            for (NSInteger i = 0; i < values.count; i++) {
                [lowercaseValues addObject:[values[i] lowercaseString]];
            }
            keywordSet = [[NSSet alloc] initWithArray:lowercaseValues];
        } else {
            keywordSet = [[NSSet alloc] initWithArray:values];
        }
        
	} else {
        keywordSet = [NSSet set];
    }
    if ((values = [syntDict objectForKey:@"predefinedDelim"])) {
		predefinedDelimSet = [[NSSet alloc]initWithArray:values];
	} else {
        predefinedDelimSet = [NSSet set];
    }
    if ((values = [syntDict objectForKey:@"predefined"])) {
		predefinedSet = [[NSMutableSet alloc] initWithArray:values];
	} else {
        predefinedSet = [[NSMutableSet alloc] initWithCapacity:4];
    }
    if ((values = [syntDict objectForKey:@"attributesDelim"])) {
		attributesDelimSet = [[NSSet alloc] initWithArray:values];
	} else {
        attributesDelimSet = [NSSet set];
    }
    
    //TODO: do we need that??
    isAttributesOnlyInTagsAndBlocks = [[syntDict valueForKey:@"attributesOnlyInTagsAndBlocks"] boolValue];
    
    isAttributeColoringInBlocks = [[syntDict valueForKey:@"attributeColoringInBlocks"] boolValue];
    
    if ((values = [syntDict objectForKey:@"singleLineStrings"])) {
		singleLineStrings = [self getValidSyntaxArray:values];
	} else {
        singleLineStrings = @[];
    }
    if ((values = [syntDict objectForKey:@"multiLineStrings"])) {
        multiLineStrings = [self getValidSyntaxArray:values];
	} else {
        multiLineStrings = @[];
    }
    if ((values = [syntDict objectForKey:@"charStrings"])) {
        charStrings = [self getValidSyntaxArray:values];
	}else {
        charStrings = @[];
    }
    if ((values = [syntDict objectForKey:@"singleLineComments"])) {
		singleLineComments = [[NSArray alloc] initWithArray:values];
	} else {
        singleLineComments = @[];
    }
    if ((values = [syntDict objectForKey:@"multiLineComments"])) {
		multiLineComments = [self getValidSyntaxArray:values];
	} else {
        multiLineComments = @[];
    }
    if ((values = [syntDict objectForKey:@"tags"])) {
        tags = [self getValidSyntaxArray:values];
	} else {
        tags = @[];
    }
    if ((values = [syntDict objectForKey:@"blocks"])) {
		blocks = [self getValidSyntaxArray:values];
	} else {
        blocks = @[];
    }
    if ((values = [syntDict objectForKey:@"variablesDelim"])) {
		variablesDelimArray = [[NSArray alloc] initWithArray:values];
	} else {
        variablesDelimArray = @[];
    }
    
    isVariablesDelimPartOfVar = [[syntDict valueForKey:@"variablesDelimPartOfVar"] boolValue];
    
    if (isVariablesDelimPartOfVar) {
        variablesSet = [[NSMutableSet alloc] initWithCapacity:16];
    } else {
        variablesSet = [[NSMutableSet alloc] initWithArray:variablesDelimArray];
    }
    
    isColoringOnlyInBlocksAndTags = [[syntDict valueForKey:@"coloringOnlyInBlocksAndTags"] boolValue];
    
}


- (NSArray *)getValidSyntaxArray:(NSArray *)syntArray {
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:syntArray];
    
    //look for empty strings in the Array
    for (NSInteger i = syntArray.count-1; i >= 0; i--) {        
        if ([temp[i] length] < 1) {
            [temp removeObjectAtIndex:i];
        }
    }
    //if count of Array is not even there must be something missing
    if (temp.count % 2 != 0) {
        [temp removeLastObject];
    }
    
    return temp;
    
}


- (void)fillSyntaxCharacterSets {
    [self fillWordCharacterSets];
    [self fillStringCharacterSets];
    [self fillCommentCharacterSets];
    [self fillTagAndBlockCharacterSets];
}


- (void)fillWordCharacterSets {
    
    wordBeginningSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
    [wordBeginningSet addCharactersInString:@"_"];
    [wordBeginningSet addCharactersInString:@"1234567890"];

    if (keywordSet != nil) {
        for (NSString *s in keywordSet) {
            if (s.length > 0) {
                [wordBeginningSet addCharactersInString:[s substringToIndex:1]];
            } 
        }
    }
    
    if (predefinedDelimSet != nil) {
        for (NSString *s in [predefinedDelimSet allObjects]) {
            if (s.length > 0) {
                [wordBeginningSet addCharactersInString:[s substringToIndex:1]];
            }
        }
    }
    
    for (NSString *s in variablesDelimArray) {
        if (s.length > 0) {
            [wordBeginningSet addCharactersInString:[s substringToIndex:1]];
        }
    }
    
    attributesCharSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [attributesCharSet addCharactersInString:@"-_"];
    
    wordEndingSet = wordBeginningSet;
    
}


- (void)fillStringCharacterSets {
    
    stringBeginningSet = [[NSMutableCharacterSet alloc] init];
    
    for (NSInteger i = 0; i < singleLineStrings.count; i++) {
        if (i % 2 == 0) {
            [stringBeginningSet addCharactersInString:[singleLineStrings[i]substringToIndex:1]];
        }
    }
    for (int i = 0; i < multiLineStrings.count; i++) {
        if (i % 2 == 0) {
            [stringBeginningSet addCharactersInString:[multiLineStrings[i]substringToIndex:1]];
        }
    }
    for (int i = 0; i < charStrings.count; i++) {
        if (i % 2 == 0) {
            [stringBeginningSet addCharactersInString:[charStrings[i]substringToIndex:1]];
        }
    }
    
}


- (void)fillCommentCharacterSets {
    
    commentBeginningSet = [[NSMutableCharacterSet alloc] init];

    if (singleLineComments != nil) {
        for (NSString *s in singleLineComments) {
            if (s.length > 0) {
                 [commentBeginningSet addCharactersInString:[s substringToIndex:1]];
            }
        }
    }

    for (NSInteger i = 0; i < multiLineComments.count; i++) {
        if (i % 2 == 0) {
            [commentBeginningSet addCharactersInString:[multiLineComments[i]substringToIndex:1]];
        }
    }
    
}


- (void)fillTagAndBlockCharacterSets {
    
    tagBlockBeginningSet = [[NSMutableCharacterSet alloc] init];
    tagBlockEndingSet = [[NSMutableCharacterSet alloc] init];

    for (NSInteger i = 0; i < tags.count; i++) {
        if (i % 2 == 0) {
            [tagBlockBeginningSet addCharactersInString:[tags[i]substringToIndex:1]];
        } else {
            [tagBlockEndingSet addCharactersInString:[tags[i]substringToIndex:1]];
        }
        
    }
    for (NSInteger i = 0; i < blocks.count; i++) {
        if (i % 2 == 0) {
            [tagBlockBeginningSet addCharactersInString:[blocks[i]substringToIndex:1]];
        } else {
            [tagBlockEndingSet addCharactersInString:[blocks[i]substringToIndex:1]];
        }
    }
    
}


//first look for plist in app sup dir so users can 'override' the link between file extensions and syntax definitions
- (void)setSyntaxDefinitionByFileExtension:(NSString *)fileExtension {
    
    NSString *syntaxDefName = @"";
    
    if (!fileExtension) {   //new or nerdy file without extension
        
        syntaxDefName = [TCADefaultsHelper getDefaultSyntaxDefinition];
        
    } else {
        
        NSString* lowerFileExtension = [fileExtension lowercaseString];
        
        //file with extension
        NSString* appSupportDefDir = [TCAApplicationSupportHelper applicationSupportDirectory];
        NSDictionary* fileExtensionsDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",appSupportDefDir, TCAFileExtensionsFile]];
        
        if (fileExtensionsDict == nil) {
            fileExtensionsDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:TCAFileExtensionsFile ofType:@"plist"]];
        }
        
        NSArray* keysArray = [fileExtensionsDict allKeys];
        
        for (NSString* key in keysArray) {
            if ([[fileExtensionsDict valueForKey:key] containsObject:lowerFileExtension]) {
                syntaxDefName = key;
                break;
            }
        }
        
    }
    
    //unknown extension
    if (!syntaxDefName || [syntaxDefName length] == 0) {
        syntaxDefName = @"Plain Text";
    }
    if ([syntaxDefinition isNotEqualTo:syntaxDefName]) {
        [self setSyntaxDefinitionByName:syntaxDefName];
    }
}


#pragma mark COLORING

- (void)textStorageDidChangeText:(NSNotification *)aNotification {
    
    if ([aNotification object][0] != [textView textStorage]
        || [[textView textStorage] string] == nil) {
        return;
    }

    NSRange rangeBefore = [[aNotification object][1] rangeValue];
    NSRange rangeAfter = [[aNotification object][2] rangeValue];

    //update the intern Strings
    textViewString = [[textView textStorage] string];
    scanner.scanString = textViewString;
    
    LexicalState* emptyState = [[LexicalState alloc] init];
    if (parsedTextStates.count < (rangeBefore.location + rangeBefore.length)) {
        parsedTextStates = [NSMutableArray arrayWithCapacity:textViewString.length];
        for (NSInteger i  = 0; i < textViewString.length; i++) {
            [parsedTextStates insertObject:emptyState atIndex:i];
        }
    } else {
        [parsedTextStates removeObjectsInRange:rangeBefore];
        for (NSInteger i = rangeAfter.location; i < rangeAfter.location+rangeAfter.length; i++) {
            [parsedTextStates insertObject:emptyState atIndex:i];
        }
    }
    
    // calculate range for recoloring
    NSRange recolorRange = [self getColoringRangeForChangedText:rangeAfter];
    NSUInteger checkIndex = recolorRange.location + recolorRange.length -1;
    
    if (parsedTextStates.count == 0 || parsedTextStates.count <= checkIndex) {
        return;
    }
    
    LexicalState* checkState = [[LexicalState alloc] initWithLexicalState:parsedTextStates[checkIndex]];
    
    // color text and if necessary calculate additional ranges to color
    [self colorRange:recolorRange];
    if ((checkIndex < parsedTextStates.count) && ![checkState isEqual:parsedTextStates[checkIndex]]) {
        recolorRange = [self getColoringRangeForChangedText:NSMakeRange(checkIndex, 0)];
        checkIndex = recolorRange.location + recolorRange.length;
        if (checkIndex < parsedTextStates.count) {
            checkState = parsedTextStates[checkIndex];
        }
    }

}


- (NSRange) getColoringRangeForChangedText:(NSRange)changedRange
{
    //probably a dragNdrop action: wait for second notification at textStorageDidChangeText
    if (textViewString.length != parsedTextStates.count) {        
        dragNdropRange = changedRange;
        if ([TCAMiscHelper isRange:changedRange inBoundOfString:textViewString]) {
            return [textViewString lineRangeForRange:changedRange];
        }
        return NSMakeRange(0, 0);
    }
    
    if (dragNdropRange.length != -1) {
        if (dragNdropRange.location < changedRange.location) {
            changedRange = NSMakeRange(dragNdropRange.location, changedRange.location + changedRange.length);
        } else {
            changedRange = NSMakeRange(changedRange.location, dragNdropRange.location + dragNdropRange.length);
        }
        dragNdropRange = NSMakeRange(0, -1);
    }

    //get start point
    NSInteger tmpStart = changedRange.location > 0 ? changedRange.location - 1 : 0;
    NSRange consideredRange = NSMakeRange(tmpStart, 0);
    
    NSUInteger lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation: consideredRange.location];
    NSRange lineRange = [(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber];
    NSInteger startPoint = lineRange.location -1;
    startPoint = startPoint < 0 ? 0 : startPoint;
    
    NSInteger endPoint = NSMaxRange(lineRange);
    while (endPoint < parsedTextStates.count) {
        LexicalState* tmpState = parsedTextStates[endPoint];        
        if ((tmpState.primaryState != eText
             && tmpState.primaryState != eSingleComment
            && tmpState.primaryState != eMultiComment
             && tmpState.primaryState != eCharString
             && tmpState.primaryState != eSingleString
            && tmpState.primaryState != eMultiString)
            || endPoint+1 >= parsedTextStates.count) {
            break;
        }
        endPoint++;
    }
    
    NSRange coloringRange = NSMakeRange(startPoint, endPoint - startPoint);
    return coloringRange;
    
}


- (NSInteger)getLocationOfLastVisibleCharacter {
    NSRect visibleRect = [[[textView enclosingScrollView] contentView] bounds];
	NSRange visibleRange = [[textView layoutManager] glyphRangeForBoundingRect:visibleRect inTextContainer:[textView textContainer]];
    NSRange charRange = [[textView layoutManager] characterRangeForGlyphRange:visibleRange actualGlyphRange:NULL];
    return (charRange.location + charRange.length);
}


- (void)colorDocument {
    if ([textView string] == nil) {
        return;
    }
    
    [lexicalState setToDefaultStates];
    textViewString = [textView string];
    scanner.scanString = textViewString;
    if (textViewString.length != parsedTextStates.count) {
        parsedTextStates = [NSMutableArray arrayWithCapacity:textViewString.length];
        LexicalState* emptyState = [[LexicalState alloc] init];
        for (NSUInteger i = 0; i < textViewString.length; i++) {
            [parsedTextStates insertObject:emptyState atIndex:i];
        }
    }

    [self colorRange:NSMakeRange(0, [textViewString length])];
        
}


- (NSInteger)colorRange:(NSRange)r {
    if (![TCAMiscHelper isRange:r inBoundOfString:textViewString]) {
        r = NSMakeRange(0, textViewString.length);
    }
    scanner.scanLocation = r.location;
    NSInteger currentPos = scanner.scanLocation;
    
    if (parsedTextStates.count > 0) {
        if (currentPos > 0) {
            lexicalState = [[LexicalState alloc] initWithLexicalState:parsedTextStates[currentPos]];
        } else {
            lexicalState = [[LexicalState alloc] init];
        }
    } else {
        lexicalState = [[LexicalState alloc] init];
        return 0;
    }
    
    [(TCTextStorage*)[textView textStorage] beginEditing];
    
    while (scanner.scanLocation < (r.location + r.length)) {
        
        currentPos = scanner.scanLocation;
        unichar currentChar = [textViewString characterAtIndex:currentPos];
        
        //look for what state we're heading
        if (!isColoringOnlyInBlocksAndTags 
            || (isColoringOnlyInBlocksAndTags && lexicalState.secondaryState == eTag) 
            || (isColoringOnlyInBlocksAndTags && lexicalState.secondaryState == eBlock)
            || (isColoringOnlyInBlocksAndTags && lexicalState.primaryState == eMultiComment)
            ) {
            if (lexicalState.primaryState == eText || lexicalState.primaryState == eKeyword
                || lexicalState.primaryState == ePredefined || lexicalState.primaryState == eVariable) {
                if ([wordBeginningSet characterIsMember:currentChar]
                    || ([attributesCharSet characterIsMember:currentChar] && lexicalState.secondaryState == eTag)
                    || ([attributesCharSet characterIsMember:currentChar] && lexicalState.secondaryState == eBlock)) {
                    [self colorWords];
                }
            }
            if ([stringBeginningSet characterIsMember:currentChar]) {
                    [self colorStrings];
                }
            else if (lexicalState.primaryState == eMultiString) {
                [self colorOpenMultiLineString];
            } else if (lexicalState.primaryState == eMultiComment) {
                [self colorOpenMultiLineComment];
            }

        }
        if (lexicalState.secondaryState != eTag
            && [commentBeginningSet characterIsMember:currentChar]
            && ((!isColoringOnlyInBlocksAndTags || lexicalState.blockNumber >= 0)
                || [tagBlockBeginningSet characterIsMember:currentChar]))
        {
            [self colorComments];
        }
        if ((lexicalState.secondaryState != eTag
             && lexicalState.secondaryState != eBlock)
            && [tagBlockBeginningSet characterIsMember:currentChar]) {
            [self colorTagsAndBlocksBeginning];
        }
        if ((lexicalState.secondaryState == eTag || lexicalState.secondaryState == eBlock)
            && [tagBlockEndingSet characterIsMember:currentChar]) {
            [self colorTagsAndBlocksEnding];
        }
        
        //nothing was found and scanner is still on the same position
        if (currentPos == scanner.scanLocation) {
            //you have to color it if its in a tag
            NSRange tmpRange = NSMakeRange(currentPos, 1);
            if (lexicalState.secondaryState == eTag) {
                [self colorizeWithColor:tagsColor inRange:tmpRange];
                [self addCurrentStateToParsedStatesInRange:tmpRange];
            } else {
                //nothing was found so the char should be in textColor 
                [self colorizeWithColor:textColor inRange:tmpRange];
                [self addCurrentStateToParsedStatesInRange:tmpRange];
            }
            scanner.scanLocation = scanner.scanLocation + 1;
        }
    }

    [(TCTextStorage*)[textView textStorage] endEditing];
    return scanner.scanLocation;
    
}


- (void)colorWords {
    
    NSDictionary* color = textColor;
    NSInteger currentPos = scanner.scanLocation;
    NSInteger newPos = currentPos;
    NSInteger tokenLength = 0;
    NSString* token = @"";
    NSRange tokenRange;
    
    //you have to look at the new pos for the attributesDelim  to get a attribute
    if ((lexicalState.secondaryState == eTag)
        || (isAttributeColoringInBlocks && lexicalState.secondaryState == eBlock)){
        
        [scanner scanCharactersFromSet:attributesCharSet];
        newPos = scanner.scanLocation;
        tokenLength = newPos - currentPos;
        NSRange delimsBeginRange = NSMakeRange(newPos, 1);
        if ([TCAMiscHelper isRange:delimsBeginRange inBoundOfString:textViewString]) {
            if ([attributesDelimSet containsObject:[textViewString substringWithRange:delimsBeginRange]]) {
                tokenLength++;
                scanner.scanLocation = newPos + 1;
                color = attributesColor;
                lexicalState.primaryState = eAttribute;
            } else {
                color = tagsColor;
                lexicalState.primaryState = eText;
            }
        }
            
        tokenRange = NSMakeRange(currentPos, tokenLength);
        
    } else {
        
        [scanner scanCharactersFromSet:wordEndingSet];
        newPos = scanner.scanLocation;
        tokenLength = newPos - currentPos;
        tokenRange = NSMakeRange(currentPos, tokenLength);
        if (![TCAMiscHelper isRange:tokenRange inBoundOfString:textViewString]) {
            return;
        }
        token = [textViewString substringWithRange:tokenRange];
        
        if (isKeywordsCaseInsensitive) {
            token = [token lowercaseString];
        }

        if ([keywordSet containsObject:token]) {
            color = keywordsColor;
            lexicalState.primaryState = eKeyword;
        } else if ([predefinedSet containsObject:token]) {
            color = predefinedColor;
            lexicalState.primaryState = ePredefined;
        } else if (!isVariablesDelimPartOfVar && [variablesSet containsObject:token]) {
            color = variablesColor;
            lexicalState.primaryState = eVariable;
        } else if (isVariablesDelimPartOfVar && variablesDelimArray.count > 0) {
            for (NSString* varDelim in variablesDelimArray) {
                if (token.length >= varDelim.length
                    && [[token substringToIndex:varDelim.length] isEqualToString:varDelim]) {
                    color = variablesColor;
                    lexicalState.primaryState = eVariable;
                }
            }
        } else {
            // needed to color strings correctly on line beginnings
            if ([stringBeginningSet characterIsMember:[textViewString characterAtIndex:currentPos]]) {
                scanner.scanLocation = currentPos;      // has to stay here
                return;
            }
            color = textColor;
            lexicalState.primaryState = eText;
        }   
    }
    
    [self colorizeWithColor:color inRange:tokenRange];
    [self addCurrentStateToParsedStatesInRange:tokenRange];
    lexicalState.primaryState = eText;
    token = nil;

}


- (void)parseNewPredefined {
    [scanner scanUpToCharactersFromSet:wordBeginningSet];
    NSInteger predefBeg = scanner.scanLocation;
    [scanner scanCharactersFromSet:wordEndingSet];
    NSInteger predefEnd = scanner.scanLocation;
    NSRange tokenRange = NSMakeRange(predefBeg, predefEnd);
    if (![TCAMiscHelper isRange:tokenRange inBoundOfString:textViewString]) {
        return;
    }
    NSString *token = [textViewString substringWithRange:tokenRange];
    [predefinedSet addObject:token];
    [self colorizeWithColor:predefinedColor inRange:tokenRange];
}


- (void)parseNewVariable {
    
    [scanner scanUpToCharactersFromSet:wordBeginningSet];
    NSInteger varBeg = scanner.scanLocation;
    [scanner scanCharactersFromSet:wordEndingSet];
    NSInteger varEnd = scanner.scanLocation;
    NSRange tokenRange = NSMakeRange(varBeg, varEnd);
    if (![TCAMiscHelper isRange:tokenRange inBoundOfString:textViewString]) {
        return;
    }
    NSString *token = [textViewString substringWithRange:tokenRange];
    [predefinedSet addObject:token];
    [self colorizeWithColor:variablesColor inRange:tokenRange];
    
}


- (void)colorStrings {
    NSInteger tokenLength = 0;
    NSRange tokenRange;
    NSInteger currentPos = scanner.scanLocation;
    NSInteger newPos = currentPos;
    //first decide which kind of string it is then parse & color it
    NSString *stringBeg = @"";
    NSString *stringBegTemp = @"";
    NSString *stringEnd = @"";
    
    NSUInteger lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation:currentPos];
    NSInteger endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
    // TODO: Hacky fix for endless loop bug, sometimes TextStorage returns end of previous line
    while (endOfCurrentLine < currentPos) {
        lineNumber++;
        endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
    }
    NSInteger maxCharsToSearch = 0;
    NSInteger maxIndexForSearch = 0;
    for (NSInteger i = 0; i < singleLineStrings.count; i += 2) {
        stringBegTemp = singleLineStrings[i];
        NSRange beginRange = NSMakeRange(currentPos, [stringBegTemp length]);
        if (![TCAMiscHelper isRange:beginRange inBoundOfString:textViewString]) {
            continue;
        }
        if ([[textViewString substringWithRange:beginRange] isEqualToString:stringBegTemp]) {
            stringBeg = singleLineStrings[i];
            stringEnd = singleLineStrings[i+1];
            maxCharsToSearch = (endOfCurrentLine) - (currentPos + [stringBeg length]);
            maxIndexForSearch = endOfCurrentLine;
            lexicalState.primaryState = eSingleString;
            break; //exits singleLineStrings for
        }
    }
    if (lexicalState.secondaryState != eTag) {
        for (NSInteger i = 0; i < multiLineStrings.count; i += 2) {
            stringBegTemp = multiLineStrings[i];
            NSRange beginRange = NSMakeRange(currentPos, [stringBegTemp length]);
            if (![TCAMiscHelper isRange:beginRange inBoundOfString:textViewString]) {
                continue;
            }
            if ([[textViewString substringWithRange:beginRange] isEqualToString:stringBegTemp]) {
                stringBeg = multiLineStrings[i];
                stringEnd = multiLineStrings[i+1];
                maxCharsToSearch = [textViewString length] - (currentPos + [stringBeg length]);
                maxIndexForSearch = [textViewString length];
                lexicalState.primaryState = eMultiString;
                break; //ends multiLineStrings for
            }
        }
    }
    
    for (NSInteger i = 0; i < charStrings.count; i += 2) {
        stringBegTemp = charStrings[i];
        NSRange beginRange = NSMakeRange(currentPos, [stringBegTemp length]);
        if (![TCAMiscHelper isRange:beginRange inBoundOfString:textViewString]) {
            continue;
        }
        if ([[textViewString substringWithRange:beginRange] isEqualToString:stringBegTemp]) {
            stringBeg = charStrings[i];
            stringEnd = charStrings[i+1];
            //this the part of singleLineStrings, because we dont distinguish between char- and singleLine strings yet.
            maxCharsToSearch = (endOfCurrentLine -1) - (currentPos + [stringBeg length]);
            maxIndexForSearch = endOfCurrentLine;
            lexicalState.primaryState = eCharString;
            break; //ends charStrings for
        }
    }
    if (stringBeg.length == 0 || stringEnd.length == 0 
        || currentPos + [stringBeg length] >= [textViewString length]) {
        return; //exits colorString because text string is not long enough or no string found
    } else {
        
        scanner.scanLocation = currentPos + [stringBeg length];
    }
    BOOL isEscaped = NO;
    
    do {
        [scanner scanUpToString:stringEnd forNumberOfCharacters:maxCharsToSearch];
        newPos = scanner.scanLocation;
        if (newPos - 1 < 0) {
            break;
        }
        if (newPos < maxIndexForSearch && [textViewString characterAtIndex:newPos - 1]  == '\\') {
            isEscaped = YES;
            NSInteger numberOfEscapeChars = 1;
            NSInteger escapeCharIndex = newPos - 2;
            while ([textViewString characterAtIndex:escapeCharIndex] == '\\') {
                numberOfEscapeChars++;
                escapeCharIndex--;
            }
            if (numberOfEscapeChars % 2 == 0) {
                isEscaped = NO;
            }
            if ((newPos + 1) < maxIndexForSearch && isEscaped) {
                [scanner setScanLocation:newPos + 1];
            } else {
                break; //exits do...while
            }
        } else {
            isEscaped = NO;
        }
    } while (isEscaped);
    //end of string is found

    newPos = scanner.scanLocation + [stringEnd length];
    if (newPos > maxIndexForSearch) {
        newPos = maxIndexForSearch;
    }
    if (newPos > [textViewString length]) {
        newPos = scanner.scanLocation;
    }
    
    tokenLength = (newPos - currentPos);
    
    tokenRange = NSMakeRange(currentPos, tokenLength);
    [self colorizeWithColor:stringsColor inRange:tokenRange];
    [self addCurrentStateToParsedStatesInRange:tokenRange];
    lexicalState.primaryState = eText;
    //set scannerLocation behind string
    scanner.scanLocation = newPos;

}


- (void)colorOpenMultiLineString {
    
    NSInteger currentPos = scanner.scanLocation;
    NSInteger nextFoundClosingLoc = parsedTextStates.count;
    NSString* nextFoundClosingToken = @"";
    for (NSInteger i = 1; i < multiLineStrings.count; i += 2) {
        scanner.scanLocation = currentPos;

        NSUInteger lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation: currentPos];
        NSInteger endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
        while (endOfCurrentLine < currentPos) {
            lineNumber++;
            endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
        }

        while (![scanner scanUpToString:multiLineStrings[i] forNumberOfCharacters:endOfCurrentLine - scanner.scanLocation]
               && ![scanner isAtEnd]) {
            lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation: scanner.scanLocation + 1];
            endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
            while (endOfCurrentLine < scanner.scanLocation + 1) {
                lineNumber++;
                endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
            }
        }
        if (scanner.scanLocation < nextFoundClosingLoc) {
            nextFoundClosingLoc = scanner.scanLocation;
            nextFoundClosingToken = multiLineStrings[i];
        }
    }
    
    NSInteger tokenEnd = nextFoundClosingLoc + nextFoundClosingToken.length > parsedTextStates.count ? parsedTextStates.count : nextFoundClosingLoc + nextFoundClosingToken.length;
    
    
    NSRange tokenRange = NSMakeRange(currentPos, tokenEnd - currentPos);
    [self colorizeWithColor:stringsColor inRange:tokenRange]; 
    [self addCurrentStateToParsedStatesInRange:tokenRange];
    lexicalState.primaryState = eText;
    scanner.scanLocation = tokenRange.location + tokenRange.length;
    
}


- (void)colorComments {
    
    NSInteger tokenLength = 0;
    NSRange tokenRange;
    NSInteger currentPos = scanner.scanLocation;
    NSInteger newPos = currentPos;
    //first decide which kind of comment it is then parse & color it
    NSString* commentBeg = @"";
    NSString* commentBegTemp = @"";
    NSString* commentEnd = @"";
    
    for (NSInteger i = 0; i < singleLineComments.count; i++) {
        commentBegTemp = singleLineComments[i];
        NSRange beginRange = NSMakeRange(currentPos, [commentBegTemp length]);
        if (![TCAMiscHelper isRange:beginRange inBoundOfString:textViewString]) {
            continue;
        }
        if ([[textViewString substringWithRange:beginRange] isEqualToString:commentBegTemp]) {
            commentBeg = singleLineComments[i];
            commentEnd = @"";
            lexicalState.primaryState = eSingleComment;
            break; //exits singleLineComments for
        }
    }
    if (lexicalState.secondaryState != eTag) {
        for (NSInteger i = 0; i < multiLineComments.count; i += 2) {
            commentBegTemp = multiLineComments[i];
            NSRange beginRange = NSMakeRange(currentPos, [commentBegTemp length]);
            if (![TCAMiscHelper isRange:beginRange inBoundOfString:textViewString]) {
                continue;
            }
            if ([[textViewString substringWithRange:beginRange] isEqualToString:commentBegTemp]) {
                commentBeg = multiLineComments[i];
                commentEnd = multiLineComments[i+1];
                
                lexicalState.primaryState = eMultiComment;
                break; //exits multiLineComments for
            }
        }
    }

    NSUInteger lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation: currentPos];
    NSInteger endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);

    if (lexicalState.primaryState == eSingleComment) {
        // TODO: hacky fix for the TextStorage bug for lineRange
        while (endOfCurrentLine < currentPos) {
            lineNumber++;
            endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
        }
        newPos = endOfCurrentLine;
    } else if (lexicalState.primaryState == eMultiComment) {
        scanner.scanLocation = currentPos + commentBeg.length;
        //[scanner scanUpToString:commentEnd];

        NSUInteger lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation: scanner.scanLocation];
        NSInteger endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
        while (scanner.scanLocation > endOfCurrentLine) {
            lineNumber++;
            endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
        }

        while (![scanner scanUpToString:commentEnd forNumberOfCharacters:endOfCurrentLine - scanner.scanLocation]
               && ![scanner isAtEnd]) {
            lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation: scanner.scanLocation + 1];
            endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
            while (endOfCurrentLine < scanner.scanLocation + 1) {
                lineNumber++;
                endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
            }
        }

        newPos = scanner.scanLocation + [commentEnd length];
        if (newPos > [textViewString length]) {
            newPos = scanner.scanLocation;
        }
    } else {
        return; //No comment found
    }
    tokenLength = newPos - currentPos;
    tokenRange = NSMakeRange(currentPos, tokenLength);
    [self colorizeWithColor:commentsColor inRange:tokenRange];
    [self addCurrentStateToParsedStatesInRange:tokenRange];
    lexicalState.primaryState = eText;
    //set scannerLocation behind comment
    scanner.scanLocation = newPos;

}


// Used if coloring starts in the middle of a multiline comment (for performance reason)
- (void)colorOpenMultiLineComment {
    NSInteger currentPos = scanner.scanLocation;
    NSInteger nextFoundClosingLoc = parsedTextStates.count;
    NSString *nextFoundClosingToken = @"";
    for (NSInteger i = 1; i < multiLineComments.count; i += 2) {
        //[scanner scanUpToString:multiLineComments[i]];


        NSUInteger lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation: scanner.scanLocation];
        NSInteger endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
        while (endOfCurrentLine < scanner.scanLocation) {
            lineNumber++;
            endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
        }

        while (![scanner scanUpToString:multiLineComments[i] forNumberOfCharacters:endOfCurrentLine - scanner.scanLocation]
               && ![scanner isAtEnd]) {
            lineNumber = [(TCTextStorage*)[textView textStorage] lineNumberForLocation: scanner.scanLocation + 1];
            endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
            while (endOfCurrentLine < scanner.scanLocation + 1) {
                lineNumber++;
                endOfCurrentLine = NSMaxRange([(TCTextStorage*)[textView textStorage] lineRangeOfLine:lineNumber]);
            }
        }





        if (scanner.scanLocation < nextFoundClosingLoc) {
            nextFoundClosingLoc = scanner.scanLocation;
            nextFoundClosingToken = multiLineComments[i];
        }
        scanner.scanLocation = currentPos;
    }

    NSInteger newPos = nextFoundClosingLoc + nextFoundClosingToken.length;
    if (newPos > parsedTextStates.count) {
        newPos = parsedTextStates.count;
    }
   
    NSRange tokenRange = NSMakeRange(currentPos, newPos - currentPos);
    [self colorizeWithColor:commentsColor inRange:tokenRange];
    [self addCurrentStateToParsedStatesInRange:tokenRange];
    lexicalState.primaryState = eText;
    scanner.scanLocation = newPos;
    
}


- (void)colorTagsAndBlocksBeginning {

    NSInteger tokenLength = 0;
    NSRange tokenRange;
    NSInteger currentPos = scanner.scanLocation;
    
    NSString* tagBlockBeg = @"";
    NSString* tagBlockBegTemp = @""; 
    for (NSInteger i = 0; i < tags.count; i += 2) {
        tagBlockBegTemp = tags[i];
        NSRange beginRange = NSMakeRange(currentPos, [tagBlockBegTemp length]);
        if (![TCAMiscHelper isRange:beginRange inBoundOfString:textViewString]) {
            continue;
        }
        if ([[textViewString substringWithRange:beginRange] isEqualToString:tagBlockBegTemp]) {
            tagBlockBeg = tagBlockBegTemp;
            lexicalState.secondaryState = eTag;
            break; //exits tags end for
        }
    }
    for (NSInteger i = 0; i < blocks.count; i += 2) {
        tagBlockBegTemp = blocks[i];
        NSRange beginRange = NSMakeRange(currentPos, [tagBlockBegTemp length]);
        if (![TCAMiscHelper isRange:beginRange inBoundOfString:textViewString]) {
            continue;
        }
        if ([[textViewString substringWithRange:beginRange] isEqualToString:tagBlockBegTemp]) {
            tagBlockBeg = tagBlockBegTemp;
            lexicalState.secondaryState = eBlock;
            lexicalState.blockNumber = i / 2;    //normalize blockNumber so 0 is for block 1, 1 is for block 2,...
            break; //exits blocks begin for
        }
    }

    tokenLength = [tagBlockBeg length];
    tokenRange = NSMakeRange(currentPos, tokenLength);
    if (lexicalState.secondaryState == eTag) {
        [self colorizeWithColor:tagsColor inRange:tokenRange];
    } else if (lexicalState.secondaryState == eBlock) {
        [self colorizeWithColor:blocksColor inRange:tokenRange];
    }
    
    [self addCurrentStateToParsedStatesInRange:tokenRange];
    if (currentPos + tokenLength < [textViewString length]) {
        scanner.scanLocation = currentPos + tokenLength; 
    }
    
}


- (void)colorTagsAndBlocksEnding {

    NSInteger tokenLength = 0;
    NSInteger currentPos = scanner.scanLocation;
    NSRange tokenRange;   
    NSString* tagBlockEnd = @"";
    
    if (lexicalState.secondaryState == eTag) {
        for (NSInteger i = 1; i < tags.count; i += 2) {
            tagBlockEnd = tags[i];
            tokenRange = NSMakeRange(currentPos, [tagBlockEnd length]);
            if (![TCAMiscHelper isRange:tokenRange inBoundOfString:textViewString]) {
                continue;
            }
            if ([[textViewString substringWithRange:tokenRange] isEqualToString:tagBlockEnd]) {
                [self colorizeWithColor:tagsColor inRange:tokenRange];
                [self addCurrentStateToParsedStatesInRange:tokenRange];
                tokenLength = [tagBlockEnd length];
                lexicalState.secondaryState = eText;
                break; //exits tags end for
            }
        }
    } else if (lexicalState.secondaryState == eBlock && lexicalState.blockNumber != -1) {
        tagBlockEnd = blocks[(lexicalState.blockNumber * 2) + 1];
        if (tagBlockEnd.length+currentPos <= textViewString.length) { //check if string is even long enough for blockEnd
            tokenLength = [tagBlockEnd length];
            tokenRange = NSMakeRange(currentPos, tokenLength);
            if ([TCAMiscHelper isRange:tokenRange inBoundOfString:textViewString] && [[textViewString substringWithRange:tokenRange] isEqualToString:tagBlockEnd]) {
                tokenLength = [tagBlockEnd length];
                tokenRange = NSMakeRange(currentPos, tokenLength);
                [self colorizeWithColor:blocksColor inRange:tokenRange];
                [self addCurrentStateToParsedStatesInRange:tokenRange];
                lexicalState.secondaryState = eText;
                lexicalState.blockNumber = -1;
            }
            else {
                tokenLength  = 0;
            }
        }
        
    }
    if (currentPos + tokenLength <= [textViewString length]) {
        scanner.scanLocation = currentPos + tokenLength; 
    }
    
}


#pragma mark COLORING INTERN

- (void)colorizeWithColor:(NSDictionary *)color inRange:(NSRange)range {

    if (range.length == 0 || range.length > textViewString.length) {
       return;
    }
    [(TCTextStorage* )[textView textStorage] setAttributes:[attributesFactory getAttributeForColorDictionary:color WithTextView:(TCTextView*)textView] range:range];
    
}


- (void)addCurrentStateToParsedStatesInRange:(NSRange)range {
    
    LexicalState* parsedState = [stateFactory getStateForState:lexicalState];
    
    if ((range.location+range.length) <= parsedTextStates.count) {
        for (NSInteger i = range.location; i < range.location+range.length; i++) {
            parsedTextStates[i] = parsedState;
        }
    } else {
        NSLog(@"addCurrentStateToParsedStates: length out of sync!!!!");
    }
    
}


#pragma mark INTERN HELPERS


- (NSString* )fileExtensionFollowingSyntaxDefinition {
    
    //TODO: should only be called once in a TCSyntaxColoring lifetime
    //NSString* appSupportDir = [TCSyntaxColoring applicationSupportDirectory];
    NSString* appSupportDir = [TCAApplicationSupportHelper applicationSupportDirectory];
    NSDictionary* fileExtensionsDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",appSupportDir, TCAFileExtensionsFile]];
    if (fileExtensionsDict == nil) {
        fileExtensionsDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:TCAFileExtensionsFile ofType:@"plist"]];
    }
    //////////////////////////////////////////////////////
    NSString* extension = [fileExtensionsDict valueForKey:self.syntaxDefinition][0];
    if (extension) {
        return extension;
    } else {
        return @"txt";
    }
    
}


#pragma mark EXTERN HELPERS

- (NSString*)getSingleLineCommentToken {
    return [singleLineComments firstObject];
}

- (NSArray*)getMultiLineCommentToken {
    if (multiLineComments.count < 2) {
        return nil;
    }
    return @[multiLineComments[0], multiLineComments[1]];
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


@end
