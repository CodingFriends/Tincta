//
//  Tincta_Tests.m
//  Tincta Tests
//
//  Created by Mr. Fridge on 31.01.14.
//
//

#import <XCTest/XCTest.h>

#import "TCTextStorage.h"

@interface TCTextStorageTests : XCTestCase

@end

@implementation TCTextStorageTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNumberOfLines
{
    TCTextStorage* textStorage = [[TCTextStorage alloc] init];
    XCTAssertEqual((NSInteger)1, [textStorage numberOfLines], @"Number of lines should be 1");
    [textStorage replaceCharactersInRange:NSMakeRange(0, 0) withString:@"\n"];
    XCTAssertEqual((NSInteger)2, [textStorage numberOfLines], @"Number of lines should be 2");
    [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withString:[self testString3Lines]];
    XCTAssertEqual((NSInteger)3, [textStorage numberOfLines], @"Number of lines should be 3");
    [textStorage replaceCharactersInRange:NSMakeRange(200, 0) withString:@"asdf\nasdf"];
    XCTAssertEqual((NSInteger)4, [textStorage numberOfLines], @"Number of lines should be 4");

}


- (void) testLineRangeOfLine {
    TCTextStorage* textStorage = [[TCTextStorage alloc] init];
    NSRange lineRange = [textStorage lineRangeOfLine:0];

    XCTAssertEqual((NSUInteger)0, lineRange.location, @"line range should start at 0");
    XCTAssertEqual((NSUInteger)0, lineRange.length, @"line range should be 0 chars wide");


    [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withString:[self testString3Lines]];
    lineRange = [textStorage lineRangeOfLine:0];

    XCTAssertEqual((NSUInteger)0, lineRange.location, @"line range should start at 0");
    XCTAssertEqual((NSUInteger)239, lineRange.length, @"line range should be 239 chars wide");


    XCTAssertEqual((NSUInteger) NSNotFound, [textStorage lineRangeOfLine:8].location, @"range for non existing line should be NSNotFound");
}



- (void) testLineNumberForLocation {
    TCTextStorage* textStorage = [[TCTextStorage alloc] init];

    XCTAssertEqual((NSUInteger)0, [textStorage lineNumberForLocation:0], @"line of loc 0 should be 0");

    [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withString:[self testString3Lines]];

    XCTAssertEqual((NSUInteger)0, [textStorage lineNumberForLocation:0], @"line of loc 0 should be 0");
    XCTAssertEqual((NSUInteger)2, [textStorage lineNumberForLocation:720], @"line of loc 720 should be 2");
    XCTAssertEqual((NSUInteger)0, [textStorage lineNumberForLocation:239], @"line of loc 239 should be 0");
    XCTAssertEqual((NSUInteger)1, [textStorage lineNumberForLocation:240], @"line of loc 240 should be 1");

}

- (NSString*) testString3Lines {
    return @"That said, the bevy of Xbox One-related rumors that have been leaking onto the Internet this week are getting too big to ignore. The source this time around is a mysterious poster going by the handle ntkrnl on popular gaming forum NeoGAF. \nLong-time forum moderator bishoptl has leared ntkrnl as a reliable source, meaning he has confirmed the poster's ties to internal Microsoft information in private communications (an unnamed Kotaku source also confirmed to the site that ntkrnl is connected to Microsoft). \nOther verified rumors posted on NeoGAF have had a mixed record of accuracy, and even with reliable sourcing, plans can change between the time a rumor is reported and the time a company makes an announcement.";
}

@end
