//
//  TCAEditTest.m
//  tincta
//
//  Created by Julius on 22/09/14.
//
//

#import <XCTest/XCTest.h>
#import "TCATextManipulation.h"
#import "TCTextView.h"

@interface TCAEditTest : XCTestCase {

}

@end

@implementation TCAEditTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSingleLineCommentingParameters {
    NSString* uncommentedSingleLine = @"this is a testline";
    NSRange cursor = NSMakeRange(3, 1);
    NSString* token = @"//";
    NSString* commentToken = @"// ";

    NSDictionary* dict = [TCATextManipulation parametersForCommentingString:uncommentedSingleLine
                                                                   inRange:cursor
                                                                 withToken:token];
    XCTAssertEqualObjects([dict objectForKey:@"workingString"],
                          commentToken,
                          @"workingString should be equal commentToken");
    XCTAssertEqualObjects([dict objectForKey:@"undoString"],
                          @"", @"undoString should be an empty NSString");
    XCTAssertEqualObjects([dict objectForKey:@"insertRanges"],
                          @[NSStringFromRange(NSMakeRange(0, 0))],
                          @"insertRanges should be an NSArray with one String from Range from 0 with length 0");
    XCTAssertEqualObjects([dict objectForKey:@"undoRanges"],
                          @[NSStringFromRange(NSMakeRange(0, commentToken.length))],
                          @"undoRanges should be an NSArray with one String from Range from 0 with to commentToken.length");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeString"],
                          NSStringFromRange(cursor),
                          @"selectedRangeString should be equal of cursor");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeStringAfterInsert"],
                          NSStringFromRange(NSMakeRange(cursor.location + commentToken.length, cursor.length)),
                          @"selectedRangeStringAfterInsert should start at curser position + commentToken length and have original lenght");
}

- (void)testMultiLineCommentingParameters {
    NSString* uncommentedMultilineLine = @"this is a testline!\nanonther testline";
    NSRange cursor = NSMakeRange(3, 20);
    NSString* token = @"//";
    NSString* commentToken = @"// ";

    NSArray* resultInsertRanges = @[NSStringFromRange(NSMakeRange(0, 0)),
                                    NSStringFromRange(NSMakeRange(20 + commentToken.length, 0))];
    NSArray* resultUndoRanges = @[NSStringFromRange(NSMakeRange(20 + commentToken.length, commentToken.length)),
                                  NSStringFromRange(NSMakeRange(0, commentToken.length))];

    NSDictionary* dict = [TCATextManipulation parametersForCommentingString:uncommentedMultilineLine
                                                                   inRange:cursor
                                                                 withToken:token];
    XCTAssertEqualObjects([dict objectForKey:@"workingString"],
                          commentToken,
                          @"workingString should be equal commentToken");
    XCTAssertEqualObjects([dict objectForKey:@"undoString"],
                          @"", @"undoString should be an empty NSString");
    XCTAssertEqualObjects([dict objectForKey:@"insertRanges"],
                          resultInsertRanges,
                          @"insertRanges should be an NSArray with 2 Ranges of location 0 and 20");
    XCTAssertEqualObjects([dict objectForKey:@"undoRanges"],
                          resultUndoRanges,
                          @"undoRanges should be an NSArray 2 Ranges with locations 0 and 20 + token lenght and each with length of the token");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeString"],
                          NSStringFromRange(cursor),
                          @"selectedRangeString should be equal of cursor");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeStringAfterInsert"],
                          NSStringFromRange(NSMakeRange(cursor.location + commentToken.length, cursor.length + commentToken.length)),
                          @"selectedRangeStringAfterInsert should start at curser position + token length and have  lenght of included token additions");
}


- (void)testMultiLineMixedCommentingParameters {
    NSString* mixedCommentedMultilineLine = @"this is a testline!\n// anonther testline\n//and another";
    NSRange cursor = NSMakeRange(14, 30);
    NSString* token = @"//";
    NSString* commentToken = @"// ";
    NSArray* resultInsertRanges = @[NSStringFromRange(NSMakeRange(0, 0)),
                                    NSStringFromRange(NSMakeRange(20 + commentToken.length, 0)),
                                    NSStringFromRange(NSMakeRange(41 + 2 * commentToken.length, 0))];
    NSArray* resultUndoRanges = @[NSStringFromRange(NSMakeRange(41 + 2 * commentToken.length, commentToken.length)),
                                  NSStringFromRange(NSMakeRange(20 + commentToken.length, commentToken.length)),
                                  NSStringFromRange(NSMakeRange(0, commentToken.length))];

    NSDictionary* dict = [TCATextManipulation parametersForCommentingString:mixedCommentedMultilineLine
                                                                   inRange:cursor
                                                                 withToken:token];
    XCTAssertEqualObjects([dict objectForKey:@"workingString"],
                          commentToken,
                          @"workingString should be equal commentToken");
    XCTAssertEqualObjects([dict objectForKey:@"undoString"], @"",
                          @"undoString should be an empty NSString");
    XCTAssertEqualObjects([dict objectForKey:@"insertRanges"],
                          resultInsertRanges,
                          @"insertRanges should be an NSArray with 2 Ranges of location 0 and 40 + token length");
    XCTAssertEqualObjects([dict objectForKey:@"undoRanges"],
                          resultUndoRanges,
                          @"undoRanges should be an NSArray 2 Ranges with locations 0 and 20 + token lenght and each with length of the token");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeString"],
                          NSStringFromRange(cursor),
                          @"selectedRangeString should be equal of cursor");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeStringAfterInsert"],
                          NSStringFromRange(NSMakeRange(cursor.location + commentToken.length, cursor.length + 2 * commentToken.length)),
                          @"selectedRangeStringAfterInsert should start at curser position + commentToken length and have lenght of included token additions");
}


- (void)testSingLineUncommentingParameters {
    NSString* commentedSingleLine = @"// this is a testline";
    NSRange cursor = NSMakeRange(2, 1);
    NSString* token = @"//";
    NSString* commentToken = @"// ";
    NSArray* resultInsertRanges = @[NSStringFromRange(NSMakeRange(0, commentToken.length))];
    NSArray* resultUndoRanges = @[NSStringFromRange(NSMakeRange(0, 0))];
    NSDictionary* dict = [TCATextManipulation parametersForUncommentingString:commentedSingleLine
                                                                   inRange:cursor
                                                                 withToken:token];
    XCTAssertEqualObjects([dict objectForKey:@"workingString"],
                          @"", @"workingString should be an empty string");
    XCTAssertEqualObjects([dict objectForKey:@"undoString"],
                          commentToken, @"undoString should be the commentToken");
    XCTAssertEqualObjects([dict objectForKey:@"insertRanges"],
                          resultInsertRanges,
                          @"insertRanges should be an NSArray with one String from Range from 0 with length of commentToken");
    XCTAssertEqualObjects([dict objectForKey:@"undoRanges"],
                          resultUndoRanges,
                          @"undoRanges should be an NSArray with one String from Range from 0 with lenght of 0");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeString"],
                          NSStringFromRange(cursor),
                          @"selectedRangeString should be equal of cursor");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeStringAfterInsert"],
                          NSStringFromRange(NSMakeRange(0, 0)),
                          @"selectedRangeStringAfterInsert should start at curser position - token length or 0 and have lenght 0");
}


- (void)testMultilineUncommentingParameters {
    NSString* commentedSingleLine = @"// this is a testline\n// and here another";
    NSRange cursor = NSMakeRange(5, 25);
    NSString* token = @"//";
    NSString* commentToken = @"// ";
    NSArray* resultInsertRanges = @[NSStringFromRange(NSMakeRange(22, commentToken.length)),
                                    NSStringFromRange(NSMakeRange(0, commentToken.length))];
    NSArray* resultUndoRanges = @[NSStringFromRange(NSMakeRange(0, 0)),
                                  NSStringFromRange(NSMakeRange(22, 0))];
    NSDictionary* dict = [TCATextManipulation parametersForUncommentingString:commentedSingleLine
                                                                     inRange:cursor
                                                                   withToken:token];
    XCTAssertEqualObjects([dict objectForKey:@"insertRanges"],
                          resultInsertRanges,
                          @"insertRanges should contain ranges with length of commentToken and the location 21 and 0");
    XCTAssertEqualObjects([dict objectForKey:@"undoRanges"],
                          resultUndoRanges,
                          @"undoRanges should contain ranges with the original comment locations 0 and 21 and length 0");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeString"],
                          NSStringFromRange(cursor),
                          @"selectedRangeString should be equal of cursor");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeStringAfterInsert"],
                          NSStringFromRange(NSMakeRange(2, 22)),
                          @"selectedRangeStringAfterInsert should start at curser position - token length = 2 and have lenght 22");
}

- (void)testMixedMultilineUncommentingParameters {
    NSString* commentedSingleLine = @"// this is a testline\nand here another\n// and a third";
    NSRange cursor = NSMakeRange(5, 38);
    NSString* token = @"//";
    NSString* commentToken = @"// ";
    NSArray* resultInsertRanges = @[
                                    NSStringFromRange(NSMakeRange(39, commentToken.length)),
                                    NSStringFromRange(NSMakeRange(0, commentToken.length))];
    NSArray* resultUndoRanges = @[NSStringFromRange(NSMakeRange(0, 0)),
                                  NSStringFromRange(NSMakeRange(39, 0))];
    NSDictionary* dict = [TCATextManipulation parametersForUncommentingString:commentedSingleLine
                                                                     inRange:cursor
                                                                   withToken:token];

    XCTAssertEqualObjects([dict objectForKey:@"insertRanges"],
                          resultInsertRanges, @"insertRanges should contain range with begin of second line (21)");
    XCTAssertEqualObjects([dict objectForKey:@"undoRanges"],
                          resultUndoRanges, @"undoRanges should contain ranges with the original comment location 21 and length 0");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeString"],
                          NSStringFromRange(cursor), @"selectedRangeString should be equal of cursor");
    XCTAssertEqualObjects([dict objectForKey:@"selectedRangeStringAfterInsert"],
                          NSStringFromRange(NSMakeRange(2, 35)),
                          @"selectedRangeStringAfterInsert should start at curser position - commentToken.lenght, lenght 35");
}


- (void)testTextViewCommenting {
    NSString* mixedCommentedMultilineLine = @"this is a testline!\n// anonther testline\n//and another";
    NSRange cursor = NSMakeRange(14, 30);
    TCTextView* textView = [[TCTextView alloc] initWithFrame:NSMakeRect(0.f, 0.f, 300.f, 100.f)];
    [textView setString:mixedCommentedMultilineLine];
    [textView setSelectedRange:cursor];
    [textView commentStringWithParameters:@{@"selectionRange": NSStringFromRange(cursor),
                                            @"token": @"//"}];
    XCTAssertEqualObjects([textView string],
                          @"// this is a testline!\n// // anonther testline\n// //and another",
                          @"textView string should be commented with the token and a space per line");
}


- (void)testTextViewUncommenting {
    NSString* mixedMultilineText = @"// this is a testline!\n// anonther testline\n//and another";
    NSRange cursor = NSMakeRange(14, 30);
    TCTextView* textView = [[TCTextView alloc] initWithFrame:NSMakeRect(0.f, 0.f, 300.f, 100.f)];
    [textView setString:mixedMultilineText];
    [textView setSelectedRange:cursor];
    [textView uncommentStringWithParameters:@{@"selectionRange": NSStringFromRange(cursor),
                                              @"token": @"//"}];
    XCTAssertEqualObjects([textView string],
                          @"this is a testline!\nanonther testline\n//and another",
                          @"textView string should uncommented");
}


- (void)testSurroundString {
    NSString* testString = @"this is\na funny test string.\nIt has mulitple lines.\nAnd one more.";
    NSString* resultString = @"thi<!--s is\na funny test string.\nIt ha-->s mulitple lines.\nAnd one more.";
    NSRange cursor = NSMakeRange(3, 31);    // thi ... s multiple
    NSArray* tokens = @[@"<!--", @"-->"];   // test with HTML comments
    NSArray* names = @[@"comment", @"uncomment"];
    NSDictionary* parameters = [TCATextManipulation parametersForSurroundString:testString inRange:cursor withTokens:tokens andActionNames:names];

    NSArray* resultInsertRanges = @[NSStringFromRange(NSMakeRange(3, 0)),
                                    NSStringFromRange(NSMakeRange(38, 0))];
    NSArray* resultUndoRanges = @[NSStringFromRange(NSMakeRange(38, 3)),
                                    NSStringFromRange(NSMakeRange(3, 4))];

    XCTAssertEqualObjects(parameters[@"insertRanges"],
                          resultInsertRanges,
                          @"ranges should be begin and end of selection");
    XCTAssertEqualObjects(parameters[@"undoRanges"],
                          resultUndoRanges,
                          @"ranges should be begin and end of selection with lenght of tokens");
    XCTAssertEqualObjects(parameters[@"selectedRangeString"],
                          NSStringFromRange(cursor),
                          @"the selection should match the cursor");
    XCTAssertEqualObjects(parameters[@"selectedRangeStringAfterInsert"],
                          NSStringFromRange(NSMakeRange(cursor.location, cursor.length + 7)),
                          @"selected range should surround all + length of tokens");

    TCTextView* textView = [[TCTextView alloc] initWithFrame:NSMakeRect(0.f, 0.f, 300.f, 100.f)];
    [textView setString:testString];
    [textView setSelectedRange:cursor];
    [textView commentStringWithParameters:@{@"selectionRange": NSStringFromRange(cursor),
                                            @"multilineTokens": tokens}];
    XCTAssertEqualObjects(textView.string, resultString, @"string should have html comment in it.");
}

- (void)testRemoveSourroundingStringParameters {
    NSString* testString = @"thi<!--s is\na funny test string.\nIt ha-->s mulitple lines.\nAnd one more.";
    NSString* resultString = @"this is\na funny test string.\nIt has mulitple lines.\nAnd one more.";
    NSRange cursor = NSMakeRange(3, 38);    // thi ... s multiple
    NSArray* tokens = @[@"<!--", @"-->"];   // test with HTML comments
    NSArray* names = @[@"uncomment", @"comment"];
    NSDictionary* parameters = [TCATextManipulation parametersForRemoveSurroundingTokens:tokens ofString:testString inRange:cursor andActionNames:names];

    NSArray* resultInsertRanges = @[NSStringFromRange(NSMakeRange(3, 4)),
                                    NSStringFromRange(NSMakeRange(34, 3))];
    NSArray* resultUndoRanges = @[NSStringFromRange(NSMakeRange(34, 0)),
                                  NSStringFromRange(NSMakeRange(3, 0))];

    XCTAssertEqualObjects(parameters[@"insertRanges"],
                          resultInsertRanges,
                          @"ranges should be begin and end of selection with length of tokens");
    XCTAssertEqualObjects(parameters[@"undoRanges"],
                          resultUndoRanges,
                          @"ranges should be begin and end of selection with length of 0");
    XCTAssertEqualObjects(parameters[@"selectedRangeString"],
                          NSStringFromRange(cursor),
                          @"the selection should match the cursor");
    XCTAssertEqualObjects(parameters[@"selectedRangeStringAfterInsert"],
                          NSStringFromRange(NSMakeRange(cursor.location, cursor.length - 7)));
    TCTextView* textView = [[TCTextView alloc] initWithFrame:NSMakeRect(0.f, 0.f, 300.f, 100.f)];
    [textView setString:testString];
    [textView setSelectedRange:cursor];
    [textView uncommentStringWithParameters:@{@"selectionRange": NSStringFromRange(cursor),
                                            @"multilineTokens": tokens}];
    XCTAssertEqualObjects(textView.string, resultString, @"string should have html comment in it.");

}


@end
