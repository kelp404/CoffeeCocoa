//
//  CoffeeCocoaTests.m
//  CoffeeCocoaTests
//
//  Created by Kelp on 2013/04/05.
//
//

#import "CoffeeCocoaTests.h"
#import "CoffeeCocoa.h"


@implementation CoffeeCocoaTests

- (void)setUp
{
    [super setUp];
    
    _cc = [CoffeeCocoa new];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testInit
{
    STAssertNotNil(_cc, nil);
}

- (void)testCocoaPrint
{
    __block BOOL executed = NO;
    [_cc.cocoa setPrint:^(id msg) {
        STAssertEqualObjects(msg, @"cocoa.print()", nil);
        executed = YES;
    }];
    [_cc evalCoffeeScript:@"cocoa.print 'cocoa.print()'"];
    STAssertTrue(executed, nil);
}

- (void)testExtendFunction
{
    __block BOOL executed = NO;
    [_cc extendFunction:@"extendA" inObject:@"window" handler:^id(id object) {
        executed = YES;
        return object;
    }];
    [_cc evalCoffeeScript:@"extendA 'extend'" callback:^(id object) {
        STAssertEqualObjects(object, @"extend", nil);
    }];
    STAssertTrue(executed, nil);
}

- (void)testCallback
{
    __block BOOL executed = NO;
    [_cc evalCoffeeScript:@"callback true" callback:^(id object) {
        executed = YES;
        STAssertEqualObjects(object, @1, nil);
    }];
    STAssertTrue(executed, nil);
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
                    STAssertEqualObjects(object, obj, nil);
    }];
    STAssertEquals(executedTimes, 2UL, nil);
}

- (void)testError
{
    __block BOOL executed = NO;
    [_cc.cocoa setError:^(id msg) {
        executed = YES;
    }];
    [_cc evalCoffeeScript:@"kelp@phate.org()"];
    STAssertTrue(executed, nil);
}

- (void)testJavaScript
{
    __block NSUInteger executedTimes = 0;
    [_cc.cocoa setPrint:^(id msg) {
        executedTimes++;
        STAssertEqualObjects(msg, @"test javascript", nil);
    }];
    [_cc evalJavaScript:@"cocoa.print('test javascript');"];
    [_cc evalJavaScript:@"callback();" callback:^(id object) {
        executedTimes++;
        STAssertEqualObjects(object, [NSNull null], nil);
    }];
    STAssertEquals(executedTimes, 2UL, nil);
}

@end
