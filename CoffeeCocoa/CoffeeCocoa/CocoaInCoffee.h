//
//  Cocoa.h
//  CoffeeCocoa
//
//  Created by Kelp on 2013/04/06.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>


@interface CocoaInCoffee : NSObject {
    NSUInteger _handlerIncrement;
    NSMutableDictionary *_handlerPool;
}

@property (strong, nonatomic, readonly) WebView *webView;

- (id)initWithWebView:(WebView *)webView;


#pragma mark - Methods in JavaScript
/**
 cocoa.print(msg) handler.
 */
@property (strong, nonatomic) __block void (^print)(id msg);
/**
 cocoa.error(msg) handler.
 */
@property (strong, nonatomic) __block void (^error)(id msg);


#pragma mark - Handler
- (NSNumber *)addHandler:(id (^)(id object))handler;
- (void)removeHandlerById:(NSNumber *)handlerId;


// for [WebView windowScriptObject]
+ (NSString *)webScriptNameForSelector:(SEL)sel;
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector;


#pragma mark - C functions
NSString *cleanupString(NSString *source);


@end
