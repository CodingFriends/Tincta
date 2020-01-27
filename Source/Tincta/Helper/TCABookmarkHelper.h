//
//  TCBookmarkHelper.h
//  Tincta Pro
//
//  Created by Mr. Fridge on 2/23/13.
//
//

#import <Foundation/Foundation.h>

@interface TCABookmarkHelper : NSObject

+ (NSData*)bookmarkForUrl:(NSURL*)theUrl;
+ (NSURL*)urlForBookmarkData:(NSData*)theBookmark;
+ (void)startAccessingBookmarkUrl:(NSURL*)theBookmarkUrl;
+ (void)stopAccessingBookmarkUrl:(NSURL*)theBookmarkUrl;

@end
