//
//  TCTextAttributesFactory.h
//  tincta
//
//  Created by Julius Peinelt on 12/4/12.
//
//

#import <Foundation/Foundation.h>
#import "TCTextView.h"

@interface TCTextAttributesFactory : NSObject {
    
    NSMutableDictionary* seenTextAttributes;
    
}

- (NSDictionary* )getAttributeForColorDictionary:(NSDictionary* )color WithTextView:(TCTextView* )textView;
- (void)reset;

@end
