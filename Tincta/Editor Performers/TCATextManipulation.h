//
//  TCATextManipulation.h
//  tincta
//
//  Created by Julius on 23/09/14.
//
//

#import <Foundation/Foundation.h>

@interface TCATextManipulation : NSObject

+ (NSDictionary*)parametersForCommentingString:(NSString*)string inRange:(NSRange)range withToken:(NSString*)token;
+ (NSDictionary*)parametersForUncommentingString:(NSString*)string inRange:(NSRange)range withToken:(NSString*)token;

+ (NSDictionary*)parametersForSurroundString:(NSString*)string inRange:(NSRange)range withTokens:(NSArray*)tokens andActionNames:(NSArray*)names;
+ (NSDictionary*)parametersForRemoveSurroundingTokens:(NSArray*)tokens ofString:(NSString*)string inRange:(NSRange)range andActionNames:(NSArray*)names;

@end
