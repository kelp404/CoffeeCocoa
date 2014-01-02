//
//  CocoaInCoffeeTests.m
//  CoffeeCocoa
//
//  Created by Kelp on 2014/01/02.
//
//

#import <XCTest/XCTest.h>
#import "CocoaInCoffee.h"

@interface CocoaInCoffeeTests : XCTestCase {
    WebView *_webView;
    CocoaInCoffee *_cic;
}

@end



@implementation CocoaInCoffeeTests

- (void)setUp
{
    [super setUp];
    
    _webView = [WebView new];
    _cic = [[CocoaInCoffee alloc] initWithWebView:_webView];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testInit
{
    _cic = [CocoaInCoffee new];
    XCTAssertNotNil(_cic, @"");
    XCTAssertNotNil(_cic.webView, @"");
}

- (void)testInitWithWebView
{
    XCTAssertNotNil(_cic, @"");
    XCTAssertEqual(_cic.webView, _webView, @"");
}

- (void)testAddAndRemoveHandler
{
    NSNumber *handlerId = [_cic addHandler:^id(id object) {
        return @YES;
    }];
    XCTAssertEqualObjects(handlerId, @0, @"");
    [_cic removeHandlerById:handlerId];
    
    handlerId = [_cic addHandler:^id(id object) {
        return @NO;
    }];
    XCTAssertEqualObjects(handlerId, @1, @"");
    [_cic removeHandlerById:handlerId];
}

- (void)testCleanupString
{
    NSString *output = cleanupString(nil);
    XCTAssertNil(output, @"test nil");
    
    output = cleanupString(@"");
    XCTAssertEqualObjects(output, @"", @"test empty string");
    
    output = cleanupString(@"\n");
    XCTAssertEqualObjects(output, @"\\n", @"test new line char");
    
    output = cleanupString(@"\\");
    XCTAssertEqualObjects(output, @"\\\\", @"");
    
    output = cleanupString(@"\"");
    XCTAssertEqualObjects(output, @"\\\"", @"");
    
    NSString *javaScript = @"function() {\n"
    "return \"\t\";\n"
    "}";
    output = cleanupString(javaScript);
    XCTAssertEqualObjects(output, @"function() {\\nreturn \\\"\t\\\";\\n}", @"");
}

@end
