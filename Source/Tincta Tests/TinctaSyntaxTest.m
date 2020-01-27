//
//  TinctaSyntaxTest.m
//  tincta
//
//  Created by Julius on 29/01/14.
//
//

#import <XCTest/XCTest.h>
#import "TCAScanner.h"


@interface TinctaSyntaxTest : XCTestCase

@end

@implementation TinctaSyntaxTest

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

- (void)testScanUpToString
{
    NSString* testString = @"1234567890abcdefg*+#!$%&";
    TCAScanner* scanner = [TCAScanner scannerWithString:testString];
    [scanner scanUpToString:@"b"];
    XCTAssertTrue([scanner scanLocation] == [testString rangeOfString:@"b"].location, @"Location expected at %ld  but is at %ld", [scanner scanLocation], [testString rangeOfString:@"b"].location);

    XCTFail(@"Not fully implemented");
}

@end
