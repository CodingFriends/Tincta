//
//  TCTextAttributesFactory.m
//  tincta
//
//  Created by Julius Peinelt on 12/4/12.
//
//

#import "TCTextAttributesFactory.h"

@implementation TCTextAttributesFactory

- (id)init {
    self = [super init];
    if (self) {
        seenTextAttributes = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
    return self;
}


- (NSDictionary* )getAttributeForColorDictionary:(NSDictionary* )color WithTextView:(TCTextView* )textView {
    
    NSMutableDictionary* returnDict;
    if ((returnDict = [seenTextAttributes objectForKey:color])) {
        return returnDict;
    } else {
        returnDict = [NSMutableDictionary dictionaryWithDictionary:[textView typingAttributes]];
        [returnDict addEntriesFromDictionary:color];
        [seenTextAttributes setObject:returnDict forKey:color];
        return returnDict;
    }
}


- (void)reset {
    // TODO: improve performance by changing objects instead of removing
    [seenTextAttributes removeAllObjects];
    
}


@end
