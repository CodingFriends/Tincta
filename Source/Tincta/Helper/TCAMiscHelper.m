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
    NSUInteger loc = aRange.location;
    NSUInteger len = aRange.length;
    NSUInteger strLen = aString.length;

    return aRange.location != NSNotFound
    && aRange.length != NSNotFound
    && aRange.length <= strLen
    && aRange.location <= strLen
    && (loc + len <= strLen);
}

@end
