//
//  tincta
//
//  Created by Gabriel Reimers on 11/01/15.
//
//

#import "TCAColorScheme.h"
#import "TCAApplicationSupportHelper.h"

@implementation TCAColorScheme


static NSString* const  kTCIsUserGenerated = @"isUserGenerated";
static NSString* const  kTCBackground = @"background";
static NSString* const  kTCText = @"text";
static NSString* const  kTCCurrentLine = @"currentLine";
static NSString* const  kTCSelection = @"selection";
static NSString* const  kTCInvisibles = @"invisibles";
static NSString* const  kTCAttributes = @"attributes";
static NSString* const  kTCVariables = @"variables";
static NSString* const  kTCComments = @"comments";
static NSString* const  kTCStrings = @"strings";
static NSString* const  kTCKeywords = @"keywords";
static NSString* const  kTCTags = @"tags";
static NSString* const  kTCPredefined = @"predefined";
static NSString* const  kTCBlocks = @"blocks";

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _colorBackground = [NSColor whiteColor];
        _colorText = [NSColor blackColor];
        
        _colorCurrentLine = [NSColor lightGrayColor];
        
        _colorSelection = [NSColor lightGrayColor];
        
        _colorComments = [NSColor blackColor];
        _colorInvisibles = [NSColor blueColor];
        
        _colorAttributes = [NSColor blackColor];
        _colorVariables = [NSColor blackColor];
        _colorStrings = [NSColor redColor];
        _colorKeywords = [NSColor blackColor];
        _colorTags = [NSColor blackColor];
        _colorBlocks = [NSColor blackColor];
        _colorPredefined = [NSColor blackColor];

        _isUserGenerated = NO;
    }
    return self;
}

- (id) initWithContentsOfURL: (NSURL*) theUrl {
    self = [self init];
    if (self) {
        
        NSDictionary* dict = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithFile:theUrl.path];
        if (dict == nil) {
            NSLog(@"TCAColorScheme > init > could not load scheme from file: %@", theUrl.path);
            return self;
        }
        
        _fileUrl = theUrl;
        
        NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        _isUserGenerated = (NO == [theUrl.path containsString:mainBundlePath]);
        
        NSColor* dictColor = dict[kTCBackground];
        if (dictColor) {
            _colorBackground = dictColor;
        }
        
        dictColor = dict[kTCText];
        if (dictColor) {
            _colorText = dictColor;
        }
        
        dictColor = dict[kTCCurrentLine];
        if (dictColor) {
            _colorCurrentLine = dictColor;
        }
        
        dictColor = dict[kTCSelection];
        if (dictColor) {
            _colorSelection = dictColor;
        }
        
        dictColor = dict[kTCComments];
        if (dictColor) {
            _colorComments = dictColor;
        }
        
        dictColor = dict[kTCInvisibles];
        if (dictColor) {
            _colorInvisibles = dictColor;
        }
        
        
        dictColor = dict[kTCAttributes];
        if (dictColor) {
            _colorAttributes = dictColor;
        }
        
        dictColor = dict[kTCVariables];
        if (dictColor) {
            _colorVariables = dictColor;
        }
        
        dictColor = dict[kTCStrings];
        if (dictColor) {
            _colorStrings = dictColor;
        }
        
        dictColor = dict[kTCKeywords];
        if (dictColor) {
            _colorKeywords = dictColor;
        }
        
        dictColor = dict[kTCTags];
        if (dictColor) {
            _colorTags = dictColor;
        }
        
        dictColor = dict[kTCPredefined];
        if (dictColor) {
            _colorPredefined = dictColor;
        }
        
        dictColor = dict[kTCBlocks];
        if (dictColor) {
            _colorBlocks = dictColor;
        }
        
    }
    return self;
}

+ (NSArray*) builtInColorSchemes {
    NSMutableArray* schemes = [NSMutableArray array];
    NSURL* localFolder = [[NSBundle mainBundle] resourceURL];
    localFolder = [localFolder URLByAppendingPathComponent:@"ColorSchemes" isDirectory:YES];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* localColorSchemesUrls = [fm contentsOfDirectoryAtURL:localFolder includingPropertiesForKeys:nil options:0 error:NULL];
    for (NSURL* url in localColorSchemesUrls) {
        if ([url.pathExtension isEqualToString:@"plist"]) {
            TCAColorScheme* scheme = [[TCAColorScheme alloc] initWithContentsOfURL:url];
            scheme.fileUrl = url;
            [schemes addObject:scheme];
        }
    }
    return schemes;
}

+ (NSArray*) userColorSchemes {
    NSMutableArray* schemes = [NSMutableArray array];
    NSURL* userSchemesFolder = [NSURL fileURLWithPath: [TCAApplicationSupportHelper applicationSupportColorSchemesDirectory]];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* userColorSchemesUrls = [fm contentsOfDirectoryAtURL:userSchemesFolder includingPropertiesForKeys:nil options:0 error:NULL];
    for (NSURL* url in userColorSchemesUrls) {
        if ([url.pathExtension isEqualToString:@"plist"]) {
            TCAColorScheme* scheme = [[TCAColorScheme alloc] initWithContentsOfURL:url];
            scheme.fileUrl = url;
            [schemes addObject:scheme];
        }
    }
    return schemes;
}

- (NSString*) name {
  return self.fileUrl.lastPathComponent.stringByDeletingPathExtension;
}


- (void) save {
    if (self.fileUrl == nil) {
        NSLog(@"ColorScheme > save > no url");
        NSURL* newUrl = [NSURL fileURLWithPath: [TCAApplicationSupportHelper applicationSupportColorSchemesDirectory]];
        newUrl = [newUrl URLByAppendingPathComponent:@"unknown.plist"];
        NSFileManager* fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:newUrl.path]) {
            return;
        }
        self.fileUrl = newUrl;
    }
    if (NO == self.isUserGenerated) {
        NSLog(@"ColorScheme > save > saving to write protected file");
        return;
    }
    [self writeToUrl:self.fileUrl];
}


- (NSURL*)duplicateWithName:(NSString*)name {
    if (self.fileUrl == nil) {
        NSLog(@"ColorProfile > rename > failed: no file url");
        return nil;
    }
    NSFileManager* fm = [NSFileManager defaultManager];

    NSString* profileName = name ? name : [self.name stringByAppendingString:@" copy"];

    NSString* rawTargetPath = [[TCAApplicationSupportHelper applicationSupportColorSchemesDirectory] stringByAppendingPathComponent:profileName];

    NSString* tempTargetPath = [NSString stringWithFormat:@"%@.plist", rawTargetPath];
    NSInteger nameCounter = 1;

    while ([fm fileExistsAtPath:tempTargetPath]) {
        tempTargetPath = [rawTargetPath stringByAppendingString: [NSString stringWithFormat: @"%ld.plist", nameCounter]];
        nameCounter++;
    }

    NSURL* newUrl = [NSURL fileURLWithPath:tempTargetPath];
    NSError* error = nil;
    [fm copyItemAtURL:self.fileUrl toURL:newUrl error:&error];
    
    if (error != nil) {
        NSLog(@"ColorProfile > duplicate > failed: %@", error.description);
        return nil;
    }
    return newUrl;
}


- (NSURL*)rename: (NSString*) newName {
    if (self.fileUrl == nil || newName == nil) {
        NSLog(@"ColorProfile > rename > failed: no file url or target given");
        return nil;
    }
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* rawPath = [[TCAApplicationSupportHelper applicationSupportColorSchemesDirectory] stringByAppendingPathComponent:newName];
    
    NSString* newPath = [rawPath stringByAppendingString:@".plist"];
    if ([fm fileExistsAtPath:newPath]) {
        newPath = self.fileUrl.path; //just keep the old path -> don't rename
    }
    
    NSURL* newUrl = [NSURL fileURLWithPath:newPath];
    NSError* error = nil;
    [fm moveItemAtURL:self.fileUrl toURL:newUrl error:&error];
    
    if (error != nil) {
        NSLog(@"ColorProfile > rename > failed: %@", error.description);
        return nil;
    }
    self.fileUrl = newUrl;
    return newUrl;
}


- (void) writeToUrl: (NSURL*) theUrl {
    NSDictionary* dict = [self dictionaryRepresentation];
    BOOL success = [NSKeyedArchiver archiveRootObject:dict toFile:[theUrl path]];
    if (NO == success) {
        NSLog(@"TCAColorScheme > writeToURL > could not save");
    }
}



- (NSDictionary*) dictionaryRepresentation {
    NSDictionary* dict = @{
                           kTCIsUserGenerated: @(self.isUserGenerated),
                           kTCText: self.colorText,
                           kTCBackground: self.colorBackground,
                           kTCCurrentLine: self.colorCurrentLine,
                           kTCSelection: self.colorSelection,
                           kTCComments: self.colorComments,
                           kTCInvisibles: self.colorInvisibles,
                           kTCAttributes: self.colorAttributes,
                           kTCVariables: self.colorVariables,
                           kTCStrings: self.colorStrings,
                           kTCKeywords: self.colorKeywords,
                           kTCTags: self.colorTags,
                           kTCPredefined: self.colorPredefined,
                           kTCBlocks: self.colorBlocks
                           };
    return dict;
}




@end
