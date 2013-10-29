//
//  Cocoa.m
//  CoffeeCocoa
//
//  Created by Kelp on 2013/04/06.
//
//

#import "CocoaInCoffee.h"


#define JSON_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"


#if defined (__GNUC__) && (__GNUC__ >= 4)
#define CC_ATTRIBUTES(attr, ...) __attribute__((attr, ##__VA_ARGS__))
#else
#define CC_ATTRIBUTES(attr, ...)
#endif
#define CC_BURST_LINK static __inline__ CC_ATTRIBUTES(always_inline)


@interface CocoaInCoffee()
CC_BURST_LINK NSString *jsonFromNSObject(id object);
@end



@implementation CocoaInCoffee


#pragma mark - Init
- (id)init
{
    self = [super init];
    if (self) {
        _handlerIncrement = 0;
        _handlerPool = [NSMutableDictionary new];
    }
    return self;
}
- (id)initWithWebView:(WebView *)webView
{
    self = [self init];
    if (self) {
        _webView = webView;
    }
    return self;
}


#pragma mark - Properties
- (void)setPrint:(void (^)(id msg))print
{
    _print = print;
}
- (void)setError:(void (^)(id msg))error
{
    _error = error;
}


#pragma mark - WebView
+ (NSString *)webScriptNameForSelector:(SEL)selector
{
    NSString *name = nil;
    
    if (selector == @selector(print:))
        name = @"print";
    if (selector == @selector(error:))
        name = @"error";
    if (selector == @selector(handler:msg:))
        name = @"handler";
    
    return name;
}
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(print:))
        return NO;
    if (selector == @selector(error:))
        return NO;
    if (selector == @selector(handler:msg:))
        return NO;
    
    return YES;
}


#pragma mark - JavaScript functions
/**
 cocoa.print(msg) handler.
 */
- (void)print:(id)msg
{
    if (_print)
        _print([self nsobjectFromWebObject:msg]);
}
/**
 cocoa.error(msg) handler.
 */
- (void)error:(id)msg
{
    if (_error)
        _error([self nsobjectFromWebObject:msg]);
}
/**
 cocoa.handler(tag, msg) handler.
 */
- (id)handler:(NSNumber *)tag msg:(id)msg
{
    __block id (^handler)(id) = [_handlerPool objectForKey:tag];
    if (handler) {
        return jsonFromNSObject(handler([self nsobjectFromWebObject:msg]));
    }
    return nil;
}


#pragma mark - Handler
- (NSNumber *)addHandler:(id (^)(id))handler
{
    NSNumber *handlerId = [NSNumber numberWithUnsignedInteger:_handlerIncrement++];
    [_handlerPool setObject:handler forKey:handlerId];
    return handlerId;
}
- (void)removeHandlerById:(NSNumber *)handlerId
{
    [_handlerPool removeObjectForKey:handlerId];
}


#pragma mark - Private functions
/**
 JSON serializer for CoffeeCocoa.
 Support type: NSNull, NSString, NSNumber, NSDate, NSDictionary, NSArray
 @param object: NSObject
 @return: JSON string
 */
CC_BURST_LINK NSString *jsonFromNSObject(id object)
{
    if ([object isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"\"%@\"", cleanupString(object)];
    }
    else if ([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    }
    else if ([object isKindOfClass:[NSNull class]] || object == nil) {
        return @"null";
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableString *result = [NSMutableString new];
        [result appendString:@"{"];
        NSArray *keys = [object allKeys];
        for (NSUInteger index = 0; index < keys.count; index++) {
            NSString *key = [keys objectAtIndex:index];
            [result appendFormat:@"\"%@\":", cleanupString(key)];
            [result appendString:jsonFromNSObject([object objectForKey:key])];
            if (index < keys.count - 1) {
                [result appendString:@","];
            }
        }
        [result appendString:@"}"];
        return result;
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableString *result = [NSMutableString new];
        [result appendString:@"["];
        for (NSUInteger index = 0; index < [object count]; index++) {
            [result appendString:jsonFromNSObject([object objectAtIndex:index])];
            if (index < [object count] - 1) {
                [result appendString:@","];
            }
        }
        [result appendString:@"]"];
        return result;
    }
    else if ([object isKindOfClass:[NSDate class]]) {
        static dispatch_once_t once;
        static NSDateFormatter *formatter;
        dispatch_once(&once, ^{
            formatter = [NSDateFormatter new];
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"us"]];
            [formatter setDateFormat:JSON_DATE_FORMAT];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        });
        return [NSString stringWithFormat:@"\"%@\"", [formatter stringFromDate:object]];
    }
    return @"";
}
/**
 Replace chars in the string.
 ["\"", "\n", "\\"] -> ["\\\"", "\\\n", "\\\\"]
 @param source: source string
 @return: resoult
 */
NSString *cleanupString(NSString *source)
{
    if (source == nil) { return nil; }
    if (source.length == 0) { return @""; }
    
    NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger bufferLength = data.length;
    const unsigned char *sourceByes = data.bytes;
    NSUInteger bufferIndex = 0;
    unsigned char *buffer = malloc(data.length);
    
    for (NSUInteger index = 0; index < data.length; index++) {
        if (sourceByes[index] == '\"') {
            buffer = reallocf(buffer, ++bufferLength);
            buffer[bufferIndex++] = '\\';
            buffer[bufferIndex] = '"';
        }
        else if (sourceByes[index] == '\n') {
            buffer = reallocf(buffer, ++bufferLength);
            buffer[bufferIndex++] = '\\';
            buffer[bufferIndex] = 'n';
        }
        else if (sourceByes[index] == '\\') {
            buffer = reallocf(buffer, ++bufferLength);
            buffer[bufferIndex++] = '\\';
            buffer[bufferIndex] = '\\';
        }
        else {
            buffer[bufferIndex] = sourceByes[index];
        }
        bufferIndex++;
    }
    
    NSString *result = [[NSString alloc] initWithBytes:buffer length:bufferLength encoding:NSUTF8StringEncoding];
    free(buffer);
    return result;
}

/**
 Convert WebScriptObject(JavaScript object) to NSObject.
 @param webObject: WebScriptObject
 @return: NSObject
 */
- (NSObject *)nsobjectFromWebObject:(id)webObject
{
    if ([webObject isKindOfClass:[NSString class]]) {
        // string
        return webObject;
    }
    else if ([webObject isKindOfClass:[NSNumber class]]) {
        // number
        return webObject;
    }
    else if ([webObject isKindOfClass:[WebScriptObject class]]) {
        WebScriptObject *cocoa = [[_webView windowScriptObject] valueForKey:@"cocoa"];
        
        NSString *type = [cocoa callWebScriptMethod:@"_type_" withArguments:@[webObject]];
        if ([type isEqualToString:@"array"]) {
            // array
            NSUInteger length = [[webObject valueForKey:@"length"] unsignedIntegerValue];
            NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:length];
            for (NSUInteger index = 0; index < length; index++) {
                [result addObject:[self nsobjectFromWebObject:[webObject webScriptValueAtIndex:(unsigned)index]]];
            }
            return result;
        }
        else if ([type isEqualToString:@"dictionary"]) {
            // dictionary
            WebScriptObject *keys = [cocoa callWebScriptMethod:@"_keys_" withArguments:@[webObject]];
            NSUInteger length = [[keys valueForKey:@"length"] unsignedIntegerValue];
            NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:length];
            for (NSUInteger index = 0; index < length; index++) {
                NSString *key = [keys webScriptValueAtIndex:(unsigned)index];
                [result setObject:[self nsobjectFromWebObject:[webObject valueForKey:key]] forKey:key];
            }
            return result;
        }
        else if ([type isEqualToString:@"date"]) {
            static dispatch_once_t once;
            static NSDateFormatter *formatter;
            dispatch_once(&once, ^{
                formatter = [NSDateFormatter new];
                [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"us"]];
                [formatter setDateFormat:JSON_DATE_FORMAT];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            });
            NSString *dateString = [webObject callWebScriptMethod:@"toJSON" withArguments:nil];
            return [formatter dateFromString:dateString];
        }
    }
    
    return [NSNull null];
}


@end
