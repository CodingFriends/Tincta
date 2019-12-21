//
//  TCBookmarkHelper.m
//  Tincta Pro
//
//  Created by Mr. Fridge on 2/23/13.
//
//

#import "TCABookmarkHelper.h"

@implementation TCABookmarkHelper

+ (NSData*)bookmarkForUrl:(NSURL*)theUrl {
    if (theUrl == nil) {
        return nil;
    }
    NSURLBookmarkCreationOptions options = NSURLBookmarkCreationMinimalBookmark;
    options = NSURLBookmarkCreationWithSecurityScope;
    NSData* bookmark = [theUrl bookmarkDataWithOptions:options includingResourceValuesForKeys:nil relativeToURL:nil error:NULL];
    return bookmark;
}


+ (NSURL*)urlForBookmarkData:(NSData*)theBookmark {
    if (theBookmark == nil) {
        return nil;
    }
    NSURLBookmarkResolutionOptions options = NSURLBookmarkResolutionWithoutMounting;
    options = options | NSURLBookmarkResolutionWithSecurityScope;
    BOOL isStale = NO;
    NSURL* url = [NSURL URLByResolvingBookmarkData:theBookmark options:options relativeToURL:nil bookmarkDataIsStale:&isStale error:NULL];
    return url;
}

+ (void)startAccessingBookmarkUrl:(NSURL*)theBookmarkUrl {
    if (theBookmarkUrl == nil) {
        return;
    }
    
    if ([theBookmarkUrl respondsToSelector:@selector(startAccessingSecurityScopedResource)]) {
        [theBookmarkUrl startAccessingSecurityScopedResource];
    }
}


+ (void)stopAccessingBookmarkUrl:(NSURL*)theBookmarkUrl {
    if (theBookmarkUrl == nil) {
        return;
    }
    
    if ([theBookmarkUrl respondsToSelector:@selector(stopAccessingSecurityScopedResource)]) {
        [theBookmarkUrl stopAccessingSecurityScopedResource];
    }
}

@end
