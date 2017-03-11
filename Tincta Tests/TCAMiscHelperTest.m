//
//  TCAMiscHelperTest.m
//  tincta
//
//  Created by Julius on 02/10/14.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "TCAMiscHelper.h"

@interface TCAMiscHelperTest : XCTestCase

@end

@implementation TCAMiscHelperTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStringBoundsCheck {
    NSString* testString = @"these here are 28 characters";
    NSRange passRange = NSMakeRange(3, 16);
    NSRange failRange1 = NSMakeRange(5, 44);
    NSRange passRange2 = NSMakeRange(8, 20);
    NSRange failRange3 = NSMakeRange(4, NSNotFound);
    NSRange failRange4 = NSMakeRange(NSNotFound, 2);
    NSRange failRange5 = NSMakeRange(NSNotFound, NSNotFound);
    NSRange failRange6 = NSMakeRange(4, (NSNotFound - 1));


    XCTAssert([TCAMiscHelper isRange:passRange inBoundOfString:testString], "Range should be in String");
    XCTAssertFalse([TCAMiscHelper isRange:failRange1 inBoundOfString:testString], "Range should not be in String");
    XCTAssert([TCAMiscHelper isRange:passRange2 inBoundOfString:testString], "Range should be in String");
    XCTAssertFalse([TCAMiscHelper isRange:failRange3 inBoundOfString:testString], "Range should not be in String");
    XCTAssertFalse([TCAMiscHelper isRange:failRange4 inBoundOfString:testString], "Range should not be in String");
    XCTAssertFalse([TCAMiscHelper isRange:failRange5 inBoundOfString:testString], "Range should not be in String");
    XCTAssertFalse([TCAMiscHelper isRange:failRange6 inBoundOfString:testString], "Range should not be in String");

}


@end
