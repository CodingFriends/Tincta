//
//  MenuHelper.m
//  Tincta Pro
//
//  Created by Julius Peinelt on 6/20/13.
//
//

#import "TCAMenuHelper.h"
#import "TCSyntaxColoring.h"
#import "TCTextViewController.h"     //TODO: because of menuSyntaxDefinitionChange selector
#import "TCAApplicationSupportHelper.h"

@implementation TCAMenuHelper


+ (NSMenu*)syntaxDefinitionsMenu {
    
    NSMenu* syntaxDefinitionsMenu = [[NSMenu alloc] initWithTitle:@"Syntax Coloring"];
    NSMutableArray* availableSyntaxDefinitions = [TCAMenuHelper createSyntaxDefinitionsArray];
    for (NSString* syntaxDef in availableSyntaxDefinitions) {
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:syntaxDef action:@selector(menuSyntaxDefinitionChange:) keyEquivalent:@""];
        [syntaxDefinitionsMenu addItem:item];
    }
    return syntaxDefinitionsMenu;
    
}


+ (NSMutableArray*)createSyntaxDefinitionsArray {
    
    NSMutableArray* availableSyntaxDefinitions = [NSMutableArray arrayWithCapacity:128];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //look up the definitions made by the user in the app sup dir
    NSString* appSupportDefDir = [TCAApplicationSupportHelper applicationSupportSyntaxDefinitionsDirectory];
    NSArray* userSyntaxDefPathList = [fileManager contentsOfDirectoryAtPath:appSupportDefDir error:NULL];
    for (NSString* filePath in userSyntaxDefPathList) {
        NSString* fileNameWithExtension = [filePath lastPathComponent];
        NSString* fileExtension = [filePath pathExtension];
        NSString* fileName = [fileNameWithExtension substringToIndex:[fileNameWithExtension length]-([fileExtension length]+1)];
        if ([fileName characterAtIndex:0] != '.') {
            [availableSyntaxDefinitions addObject:fileName];
        }
    }
    
    NSString* mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* syntaxDefFolderPath = [NSString stringWithFormat:@"%@/Contents/Resources/Syntax Definitions", mainBundlePath];
    if ([fileManager fileExistsAtPath: syntaxDefFolderPath]) {
        
        NSArray* syntaxDefPathList = [fileManager contentsOfDirectoryAtPath:syntaxDefFolderPath error:NULL];
        
        for (NSString* filePath in syntaxDefPathList) {
            NSString* fileNameWithExtension = [filePath lastPathComponent];
            NSString* fileExtension = [filePath pathExtension];
            NSString* fileName = [fileNameWithExtension substringToIndex:[fileNameWithExtension length]-([fileExtension length]+1)];
            if (![availableSyntaxDefinitions containsObject:fileName]) {
                [availableSyntaxDefinitions addObject:fileName];
            }
        }
    }
    [availableSyntaxDefinitions sortUsingSelector:@selector(compare:)];
    
    return availableSyntaxDefinitions;
    
}

+ (NSArray*)allFileExtensions {
    
    NSString* appSupportDefDir = [TCAApplicationSupportHelper applicationSupportSyntaxDefinitionsDirectory];
    NSDictionary* fileExt = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",appSupportDefDir, TCAFileExtensionsFile]];
        
    if (fileExt == nil) {
        fileExt = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:TCAFileExtensionsFile ofType:@"plist"]];
    }
    NSArray* fileExtensionsArrays = [fileExt allValues];
    NSMutableArray* fileExtensions = [NSMutableArray arrayWithCapacity:[fileExtensionsArrays count]];
    for (NSArray* extArray in fileExtensionsArrays) {
        [fileExtensions addObjectsFromArray:extArray];
    }
    return fileExtensions;
    
}




@end
