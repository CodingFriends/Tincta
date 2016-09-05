//
//  TCStateFactory.m
//  tincta
//
//  Created by Julius Peinelt on 12/4/12.
//
//

#import "TCStateFactory.h"

@implementation TCStateFactory

- (id)init {
    
    self = [super init];
    if (self) {
        
        seenStates = [[NSMutableDictionary alloc] initWithCapacity:64];
        
    }
    return self;
    
}


- (LexicalState* )getStateForState:(LexicalState *)lexicalState {
    
    LexicalState* returnState;
    if ((returnState = [seenStates objectForKey:lexicalState])) {
        return returnState;
    } else {
        returnState = [[LexicalState alloc] initWithLexicalState:lexicalState];
        [seenStates setObject:returnState forKey:lexicalState];
        return returnState;
    }

}


@end
