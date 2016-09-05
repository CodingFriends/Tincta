//
//  TCEncodings.h
//  Tincta
//
//  Created by Mr. Fridge on 4/27/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <Foundation/Foundation.h>


@interface TCEncodings : NSObject {

    
    NSArray* standardEncodings;
    NSArray* westernEncodings;
    NSArray* eastEuropeanEncodings;
    NSArray* eastAsianEncodings;
    NSArray* centralWestAsianEncodings;
    NSArray* indianEncodings;

    NSArray* nearEastEncodings;
    NSArray* africanEncodings;
    NSArray* unicodeEncodings;
    
    NSArray* weiredEncodings;

    id __strong target;
    
}
@property (strong) id target;

- (NSMenu*) encodingsMenuWithAction: (SEL)theAction;
- (void) createEncodingsArrays;
- (NSMenuItem*) menuItemForCFStringEncoding: (NSNumber*) encNo withAction: (SEL) theAction;
@end
