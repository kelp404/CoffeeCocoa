//
//  CocoaInCoffeeTest.m
//  CoffeeCocoa
//
//  Created by Kelp on 2013/08/13.
//
//

#import "CocoaInCoffee.h"
#import "CocoaInCoffeeTest.h"

@implementation CocoaInCoffeeTest

- (void)setUp
{
    [super setUp];
    
    _webView = [WebView new];
    _cic = [[CocoaInCoffee alloc] initWithWebView:_webView];
}

- (void)testInit
{
    STAssertNotNil(_cic, nil);
    STAssertEqualObjects(_cic.webView, _webView, nil);
}

- (void)testAddAndRemoveHandler
{
    NSNumber *handlerId = [_cic addHandler:^id(id object) {
        return @YES;
    }];
    STAssertEqualObjects(handlerId, @0, nil);
    [_cic removeHandlerById:handlerId];
    
    handlerId = [_cic addHandler:^id(id object) {
        return @NO;
    }];
    STAssertEqualObjects(handlerId, @1, nil);
    [_cic removeHandlerById:handlerId];
}

- (void)testCleanupString
{
    NSString *output = cleanupString(nil);
    STAssertNil(output, @"test nil");
    
    output = cleanupString(@"");
    STAssertEqualObjects(output, @"", @"test empty string");
    
    output = cleanupString(@"\n");
    STAssertEqualObjects(output, @"\\n", @"test new line char");
    
    output = cleanupString(@"\\");
    STAssertEqualObjects(output, @"\\\\", nil);
    
    output = cleanupString(@"\"");
    STAssertEqualObjects(output, @"\\\"", nil);
    
    NSString *javaScript = @"function() {\n"
    "return \"\t\";\n"
    "}";
    output = cleanupString(javaScript);
    STAssertEqualObjects(output, @"function() {\\nreturn \\\"\t\\\";\\n}", nil);
}



@end
