//
//  TCLineNumberViewTests.m
//  tincta
//
//  Created by Mr. Fridge on 31.01.14.
//
//

#import <XCTest/XCTest.h>
#import "TCTextView.h"
#import "TCLineNumberView.h"
#import "TCTextStorage.h"

@interface TCLineNumberViewTests : XCTestCase {
    TCTextView* _textView;
    TCLineNumberView* _lineNumberView;
    NSScrollView* _scrollView;
}
@end

@implementation TCLineNumberViewTests

- (void)setUp
{
    [super setUp];

    _scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 400, 400)];
    NSSize contentSize = [_scrollView contentSize];

    [_scrollView setBorderType:NSNoBorder];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:NO];
    [_scrollView setAutoresizingMask:NSViewWidthSizable |
     NSViewHeightSizable];

    [_scrollView setVerticalRulerView:_lineNumberView];
    [_scrollView setHasHorizontalRuler:NO];
    [_scrollView setHasVerticalRuler:YES];
    [_scrollView setRulersVisible:YES];

    _textView = [[TCTextView alloc] initWithFrame:NSMakeRect(0, 0, 378, 400)];
    [_textView setMinSize:NSMakeSize(0.0, contentSize.height)];
    [_textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [_textView setVerticallyResizable:YES];
    [_textView setHorizontallyResizable:NO];
    [_textView setAutoresizingMask:NSViewWidthSizable];

    [[_textView textContainer]
     setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
    [[_textView textContainer] setWidthTracksTextView:YES];





    [_scrollView setDocumentView:_textView];


    _lineNumberView = [[TCLineNumberView alloc] initWithScrollView:_scrollView];
    _lineNumberView.isWrappingDisabled = NO;
    [_lineNumberView resetLineNumbers];

    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testWrapsOfLine
{
    [_textView setString: [self testString3Lines]];

    XCTAssertEqual((NSUInteger)239, [(TCTextStorage*)_textView.textStorage lineRangeOfLine:0].length, "length of line 0 should be 239");

    // 239 / 58 charsPerLine >= 4.1 => 5 lines
    //4 wraps == 5 lines
    XCTAssertEqual((NSInteger)4, [_lineNumberView wrapsOfLine:0], "wraps of line 0 should be 4");

    XCTAssertEqual((NSInteger)0, [_lineNumberView wrapsOfLine:-1], "wraps of line -1 should be 0");
    XCTAssertEqual((NSInteger)0, [_lineNumberView wrapsOfLine:10], "wraps of line 10 should be 0");


}


- (void)testWrapsOfString
{
    NSInteger lineWraps = [_lineNumberView calculateLineWrapsForString: @"That said, the bevy of Xbox One-related rumors that have been leaking onto the Internet this week are getting too big to ignore. The source this time around is a mysterious poster going by the handle ntkrnl on popular gaming forum NeoGAF."];

    // 239 / 58 charsPerLine >= 4.1 => 5 lines
    //4 wraps == 5 lines
    XCTAssertEqual((NSInteger)4, lineWraps, "wraps of string should be 4");

    lineWraps = [_lineNumberView calculateLineWrapsForString: @""];
    XCTAssertEqual((NSInteger)0, lineWraps, "wraps of string should be 0");


    lineWraps = [_lineNumberView calculateLineWrapsForString: @"That said, the bevy of Xbox One-related rumors that have b"];
    XCTAssertEqual((NSInteger)0, lineWraps, "wraps of string with length 58 should be 0");

    lineWraps = [_lineNumberView calculateLineWrapsForString: @"That said, the bevy of Xbox One-related rumors that have be"];
    XCTAssertEqual((NSInteger)1, lineWraps, "wraps of string with length 59 should be 1");

    //should break at dash (-) like on blank so the following should have 2 wraps
    lineWraps = [_lineNumberView calculateLineWrapsForString: @"That said, the blubb blubb blubb bevy of Xbox One-relateded rumors that have been leaking onto the Internet thisbl"];
    XCTAssertEqual((NSInteger)2, lineWraps, "wraps of string with length 59 should be 2");

    lineWraps = [_lineNumberView calculateLineWrapsForString: @"\n"];
    XCTAssertEqual((NSInteger)0, lineWraps, "wraps of string with length 1 should be 0");
}



- (void)testCharsPerLine {
    XCTAssertEqual((NSInteger)58, _lineNumberView.charsPerLine, "at width 400 chars per line should be 58");
}


- (NSString*) testString3Lines {
    return @"That said, the bevy of Xbox One-related rumors that have been leaking onto the Internet this week are getting too big to ignore. The source this time around is a mysterious poster going by the handle ntkrnl on popular gaming forum NeoGAF. \nLong-time forum moderator bishoptl has leared ntkrnl as a reliable source, meaning he has confirmed the poster's ties to internal Microsoft information in private communications (an unnamed Kotaku source also confirmed to the site that ntkrnl is connected to Microsoft). \nOther verified rumors posted on NeoGAF have had a mixed record of accuracy, and even with reliable sourcing, plans can change between the time a rumor is reported and the time a company makes an announcement.";
}

@end
