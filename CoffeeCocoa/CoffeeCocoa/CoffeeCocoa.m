//
//  CoffeeCocoa.m
//  CoffeeCocoa
//
//  Created by Kelp on 2013/04/05.
//
//

#import "CoffeeCocoa.h"



@implementation CoffeeCocoa

@synthesize webView = _webView;
@synthesize cocoa = _cocoa;

#pragma mark - Init
- (id)init
{
    self = [super init];
    if (self) {
        _webView = [WebView new];
        
        // load CoffeeScript
        NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"coffee-script.min" ofType:@"js"];
        NSString *coffeeScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [_webView stringByEvaluatingJavaScriptFromString:coffeeScript];
        
        // load jQuery
        path = [[NSBundle bundleForClass:self.class] pathForResource:@"jquery.min" ofType:@"js"];
        NSString *jQueryScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [_webView stringByEvaluatingJavaScriptFromString:jQueryScript];
        
        // object mapping
        WebScriptObject *win = [_webView windowScriptObject];
        _cocoa = [[CocoaInCoffee alloc] initWithWebView:_webView];
        [win setValue:_cocoa forKey:@"cocoa_"];
        
        // load cocoa.coffee
        path = [[NSBundle bundleForClass:self.class] pathForResource:@"cocoa" ofType:@"coffee"];
        NSString *cocoaScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [self evalCoffeeScript:cocoaScript];
    }
    return self;
}


#pragma mark - Eval CoffeeScript
- (void)evalCoffeeScript:(NSString *)coffeeScript
{
    NSString *script = [NSString stringWithFormat:@"var java_script = CoffeeScript.compile(\"%@\");"
                        "eval(java_script);", cleanupString(coffeeScript)];
    [_webView stringByEvaluatingJavaScriptFromString:script];
}
- (void)evalCoffeeScript:(NSString *)coffeeScript callback:(void (^)(id object))handler
{
    NSNumber *handlerId = [_cocoa addHandler:^id(id object) {
        if (handler)
            handler(object);
        return nil;
    }];
    NSString *callbackScript = [NSString stringWithFormat:@"callback = (msg) -> cocoa.handler(%@, msg)", handlerId];
    NSString *script = [NSString stringWithFormat:@"var java_script = CoffeeScript.compile(\"%@\\n%@\");"
                        "eval(java_script);", cleanupString(callbackScript), cleanupString(coffeeScript)];
    [_webView stringByEvaluatingJavaScriptFromString:script];
}


#pragma mark - Eval JavaScript
- (void)evalJavaScript:(NSString *)javaScript
{
    NSString *script = [NSString stringWithFormat:@"(function() {%@}).call(this);", javaScript];
    [_webView stringByEvaluatingJavaScriptFromString:script];
}
- (void)evalJavaScript:(NSString *)javaScript callback:(void (^)(id object))handler
{
    NSNumber *handlerId = [_cocoa addHandler:^id(id object) {
        if (handler)
            handler(object);
        return nil;
    }];
    NSString *callbackScript = [NSString stringWithFormat:@"var callback = function(msg) {cocoa.handler(%@, msg);}", handlerId];
    NSString *script = [NSString stringWithFormat:@"(function() {\n"
                        "%@\n"
                        "%@\n"
                        "}).call(this);", callbackScript, javaScript];
    [_webView stringByEvaluatingJavaScriptFromString:script];
}


#pragma mark - Extend
- (NSNumber *)extendFunction:(NSString *)functionName inObject:(NSString *)objectName handler:(id (^)(id object))handler;
{
    NSNumber *handlerId = [_cocoa addHandler:handler];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"jQuery.extend(%@, {%@:function(msg){return cocoa.handler(%@, msg);}});",
                                                      objectName,
                                                      functionName,
                                                      handlerId]];
    return handlerId;
}
- (void)removeHandlerById:(NSNumber *)handlerId
{
    [_cocoa removeHandlerById:handlerId];
}


@end
