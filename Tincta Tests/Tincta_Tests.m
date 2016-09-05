//
//  Tincta_Tests.m
//  Tincta Tests
//
//  Created by Julius on 13/01/14.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import <XCTest/XCTest.h>

#import "TCABookmarkHelper.h"


@interface TinctaHelperTests : XCTestCase

@end

@implementation TinctaHelperTests

- (void)setUp
{
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
    [TCADefaultsHelper setIsNotFirstStart:YES];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [TCADefaultsHelper setIsNotFirstStart:NO];

    [super tearDown];
}

# pragma mark - DefaultsHelper

- (void)testGetTabWidth
{
    NSInteger defaultWidth = 4;

    NSInteger width = 9;
    [TCADefaultsHelper setTabWidth:width];
    XCTAssertEqual([TCADefaultsHelper getTabWidth], width, @"Expected Width: %ld", width);

    width = -10;
    [TCADefaultsHelper setTabWidth:width];
    XCTAssertEqual([TCADefaultsHelper getTabWidth], defaultWidth, @"Expected Width: %ld", defaultWidth);

    width = 0;
    [TCADefaultsHelper setTabWidth:width];
    XCTAssertEqual([TCADefaultsHelper getTabWidth], defaultWidth, @"Expected Width: %ld", defaultWidth);

}

- (void)testGetPageGuidColumn
{
    NSInteger defaultPosition = 80;

    NSInteger position = 100;
    [TCADefaultsHelper setPageGuideColumn:position];
    XCTAssertEqual([TCADefaultsHelper getPageGuideColumn], position, @"Expected Position: %ld", position);

    position = -20;
    [TCADefaultsHelper setPageGuideColumn:position];
    XCTAssertEqual([TCADefaultsHelper getPageGuideColumn], defaultPosition, @"Expected Position: %ld", defaultPosition);

    position = 0;
    [TCADefaultsHelper setPageGuideColumn:position];
    XCTAssertEqual([TCADefaultsHelper getPageGuideColumn], defaultPosition, @"Expected Position: %ld", defaultPosition);

}

- (void)testGetDefaultSyntaxDefiniton {
    NSString* defaultDef = @"None";

    NSString* testDef = @"JavaScript";
    [TCADefaultsHelper setDefaultSyntaxDefinition:testDef];
    XCTAssertEqualObjects([TCADefaultsHelper getDefaultSyntaxDefinition], testDef, @"Expected Syntax def: %@", testDef);

    testDef = @"fasdflk";
    [TCADefaultsHelper setDefaultSyntaxDefinition:testDef];
    XCTAssertEqualObjects([TCADefaultsHelper getDefaultSyntaxDefinition], defaultDef, @"Expected Syntax def: %@", defaultDef);

    testDef = nil;
    [TCADefaultsHelper setDefaultSyntaxDefinition:testDef];
    XCTAssertEqualObjects([TCADefaultsHelper getDefaultSyntaxDefinition], defaultDef, @"Expected Syntax def: %@", defaultDef);
}

- (void)testGetEditorFont {

    NSFont* defaultFont = [NSFont fontWithName:@"Menlo Regular" size:11.0f];
    NSFont* testFont = [NSFont fontWithName:@"Arial" size:11.0f];

    XCTAssertEqualObjects([TCADefaultsHelper getEditorFont], defaultFont, @"Expected Syntax def: %@", defaultFont.description);

    [TCADefaultsHelper setEditorFont:testFont];
    XCTAssertEqualObjects([TCADefaultsHelper getEditorFont], testFont, @"Expected Syntax def: %@", testFont.description);

    testFont = [NSFont fontWithName:@"blhfdgdg" size:11.0f];
    [TCADefaultsHelper setEditorFont:testFont];
    XCTAssertEqualObjects([TCADefaultsHelper getEditorFont], defaultFont, @"Expected Syntax def: %@", defaultFont.description);

    testFont = nil;
    [TCADefaultsHelper setEditorFont:testFont];
    XCTAssertEqualObjects([TCADefaultsHelper getEditorFont], defaultFont, @"Expected Syntax def: %@", defaultFont.description);
}

- (void)testGetAttributesColor {

    NSColor* defaultColor = [NSColor colorWithDeviceRed:0.48f green:0.0f blue:0.72f alpha:1.0f];
    NSColor* testColor = [NSColor colorWithDeviceRed:0.9f green:0.9f blue:0.9f alpha:1.0f];
    [TCADefaultsHelper setAttributesColor:testColor];
    XCTAssertEqualObjects([TCADefaultsHelper getAttributesColor], testColor, @"Expected Color def: %@", testColor.description);

    testColor = nil;
    [TCADefaultsHelper setAttributesColor:testColor];
    XCTAssertEqualObjects([TCADefaultsHelper getAttributesColor], defaultColor, @"Expected Color def: %@", defaultColor.description);
}


- (void)testGetRecentItemsBookmarks {
    NSArray* testArray = @[@"bla", @"blu", @"bli"];
    [TCADefaultsHelper setRecentItemsBookmarks:testArray];
    XCTAssertEqualObjects([TCADefaultsHelper getRecentItemsBookmarks], testArray, @"Expected array: %@", testArray);
    [TCADefaultsHelper setRecentItemsBookmarks:nil];
    XCTAssertTrue([[TCADefaultsHelper getRecentItemsBookmarks] count] == 0, @"Expected nil");
}

- (void)testGetOpenFilesToRestoreBookmarks {
    NSArray* testArray = @[@"bla", @"blu", @"bli"];
    [TCADefaultsHelper setOpenFilesToRestoreBookmarks:testArray];
    XCTAssertEqualObjects([TCADefaultsHelper getOpenFilesToRestoreBookmarks], testArray, @"Expected array: %@", testArray);
    [TCADefaultsHelper setOpenFilesToRestoreBookmarks:nil];
    XCTAssertTrue([[TCADefaultsHelper getOpenFilesToRestoreBookmarks] count] == 0, @"Expected nil");
}

- (void)testGetFileBrowserBaseBookmark {
}

- (void)testGetFileBrowserRootFolder {
    NSString* testPath = @"pathTo/bla";
    [TCADefaultsHelper setFileBrowserRootFolder:testPath];
    XCTAssertEqualObjects([TCADefaultsHelper getFileBrowserRootFolder], testPath, @"Expected path: %@", testPath);
    [TCADefaultsHelper setFileBrowserRootFolder:nil];
    XCTAssertEqualObjects([TCADefaultsHelper getFileBrowserRootFolder], @"", @"Expected empy string");
}

# pragma mark - Bookmarkshelper

- (void)testUrlForBookmarkData {
    NSURL* testUrl = [NSURL URLWithString:@"/bin/ls"];

    NSData* testBookmark = [TCABookmarkHelper bookmarkForUrl:testUrl];
        XCTAssertEqualObjects([TCABookmarkHelper urlForBookmarkData:testBookmark], NULL, @"Expected Url %@", testUrl);

    XCTAssertNil([TCABookmarkHelper urlForBookmarkData:nil], @"Expected nil");
    XCTAssertNil([TCABookmarkHelper bookmarkForUrl:nil], @"Ecpected nil");
}

@end
