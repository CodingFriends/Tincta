//
//  TCAMiscHelper.m
//  tincta
//
//  Created by Julius on 02/10/14.
//
//

#import "TCAMiscHelper.h"

@implementation TCAMiscHelper

+ (BOOL)isRange:(NSRange)aRange inBoundOfString:(NSString*)aString {
    NSInteger loc = (NSInteger)aRange.location;
    NSInteger len = (NSInteger)aRange.length;
    NSInteger strLen = (NSInteger)aString.length;

    return aRange.location != NSNotFound && aRange.length != NSNotFound && (loc + len <= strLen);
}

@end
