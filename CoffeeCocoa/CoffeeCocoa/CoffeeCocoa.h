//
//  CoffeeCocoa.h
//  CoffeeCocoa
//
//  Created by Kelp on 2013/04/05.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "CocoaInCoffee.h"



@interface CoffeeCocoa : NSObject

@property (strong, nonatomic, readonly) WebView *webView;
@property (strong, nonatomic, readonly) CocoaInCoffee *cocoa;

#pragma mark - Eval CoffeeScript
/**
 Eval CoffeeScript.
 @param coffeeScript: CoffeeScript
 */
- (void)evalCoffeeScript:(NSString *)coffeeScript;
/**
 Eval CoffeeScript with callback function.
 You could use `callback(object)` in CoffeeScript to call Objective-C code.
 @param coffeeScript: CoffeeScript
 @param handler: callback handler
 */
- (void)evalCoffeeScript:(NSString *)coffeeScript callback:(void (^)(id object))handler;

#pragma mark - Eval JavaScript
/**
 Eval JavaScript.
 The JavaScript will be eval in the function, like this `(function(){.........}).call(this);`.
 @param javaScript: JavaScript
 */
- (void)evalJavaScript:(NSString *)javaScript;
/**
 Eval JavaScript with callback function.
 You could use `callback(object)` in JavaScript to call Objective-C code.
 The JavaScript will be eval in the function, like this `(function(){.........}).call(this);`.
 @param javaScript: JavaScript
 @param handler: callback handler
 */
- (void)evalJavaScript:(NSString *)javaScript callback:(void (^)(id object))handler;

#pragma mark - Extend
/**
 Extend a function in JavaScript object;
 @param functionName: javascript function name
 @param objectName: javascript object name
 @param handler: function execute block
 @return: handler id
 */
- (NSNumber *)extendFunction:(NSString *)functionName inObject:(NSString *)objectName handler:(id (^)(id object))handler;
/**
 Remove Objective-C handler in the handler pool, it can't remove function in javascript.
 @param handlerId: handler id
 */
- (void)removeHandlerById:(NSNumber *)handlerId;

@end
