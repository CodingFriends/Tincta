//
//  TCScanner.m
//  tincta
//
//  Created by Julius Peinelt on 17.09.11.
//  Copyright 2010-2016 Coding Friends UG (haftungsbeschränkt)
//

#import "TCAScanner.h"
#import "TCAMiscHelper.h"

@implementation TCAScanner

@synthesize scanLocation, scanString;

- (id)init {
    self = [super init];
    if (self) {
        scanString = @"";
        scanLocation = 0;
    }
    return self;
}

- (id)initWithString:(NSString*)aString {
    self = [super init];
    if (self) {
        scanString = aString;
        scanLocation = 0;
    }
    return self;
}


+ (id)scannerWithString:(NSString*)aString {
    TCAScanner* scanner = [[TCAScanner alloc] initWithString:aString];
    return scanner;
}

- (BOOL)isAtEnd {
    if (scanLocation >= scanString.length) {
        return YES;
    }
    return NO;
}

- (BOOL)scanUpToString:(NSString*)aString {
    if (![self isAtEnd]) {
        NSString *subString = [scanString substringFromIndex:scanLocation];
        NSRange foundRange = [subString rangeOfString:aString];
        if (foundRange.location != NSNotFound) {
            scanLocation += foundRange.location;
            return YES;
        } else {
            scanLocation = scanString.length;
            return NO;
        }
    }
    return NO;
}

- (BOOL)scanUpToString:(NSString*)aString forNumberOfCharacters:(NSInteger)length {
    if (aString!= nil
        && length > 0
        && ![self isAtEnd]) {
        NSString *subString;
        NSRange scanRange = NSMakeRange(scanLocation, length);
        if (![TCAMiscHelper isRange:scanRange inBoundOfString:scanString]) {
            subString = [scanString substringFromIndex:scanLocation];
        } else {
            subString = [scanString substringWithRange:NSMakeRange(scanLocation, length)];
        } 
        NSRange foundRange = [subString rangeOfString:aString];
        if (foundRange.location != NSNotFound) {
            scanLocation += foundRange.location;
            return YES;
        } else {
            scanLocation += subString.length;
            return NO;
        }
    }
    return NO;
}

- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet*)aCharacterSet {
    if (![self isAtEnd]) {
        NSRange foundRange = [[scanString substringFromIndex:scanLocation] rangeOfCharacterFromSet:aCharacterSet];
        if (foundRange.location != NSNotFound) {
            scanLocation += foundRange.location;
            return YES;
        } else {
            scanLocation = scanString.length;
            return NO;
        }
    }
    return NO;
}

- (BOOL)scanCharactersFromSet:(NSCharacterSet*)aCharacterSet {
    if (![self isAtEnd]) {
        
        for (int i = scanLocation; i < [scanString length]; i++) {
            if (![aCharacterSet characterIsMember:[scanString characterAtIndex:i]]) {
                return YES;
            }
            scanLocation++;
        }
    }
    return NO;
}

@end
