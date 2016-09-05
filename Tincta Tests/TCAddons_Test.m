//
//  Addons_Test.m
//  Wokabulary
//
//  Created by Mr. Fridge on 2014. 3. 1..
//
//

#import <XCTest/XCTest.h>
#import "TCAUpgradePopupController.h"
@interface TCAddons_Test : XCTestCase {
    
    TCAUpgradePopupController* addonsController;
}

@end

@implementation TCAddons_Test

- (void)setUp
{
    [super setUp];
    
    addonsController = [[TCAUpgradePopupController alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

    

    
- (void)testEncoding
    {
        NSString* original = @"hello";
        NSString* code = [addonsController encode:original];
        NSString* decoded = [addonsController decode:code];
        XCTAssertTrue([decoded hasPrefix:original], @"code should start with original");
        
        original = @"syncingAddon";
        code = [addonsController encode:original];
        decoded = [addonsController decode:code];
        XCTAssertTrue([decoded hasPrefix:original], @"code should start with original");

        original = @"HELLO";
        code = [addonsController encode:original];
        decoded = [addonsController decode:code];
        XCTAssertTrue([decoded hasPrefix:original], @"code should start with original");
        
    }
    
@end
