//
//  LexicalState.m
//  tincta
//
//  Created by Julius Peinelt on 21.10.12.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import "LexicalState.h"

@implementation LexicalState


@synthesize primaryState, secondaryState, blockNumber;


#pragma mark -
#pragma mark INIT

- (id)init
{
    self = [super init];
    if (self) {
        [self setToDefaultStates];
    }
    return self;
}

- (id)initWithPrimaryState:(TCState)firstState andSecondaryState:(TCState)secondState andBlockNumber:(NSInteger)number {
    self = [super init];
    if (self) {
        primaryState = firstState;
        secondaryState = secondState;
        blockNumber = number;
    }
    return self;
}

- (id)initWithLexicalState:(LexicalState* )otherState {
    self = [super init];
    if (self) {
        primaryState = otherState.primaryState;
        secondaryState = otherState.secondaryState;
        blockNumber = otherState.blockNumber;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[LexicalState alloc] initWithLexicalState:self];
}


#pragma mark HELPER

- (BOOL)isEqualTo:(LexicalState*)otherState {
    return (otherState.primaryState == primaryState
        && otherState.secondaryState == secondaryState
            && otherState.blockNumber == blockNumber);
}

- (BOOL)isEqual:(id)object {
    if ([object class] == [self class]) {
        return [self isEqualTo:(LexicalState* )object];
    }
    return NO;
    
}


- (void)setToDefaultStates {
    self.primaryState = eText;
    self.secondaryState = eText;
    self.blockNumber = -1;
}


#pragma mark -

@end
