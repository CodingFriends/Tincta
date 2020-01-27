//
//  TCApplicationSupportHelper.m
//  Tincta Pro
//
//  Created by Julius Peinelt on 6/20/13.
//
//

#import "TCAApplicationSupportHelper.h"

@implementation TCAApplicationSupportHelper

//Application Support Directory / Syntax Definitions
+ (NSString*)applicationSupportSyntaxDefinitionsDirectory {
    
    NSString* executableName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
    NSString* syntaxDefPath = [NSString stringWithFormat:@"%@/Definitions",executableName];
    NSError* error;
    NSString* result = [TCAApplicationSupportHelper findOrCreateDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appendPathComponent:syntaxDefPath error:&error];
    if (error) {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}

//Application Support Directory / Syntax Definitions
+ (NSString*)applicationSupportColorSchemesDirectory {
    
    NSString* executableName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
    NSString* syntaxDefPath = [NSString stringWithFormat:@"%@/ColorSchemes",executableName];
    NSError* error;
    NSString* result = [TCAApplicationSupportHelper findOrCreateDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appendPathComponent:syntaxDefPath error:&error];
    if (error) {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}


//Application Support Directory / Syntax Definitions
+ (NSString*)applicationSupportDirectory {
    
    NSString* executableName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
    NSError* error;
    NSString* result = [TCAApplicationSupportHelper findOrCreateDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appendPathComponent:executableName error:&error];
    if (result == nil) {
        NSRunAlertPanel(@"Alert", @"Can't find application support folder - Probably your system is seriously damaged. You may now panic and flee to the next genius bar.\nOr you can lean back and think about how pointless all this material stuff acutally is. You will agree that going to the park with your family is much more fun anyway.", @"No work today! Yay!", nil, nil);
        [[NSApplication sharedApplication] terminate:self];
    }
    return result;
}


//find or create a Userdefined Syntax Definitions directory
+ (NSString*)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString*)appendComponent
                              error:(NSError**)errorOut {
    
    // Search for the path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, domainMask, YES);
    if ([paths count] == 0) {
        return nil;
    }
    NSString* resolvedPath = [paths firstObject];
    if (appendComponent) {
        resolvedPath = [resolvedPath stringByAppendingPathComponent:appendComponent];
    }
    // Create the path if it doesn't exist
    NSError* error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:resolvedPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        if (errorOut) {
            *errorOut = error;
        }
        return nil;
    }

    if (*errorOut) {
        NSLog(@"TCAApplicationSupportHelper > Error %@", *errorOut);
        *errorOut = nil;
    }
    return resolvedPath;
}

@end
