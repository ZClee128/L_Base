//
//  FMHttpRequest.m
//  ZFMRACNetwork
//
//  Created by todriver02 on 2018/7/31.
//  Copyright © 2018年 zhufaming. All rights reserved.
//

#import "FMHttpRequest.h"

NSString *const kXQCNetworkPerformShowErrorMessageForKey = @"ofapeofjawfawfsldfmalsfa";
NSString *const kXQCNetworkPerformHiddenSomeErrorMessageCodeForKey = @"fjpaowejfpoqwe902efjalsdf";

@implementation ExtendsParameters

+ (instancetype)extendsParameters
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)version{
    static NSString *version = nil;
    if (version == nil) version = APP_BUNDLE_VERSION;
    return (version.length>0)?version:@"";
}

- (NSString *)token {
    // token 自己的逻辑
    return @"";
}

- (NSString *)deviceid {
    static NSString *deviceidStr = nil;
    //设备ID 自行逻辑获取
    return deviceidStr.length>0?deviceidStr:@"";
}

- (NSString *)platform{
    return @"iOS";
}

- (NSString *)channel{
    return @"AppStore";
}

- (NSString *)t {
    return [NSString stringWithFormat:@"%.f", [NSDate date].timeIntervalSince1970];
}

@end

@interface FMHttpRequest ()

@property (nonatomic, copy, readonly) NSDictionary *parametersSource;

@end

@implementation FMHttpRequest

+(instancetype)urlParametersWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    return [[self alloc] initUrlParametersWithMethod:method path:path parameters:parameters];
}

-(instancetype)initUrlParametersWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    self = [super init];
    if (self) {
        self.method = method;
        self.path = path;
        _parametersSource = parameters;
        self.parameters = self.realRequestParamters;
        self.extendsParameters = [[ExtendsParameters alloc] init];
    }
    return self;
}

+ (RACTuple *)realRequestParamters:(NSDictionary *)paramers
{
    if (![paramers.allKeys containsObject:kXQCNetworkPerformShowErrorMessageForKey] && ![paramers.allKeys containsObject:kXQCNetworkPerformHiddenSomeErrorMessageCodeForKey]) {
        return RACTuplePack(paramers);
    }
    NSMutableDictionary *realRequestParamters = [NSMutableDictionary dictionaryWithDictionary:paramers.mutableCopy];
    [realRequestParamters removeObjectForKey:kXQCNetworkPerformShowErrorMessageForKey];
    [realRequestParamters removeObjectForKey:kXQCNetworkPerformHiddenSomeErrorMessageCodeForKey];
    return RACTuplePack(realRequestParamters, paramers);
}

- (NSDictionary *)realRequestParamters
{
    return (NSDictionary *)[FMHttpRequest realRequestParamters:self.parametersSource].first;
}

@end

@implementation FMHttpRequest (Error)

- (BOOL)performShowErrorMessage
{
    if (self.parametersSource && self.parametersSource[kXQCNetworkPerformShowErrorMessageForKey]) {
        NSNumber *show = self.parametersSource[kXQCNetworkPerformShowErrorMessageForKey];
        return show.boolValue;
    }
    return YES;
}

@end
