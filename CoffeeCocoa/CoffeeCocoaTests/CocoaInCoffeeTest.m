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

@end
