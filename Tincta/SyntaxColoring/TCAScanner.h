//
//  TCScanner.h
//  tincta
//
//  Created by Julius Peinelt on 17.09.11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <Foundation/Foundation.h>

@interface TCAScanner : NSObject {

}

@property (assign) NSInteger scanLocation;
@property (strong) NSString *scanString;

- (id)initWithString:(NSString*)aString;

- (BOOL)isAtEnd;
- (BOOL)scanUpToString:(NSString*)aString;
- (BOOL)scanUpToString:(NSString*)aString forNumberOfCharacters:(NSInteger)length;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet*)aCharacterSet;
- (BOOL)scanCharactersFromSet:(NSCharacterSet*)aCharacterSet;

+ (id)scannerWithString:(NSString*)aString;

@end
