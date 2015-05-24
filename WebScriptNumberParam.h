//
//  NSNumber+WebScriptObjectParamType.h
//  163Music
//
//  Created by openthread on 2/25/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WebScriptNumberParamTypeNumber = 0,
    WebScriptNumberParamTypeNull,
    WebScriptNumberParamTypeUndefined,
    WebScriptNumberParamTypeBool
}WebScriptNumberParamType;

@interface WebScriptNumberParam : NSObject

@property (nonatomic, assign) WebScriptNumberParamType paramType;
@property (nonatomic, retain) NSNumber *number;

@end
