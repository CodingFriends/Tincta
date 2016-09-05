//
//  LexicalState.h
//  tincta
//
//  Created by Julius Peinelt on 21.10.12.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <Foundation/Foundation.h>


typedef enum TCStyle : NSUInteger {
    eText,
    eKeyword,
    ePredefined,
    eCharString,
    eSingleString,
    eMultiString,
    eSingleComment,
    eMultiComment,
    eTag,
    eBlock,
    eAttribute,
    eVariable,
    eFunction
} TCState;

@interface LexicalState : NSObject <NSCopying> {

}

@property (assign) TCState primaryState;
@property (assign) TCState secondaryState;
@property (assign) NSInteger blockNumber;

- (id)initWithPrimaryState:(TCState)firstState andSecondaryState:(TCState)secondState andBlockNumber:(NSInteger)number;
- (id)initWithLexicalState:(LexicalState*)otherState;
- (BOOL)isEqualTo:(LexicalState*)otherState;
- (BOOL)isEqual:(id)object;

//Helper
- (void)setToDefaultStates;

@end
