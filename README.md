#CoffeeCocoa

Kelp https://twitter.com/kelp404  
[MIT License][mit]  
[MIT]: http://www.opensource.org/licenses/mit-license.php


Run **<a href="http://coffeescript.org/" target="_blank">CoffeeScript</a>** in **Cocoa**.  
This project use WebKit to run JavaScript not V8. And this version just supports OS X, it may be supported iOS in future.  


This idea is from <a href="https://github.com/kelp404/NyaruDB-Control" target="_blank">NyaruDB-Control</a> which is the <a href="https://github.com/kelp404/NyaruDB" target="_blank">NyaruDB</a> management tool. I want to build a tool to execute NyaruDB query syntax.  
But Objective-C need to be compiled. It doesn't like Python, Ruby or JavaScript.  
This project is for doing that.  
Enjoy It :-)  



##Frameworks
+ CoffeeScript 1.6.3
+ jQuery 2.0.3



##Data Type
It supports `NSNull`, `NSString`, `NSNumber`, `NSDate`, `NSDictionary` and `NSArray`.  

  Objective-C  |  JavaScript  
:---------:|:---------:
`NSNull` | `null`
`NSString` | `string`
`NSNumber ` | `number`, `true`, `false`
`NSDate` | `Date`
`NSDictionary` | `object`
`NSArray` | `Array`



##Methods
###Eval CoffeeScript
```objective-c
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
```


###Eval JavaScript
```objective-c
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
```


###Extend
```objective-c
/**
 Extend a function in JavaScript object;
 @param functionName: javascript function name
 @param objectName: javascript object name
 @param handler: function execute block
 @return: handler id
 */
- (NSNumber *)extendFunction:(NSString *)functionName inObject:(NSString *)objectName handler:(id (^)(id object))handler;
```



##Example
```objective-c
CoffeeCocoa *cc = [CoffeeCocoa new];

NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
NSDictionary *subDict = @{@"title": @"title"};
NSDictionary *obj = @{@"name": @"Kelp",
                      @"number": @10.11,
                      @"null": [NSNull null],
                      @"date": date,
                      @"sub": subDict,
                      @"array": @[@"A", @"B"]};

[cc extendFunction:@"get_object" inObject:@"window" handler:^id(id object) {
    return obj;
}];
[cc evalCoffeeScript:@"func = (obj) ->\n"
 "  callback obj\n"
 "func get_object()"
            callback:^(id object) {
                NSLog(@"%@", object);
}];
```



##Unittest
`/CoffeeCocoa/CoffeeCocoaTests`  
⌘ + U  



##Attention
Your should copy `/CoffeeCocoa/CoffeeCocoa/CoffeeScript` and `/CoffeeCocoa/CoffeeCocoa/JavaScript` into your bundle.  
