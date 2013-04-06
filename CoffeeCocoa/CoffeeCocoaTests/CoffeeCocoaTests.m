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
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testInit
{
    CoffeeCocoa *cc = [CoffeeCocoa new];
    STAssertNotNil(cc, nil);
}

- (void)testCocoaPrint
{
    CoffeeCocoa *cc = [CoffeeCocoa new];
    
    __block BOOL executed = NO;
    [cc.cocoa setPrint:^(id msg) {
        STAssertEqualObjects(msg, @"cocoa.print()", nil);
        executed = YES;
    }];
    [cc evalCoffeeScript:@"cocoa.print 'cocoa.print()'"];
    STAssertTrue(executed, nil);
}

- (void)testExtendFunction
{
    CoffeeCocoa *cc = [CoffeeCocoa new];
    
    __block BOOL executed = NO;
    [cc extendFunction:@"extendA" inObject:@"window" handler:^id(id object) {
        executed = YES;
        return object;
    }];
    [cc evalCoffeeScript:@"extendA 'extend'" callback:^(id object) {
        STAssertEqualObjects(object, @"extend", nil);
    }];
    STAssertTrue(executed, nil);
}

- (void)testObjectSend
{
    CoffeeCocoa *cc = [CoffeeCocoa new];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    NSDictionary *subDict = @{@"title": @"title"};
    NSDictionary *obj = @{@"name": @"Kelp",
                          @"number": @10.11,
                          @"null": [NSNull null],
                          @"date": date,
                          @"sub": subDict,
                          @"array": @[@"A", @"B"]};
    
    __block NSUInteger executedTimes = 0;
    [cc extendFunction:@"get_object" inObject:@"window" handler:^id(id object) {
        executedTimes++;
        return obj;
    }];
    [cc evalCoffeeScript:@"func = (obj) ->\n"
     "  callback obj\n"
     "func get_object()"
                callback:^(id object) {
                    executedTimes++;
                    STAssertEqualObjects(object, obj, nil);
    }];
    STAssertEquals(executedTimes, 2UL, nil);
}

@end
