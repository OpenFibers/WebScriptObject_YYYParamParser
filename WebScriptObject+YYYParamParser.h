//
//  WebScriptObject+YYYParamParser.h
//  WYYYY
//
//  Created by openthread on 2/12/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface WebScriptObject (YYYParamParser)

+ (NSNumber *)NSNumerWithJSValue:(JSValueRef)valueRef context:(JSContextRef)context;
+ (NSString *)NSStringWithJSStrng:(JSStringRef)stringRef;
+ (NSString *)NSStringWithJSValue:(JSValueRef)valueRef context:(JSContextRef)context;
+ (NSDictionary *)NSDictionaryFromJSObject:(JSObjectRef)object context:(JSContextRef)context;
+ (NSObject *)NSObjectFromJSValue:(JSValueRef)value context:(JSContextRef)context;

@property (nonatomic, readonly) NSArray *arrayValue;
@property (nonatomic, readonly) NSString *stringValue;

- (id)callAsFunctionWithRootWebViewWithNullParam:(WebView *)rootWebView;
- (id)callAsFunctionWithRootWebViewWithUndefinedParam:(WebView *)rootWebView;
- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentBoolean:(BOOL)boolValue;
- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentNumber:(double)numberValue;
- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentString:(NSString *)string;
- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentArray:(NSArray *)array;
- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentDictionary:(NSDictionary *)dictionary;

- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView seperatedArguments:(NSArray *)array;

@end
