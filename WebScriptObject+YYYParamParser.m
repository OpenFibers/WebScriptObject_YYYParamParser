//
//  WebScriptObject+YYYParamParser.m
//  WYYYY
//
//  Created by openthread on 2/12/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import "WebScriptObject+YYYParamParser.h"
#import "WebScriptNumberParam.h"

@implementation WebScriptObject (YYYParamParser)

#pragma mark - NSObjects From JSValueRef Methods

+ (NSNumber *)NSNumerWithJSValue:(JSValueRef)valueRef context:(JSContextRef)context
{
    JSValueRef exception;
    NSNumber *returnValue = nil;
    double value = JSValueToNumber(context, valueRef, &exception);
    if (!exception)
    {
        returnValue = [NSNumber numberWithDouble:value];
    }
    return returnValue;
}

+ (NSString *)NSStringWithJSStrng:(JSStringRef)stringRef;
{
    CFStringRef cfString = JSStringCopyCFString(kCFAllocatorDefault, stringRef);
    NSString *returnValue = (__bridge_transfer NSString *)cfString;
    return returnValue;
}

+ (NSString *)NSStringWithJSValue:(JSValueRef)valueRef context:(JSContextRef)context
{
    NSString *returnValue = nil;
    JSStringRef stringRef = JSValueToStringCopy(context, valueRef, nil);
    returnValue = [WebScriptObject NSStringWithJSStrng:stringRef];
    return returnValue;
}

+ (NSDictionary *)NSDictionaryFromJSObject:(JSObjectRef)object context:(JSContextRef)context
{
    JSPropertyNameArrayRef propertyNames = JSObjectCopyPropertyNames(context, object);
    
    size_t propertyCount = JSPropertyNameArrayGetCount(propertyNames);
    
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < propertyCount; i++)
    {
        JSStringRef propertyName = JSPropertyNameArrayGetNameAtIndex(propertyNames, i);
        NSString* key = [WebScriptObject NSStringWithJSStrng:propertyName];
        
        
        JSValueRef exception = nil;
        JSValueRef valueRef = JSObjectGetProperty(context, object, propertyName, &exception);
        
        if (exception != nil) {
            JSPropertyNameArrayRelease(propertyNames);
            return nil;
        }
        
        id value = [WebScriptObject NSObjectFromJSValue:valueRef context:context];
        if (value && key)
        {
            [properties setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:properties];
}

+ (NSObject *)NSObjectFromJSValue:(JSValueRef)value context:(JSContextRef)context
{
    JSValueRef exception = nil;
    
    id returnObjCValue;
    
    JSType jsType = JSValueGetType(context, value);
    switch (jsType)
    {
        case kJSTypeNull:
            returnObjCValue = [NSNull null];
            break;
        case kJSTypeBoolean:
            returnObjCValue = @(JSValueToBoolean(context, value));
            break;
        case kJSTypeNumber:
            returnObjCValue = @(JSValueToNumber(context, value, &exception));
            break;
        case kJSTypeUndefined:
        case kJSTypeString:
            returnObjCValue = [WebScriptObject NSStringWithJSValue:value context:context];
            break;
        case kJSTypeObject:
//            if (JSValueIsObjectOfClass(context, value, NativeObjectClass()))
//            {
//                return (__bridge id)JSObjectGetPrivate((JSObjectRef)value);
//            }
//            else if (JSValueIsObjectOfClass(context, value, BlockFunctionClass()))
//            {
//                return [NSString stringWithFormat:@"<Block Function %p>", JSObjectGetPrivate((JSObjectRef)value)];
//            }
//            else if (JSObjectIsFunction(context, (JSObjectRef)value))
//            {
//                returnObjCValue = ^(NSArray* parameters)
//                {
//                    return CallFunctionObject(context, (JSObjectRef)value, parameters, nil, NULL, nil);
//                };
//            }
//            else if (JSValueIsObjectOfClass(context, value, PointValueClass()))
//            {
//                JSObjectRef object = (JSObjectRef)value;
//                JSStringRef propertyName;
//                
//                propertyName = JSStringCreateWithUTF8CString("x");
//                JSValueRef xValue = JSObjectGetProperty(context, object, propertyName, &exception);
//                double x = JSValueToNumber(context, xValue, &exception);
//                JSStringRelease(propertyName);
//                
//                propertyName = JSStringCreateWithUTF8CString("y");
//                JSValueRef yValue = JSObjectGetProperty(context, object, propertyName, &exception);
//                double y = JSValueToNumber(context, yValue, &exception);
//                JSStringRelease(propertyName);
//                
//                CGPoint point = CGPointMake(x,y);
//                return [NSValue valueWithCGPoint:point];
//            }
//            else
            {
                JSObjectRef objectRef = JSValueToObject(context, value, &exception);
                if (!exception)
                {
                    returnObjCValue = [WebScriptObject NSDictionaryFromJSObject:objectRef context:context];
                }
            }
            break;
        default:
            break;
    }
    
    if (exception != nil)
    {
        NSError* error;
        NSString* errorString = [WebScriptObject NSStringWithJSValue:exception context:context];
        error = [NSError errorWithDomain:@"JavaScript" code:0 userInfo:@{NSLocalizedDescriptionKey:errorString}];
        return  error;
    }
    return returnObjCValue;
}

#pragma mark - NSObject from WebScriptObjects

- (NSArray *)arrayValue
{
    NSMutableArray *result = [NSMutableArray array];
    
	id elem = nil;
	int i = 0;
	WebUndefined *undefined = [WebUndefined undefined];
	while ((elem = [self webScriptValueAtIndex:i++]) != undefined)
    {
		[result addObject:elem];
	}
	return [NSArray arrayWithArray:result];
}

- (NSString *)stringValue
{
    NSString *result = [self evaluateWebScript:@"self.toString();"];
    return result;
}

#pragma mark - JSValueRef from NSObjects

+ (JSValueRef)JSValueRefFromNSObject:(id)object context:(JSContextRef)context
{
    JSValueRef resultRef = nil;
    if ([object isKindOfClass:[NSString class]])
    {
        resultRef = JSValueMakeString(context, JSStringCreateWithCFString((__bridge CFStringRef)object));
    }
    else if ([object isKindOfClass:[WebScriptNumberParam class]])
    {
        WebScriptNumberParamType numberType = ((WebScriptNumberParam *)object).paramType;
        switch (numberType)
        {
            case WebScriptNumberParamTypeNull:
                resultRef = JSValueMakeNull(context);
                break;
            case WebScriptNumberParamTypeUndefined:
                resultRef = JSValueMakeUndefined(context);
                break;
            case WebScriptNumberParamTypeBool:
            {
                BOOL cocoaBOOLValue = [((WebScriptNumberParam *)object).number doubleValue];
                resultRef = JSValueMakeBoolean(context, cocoaBOOLValue ? true : false);
            }
                break;
            case WebScriptNumberParamTypeNumber:
            default:
                resultRef = JSValueMakeNumber(context, [((WebScriptNumberParam *)object).number doubleValue]);
                break;
        }
    }
    else if ([object isKindOfClass:[NSNumber class]])
    {
        resultRef = JSValueMakeNumber(context, [((NSNumber *)object) doubleValue]);
    }
    else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]])
    {
        NSString *jsonString = [object JSONString];
        jsonString = [NSString stringWithFormat:@"var a = function(){return %@;}; a();", jsonString];
        JSStringRef scriptRef = JSStringCreateWithUTF8CString(jsonString.UTF8String);
        JSValueRef exception;
        resultRef = JSEvaluateScript(context, scriptRef, NULL, NULL, 0, &exception);
        JSStringRelease(scriptRef);
    }
    
    NSAssert([WebScriptObject NSObjectFromJSValue:resultRef context:context],
             @"can't convert js value back to NSObject!");
    return resultRef;
}

#pragma mark - WebScriptObject call as function

- (id)callAsFunctionWithRootWebViewWithNullParam:(WebView *)rootWebView
{
    WebScriptNumberParam *numberParam = [[WebScriptNumberParam alloc] init];
    numberParam.paramType = WebScriptNumberParamTypeNull;
    return [self callAsFunctionWithRootWebView:rootWebView singleArgument:numberParam];
}

- (id)callAsFunctionWithRootWebViewWithUndefinedParam:(WebView *)rootWebView
{
    WebScriptNumberParam *numberParam = [[WebScriptNumberParam alloc] init];
    numberParam.paramType = WebScriptNumberParamTypeUndefined;
    return [self callAsFunctionWithRootWebView:rootWebView singleArgument:numberParam];
}

- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentBoolean:(BOOL)boolValue
{
    NSNumber *number = [NSNumber numberWithBool:boolValue];
    WebScriptNumberParam *numberParam = [[WebScriptNumberParam alloc] init];
    numberParam.number = number;
    numberParam.paramType = WebScriptNumberParamTypeBool;
    return [self callAsFunctionWithRootWebView:rootWebView singleArgument:numberParam];
}

- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentNumber:(double)numberValue
{
    NSNumber *number = [NSNumber numberWithDouble:numberValue];
    WebScriptNumberParam *numberParam = [[WebScriptNumberParam alloc] init];
    numberParam.number = number;
    numberParam.paramType = WebScriptNumberParamTypeNumber;
    return [self callAsFunctionWithRootWebView:rootWebView singleArgument:number];
}

- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentString:(NSString *)string
{
    return [self callAsFunctionWithRootWebView:rootWebView singleArgument:string];
}

- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentArray:(NSArray *)array
{
    return [self callAsFunctionWithRootWebView:rootWebView singleArgument:array];
}

- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView argumentDictionary:(NSDictionary *)dictionary
{
    return [self callAsFunctionWithRootWebView:rootWebView singleArgument:dictionary];
}

- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView singleArgument:(id)argument
{
    return [self callAsFunctionWithRootWebView:rootWebView seperatedArguments:@[argument]];
}

- (id)callAsFunctionWithRootWebView:(WebView *)rootWebView seperatedArguments:(NSArray *)arguments
{
    NSMutableDictionary *info = [@{@"webview": rootWebView, @"arguments": arguments} mutableCopy];
    [self performSelectorOnMainThread:@selector(mainThreadCallAsFunctionWithInfo:) withObject:info waitUntilDone:YES];
//    [self mainThreadCallAsFunctionWithInfo:info]; //bad usage!
    return info[@"return"];
}

- (void)mainThreadCallAsFunctionWithInfo:(NSMutableDictionary *)info
{
    WebView *rootWebView = info[@"webview"];
    NSArray *arguments = info[@"arguments"];
    
    JSObjectRef objectRef = [self JSObject];
    JSContextRef context = [[rootWebView mainFrame] globalContext];
    
    JSValueRef paramRef[arguments.count];
    BOOL parseSuccessed = YES;
    for (int i = 0; i < arguments.count; i++)
    {
        id eachParam = arguments[i];
        id paramToParse = eachParam;
        if ([eachParam isKindOfClass:[NSNumber class]])
        {
            WebScriptNumberParam *param = [[WebScriptNumberParam alloc] init];
            param.number = eachParam;
            param.paramType = WebScriptNumberParamTypeNumber;
            paramToParse = param;
        }
        JSValueRef jsParam = [WebScriptObject JSValueRefFromNSObject:paramToParse context:context];
        if (!jsParam)
        {
            parseSuccessed = NO;
            break;
        }
        paramRef[i] = jsParam;
    }
    
    id value = nil;
    if (parseSuccessed)
    {
        JSValueRef valueRef = JSObjectCallAsFunction(context, objectRef, NULL, arguments.count, paramRef, NULL);
        if (valueRef)
        {
            value = [WebScriptObject NSObjectFromJSValue:valueRef context:context];
            info[@"return"] = value;
        }
        else
        {
            info[@"return"] = @"undefined";
        }
    }
}

@end
