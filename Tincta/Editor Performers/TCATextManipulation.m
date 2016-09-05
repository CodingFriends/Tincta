//
//  TCATextManipulation.m
//  tincta
//
//  Created by Julius on 23/09/14.
//
//

#import "TCATextManipulation.h"
#import "TCAMiscHelper.h"

@implementation TCATextManipulation

+ (NSDictionary*)parametersForCommentingString:(NSString*)string inRange:(NSRange)range withToken:(NSString*)token {

    // adding a space after the comment token like most coding styles want it to be
    NSString* commentToken = [NSString stringWithFormat:@"%@ ", token];

    NSMutableArray* insertRanges = [NSMutableArray arrayWithCapacity:16];
    NSMutableArray* undoRanges = [NSMutableArray arrayWithCapacity:16];

    NSInteger selLength = range.length;
    NSInteger selMax = NSMaxRange(range);

    NSInteger addedInFront = 0;
    NSInteger addedInside = 0;

    NSInteger lineStart = [string lineRangeForRange:range].location;
    do {
        NSRange lineRange = NSMakeRange(lineStart, NSMaxRange([string lineRangeForRange:NSMakeRange(lineStart, 0)])-lineStart);
        NSRange replaceRange = NSMakeRange(lineStart + commentToken.length * [insertRanges count], 0);
        [insertRanges addObject:NSStringFromRange(replaceRange)];

        NSRange undoReplaceRange = NSMakeRange(replaceRange.location, commentToken.length);
        [undoRanges insertObject:NSStringFromRange(undoReplaceRange) atIndex:0];

        // immer wenn commentare eingefügt werden wo auch selektiert ist wächst die selektion
        // wenn davor eingefügt wird dann verschiebt sie sich
        if (replaceRange.location < range.location) {
            addedInFront = addedInFront + commentToken.length;
        } else {
            addedInside = addedInside + commentToken.length;
        }
        //get range of next line
        lineStart = NSMaxRange(lineRange);
    } while (lineStart < selMax);

    NSRange rangeAfterInsert = NSMakeRange(range.location + addedInFront, selLength + addedInside);
    return @{
             @"workingString" : [commentToken copy],
             @"undoString": @"",
             @"insertRanges" : insertRanges,
             @"undoRanges" : undoRanges,
             @"selectedRangeString" : NSStringFromRange(range),
             @"selectedRangeStringAfterInsert" : NSStringFromRange(rangeAfterInsert),
             @"doActionName" : @"Comment",
             @"undoActionName" : @"Uncomment"
             };
}


+ (NSDictionary*)parametersForUncommentingString:(NSString*)string inRange:(NSRange)range withToken:(NSString*)token {

    // adding a space after the comment token like most coding styles want it to be
    NSString* commentToken = [NSString stringWithFormat:@"%@ ", token];

    NSMutableArray* removeRanges = [NSMutableArray arrayWithCapacity:16];
    NSMutableArray* undoRanges = [NSMutableArray arrayWithCapacity:16];

    NSInteger selMax = NSMaxRange(range);

    NSInteger sumCommentsIntersectWithSelection = 0;
    NSInteger charsDeletedInFront = 0;

    NSInteger lineStart = [string lineRangeForRange:range].location;
    do {
        NSRange lineRange = NSMakeRange(lineStart, NSMaxRange([string lineRangeForRange:NSMakeRange(lineStart, 0)])-lineStart);

        NSRange tokenRange = NSMakeRange(lineRange.location, commentToken.length);
        if ([TCAMiscHelper isRange:tokenRange inBoundOfString:string]
            && [[string substringWithRange:tokenRange] isEqualToString:commentToken]) {
            NSRange replaceRange = NSMakeRange(lineStart, commentToken.length);
            [removeRanges insertObject:NSStringFromRange(replaceRange) atIndex:0];

            NSRange undoReplaceRange = NSMakeRange(replaceRange.location, 0);
            [undoRanges addObject:NSStringFromRange(undoReplaceRange)];

            if (replaceRange.location < range.location) {
                NSInteger difference = range.location - replaceRange.location;
                charsDeletedInFront = difference < commentToken.length ? difference : commentToken.length;
            }

            sumCommentsIntersectWithSelection = sumCommentsIntersectWithSelection + NSIntersectionRange(range, replaceRange).length;
        }

        //get range of next line
        lineStart = NSMaxRange(lineRange);
    } while (lineStart < selMax);

    NSInteger newLoc = MAX(range.location - charsDeletedInFront, 0);
    NSInteger newLen = MAX(range.length - sumCommentsIntersectWithSelection, 0);
    NSRange rangeAfterRemove = NSMakeRange(newLoc, newLen);
    return @{
             @"workingString" : @"",
             @"originalToken" : [token copy],
             @"undoString": [commentToken copy],
             @"insertRanges" : removeRanges,
             @"undoRanges" : undoRanges,
             @"selectedRangeString" : NSStringFromRange(range),
             @"selectedRangeStringAfterInsert" : NSStringFromRange(rangeAfterRemove),
             @"doActionName" : @"Uncomment",
             @"undoActionName" : @"Comment"
             };
}


+ (NSDictionary*)parametersForSurroundString:(NSString*)string inRange:(NSRange)range withTokens:(NSArray*)tokens andActionNames:(NSArray*)names {
    if (tokens.count != 2 || names.count != 2) {
        return nil;
    }
    NSInteger firstTokenLength = [(NSString*)tokens[0] length];
    NSInteger secondTokenLength = [(NSString*)tokens[1] length];
    NSArray* insertRanges = @[NSStringFromRange(NSMakeRange(range.location, 0)),
                              NSStringFromRange(NSMakeRange(range.location + range.length + firstTokenLength, 0))];
    NSArray* undoRanges = @[NSStringFromRange(NSMakeRange(range.location + range.length + firstTokenLength, secondTokenLength)),
                              NSStringFromRange(NSMakeRange(range.location, firstTokenLength))];
    return @{
             @"tokens" : tokens,
             @"undoTokens" : @[@"", @""],
             @"insertRanges" : insertRanges,
             @"undoRanges" : undoRanges,
             @"selectedRangeString" : NSStringFromRange(range),
             @"selectedRangeStringAfterInsert" : NSStringFromRange(NSMakeRange(range.location, range.length + firstTokenLength + secondTokenLength)),
             @"doActionName" : names[0],
             @"undoActionName" : names[1]
             };
}


+ (NSDictionary*)parametersForRemoveSurroundingTokens:(NSArray*)tokens ofString:(NSString*)string inRange:(NSRange)range andActionNames:(NSArray*)names {
    if (tokens.count != 2 || names.count != 2) {
        return nil;
    }
    NSInteger firstTokenLength = [(NSString*)tokens[0] length];
    NSInteger secondTokenLength = [(NSString*)tokens[1] length];

    NSMutableArray* insertRanges = [NSMutableArray arrayWithArray:@[NSStringFromRange(NSMakeRange(range.location, firstTokenLength))]];
    NSMutableArray* undoRanges = [NSMutableArray arrayWithArray:@[NSStringFromRange(NSMakeRange(range.location, 0))]];;

    if ([string substringWithRange:NSMakeRange(range.location + range.length - secondTokenLength, secondTokenLength)]) {
        [insertRanges addObject:NSStringFromRange(NSMakeRange(range.location + range.length - (firstTokenLength + secondTokenLength), secondTokenLength))];
        [undoRanges insertObject:NSStringFromRange(NSMakeRange(range.location + range.length - (firstTokenLength + secondTokenLength), 0)) atIndex:0];
    }

    return @{
             @"tokens" : @[@"", @""],
             @"undoTokens" : tokens,
             @"insertRanges" : insertRanges,
             @"undoRanges" : undoRanges,
             @"selectedRangeString" : NSStringFromRange(range),
             @"selectedRangeStringAfterInsert" : NSStringFromRange(NSMakeRange(range.location, range.length - (firstTokenLength + secondTokenLength))),
             @"doActionName" : names[0],
             @"undoActionName" : names[1]
             };
}


@end
