//
//  CoffeeCocoaTests.m
//  CoffeeCocoaTests
//
//  Created by Kelp on 2014/01/02.
//
//

#import <XCTest/XCTest.h>
#import "CoffeeCocoa.h"

@interface CoffeeCocoaTests : XCTestCase {
    CoffeeCocoa *_cc;
}

@end



@implementation CoffeeCocoaTests

- (void)setUp
{
    [super setUp];
    
    _cc = [CoffeeCocoa new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testInit
{
    XCTAssertNotNil(_cc, @"");
    XCTAssertNotNil(_cc.webView, @"");
}

- (void)testCocoaPrint
{
    __block BOOL executed = NO;
    __block NSString *printMsg;
    [_cc.cocoa setPrint:^(id msg) {
        executed = YES;
        printMsg = msg;
    }];
    [_cc evalCoffeeScript:@"cocoa.print 'cocoa.print()'"];
    XCTAssertTrue(executed, @"");
    XCTAssertEqualObjects(printMsg, @"cocoa.print()", @"");
}

- (void)testExtendFunction
{
    __block BOOL executed = NO;
    [_cc extendFunction:@"extendA" inObject:@"window" handler:^id(id object) {
        executed = YES;
        return object;
    }];
    [_cc evalCoffeeScript:@"extendA 'extend'" callback:^(id object) {
        XCTAssertEqualObjects(object, @"extend", @"");
    }];
    XCTAssertTrue(executed, @"");
}

- (void)testCallback
{
    __block BOOL executed = NO;
    [_cc evalCoffeeScript:@"callback true" callback:^(id object) {
        executed = YES;
        XCTAssertEqualObjects(object, @1, @"");
    }];
    XCTAssertTrue(executed, @"");
}

- (void)testObjectSend
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    NSDictionary *subDict = @{@"title": @"title"};
    NSDictionary *obj = @{@"name": @"Kelp",
                          @"number": @10.11,
                          @"null": [NSNull null],
                          @"date": date,
                          @"sub": subDict,
                          @"array": @[@"A", @"B"]};
    
    __block NSUInteger executedTimes = 0;
    [_cc extendFunction:@"get_object" inObject:@"window" handler:^id(id object) {
        executedTimes++;
        return obj;
    }];
    [_cc evalCoffeeScript:@"func = (obj) ->\n"
     "  callback obj\n"
     "func get_object()"
                 callback:^(id object) {
                     executedTimes++;
                     XCTAssertEqualObjects(object, obj, @"");
                 }];
    XCTAssertEqual(executedTimes, 2UL, @"");
}

- (void)testError
{
    __block BOOL executed = NO;
    [_cc.cocoa setError:^(id msg) {
        executed = YES;
    }];
    [_cc evalCoffeeScript:@"kelp@phate.org()"];
    XCTAssertTrue(executed, @"");
}

- (void)testJavaScript
{
    __block NSUInteger executedTimes = 0;
    __block NSString *printMsg;
    [_cc.cocoa setPrint:^(id msg) {
        executedTimes++;
        printMsg = msg;
    }];
    [_cc evalJavaScript:@"cocoa.print('test javascript');"];
    XCTAssertEqualObjects(printMsg, @"test javascript", @"");
    [_cc evalJavaScript:@"callback();" callback:^(id object) {
        executedTimes++;
        XCTAssertEqualObjects(object, [NSNull null], @"");
    }];
    XCTAssertEqual(executedTimes, 2UL, @"");
}

@end
