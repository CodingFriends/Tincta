//
//  TCStateFactory.h
//  tincta
//
//  Created by Julius Peinelt on 12/4/12.
//
//

#import <Foundation/Foundation.h>
#import "LexicalState.h"

@interface TCStateFactory : NSObject {


    NSMutableDictionary* seenStates;
    

}


- (LexicalState* )getStateForState:(LexicalState* )lexicalState;


@end
