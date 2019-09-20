//
//  FMHttpResonse.m
//  ZFMRACNetwork
//
//  Created by todriver02 on 2018/7/31.
//  Copyright © 2018年 zhufaming. All rights reserved.
//

#import "FMHttpResonse.h"

@interface FMHttpResonse()

@property (nonatomic, assign, readwrite) Boolean isSuccess;
@property (nonatomic, assign, readwrite) NSInteger code;
@property (nonatomic, copy, readwrite) NSString *message;
@property (nonatomic, strong, readwrite) id reqResult;
@property (nonatomic, strong, readwrite) NSError *reqError;
@property (nonatomic, assign, readwrite) NSInteger pageNo;
@property (nonatomic, assign, readwrite) NSInteger pageSize;
@property (nonatomic, assign, readwrite) NSInteger totalCount;
@property (nonatomic, assign, readwrite) NSInteger totalPages;

@end

@implementation FMHttpResonse

/**
 请求成功的初始化
 
 @param result json
 @param dict 剩余参数
 @return FMHttpResonse
 */
- (instancetype)initWithResponseSuccess:(id)result dict:(NSDictionary *)dict responseObject:(id)response
{
    if (self = [super init]) {
        _responses = response;
        self.isSuccess = YES;
        self.reqResult = result;
        self.code = [dict[HTTPServiceResponseCodeKey] integerValue];
        self.pageSize = [dict[HTTPServiceResponsePageSize] integerValue];
        self.pageNo = [dict[HTTPServiceResponsePageNo] integerValue];
        self.totalCount = [dict[HTTPServiceResponseTotalCount] integerValue];
        self.totalPages = [dict[HTTPServiceResponseTotalPages] integerValue];
        self.message = response[HTTPServiceResponseMsgKey];
    }
    return self;
}

/**
 请求错误的初始化
 
 @param error 错误信息
 @param code 码
 @param message 信息
 @return FMHttpResonse
 */
- (instancetype)initWithResponseError:(NSError *)error code:(NSInteger)code msg:(NSString *)message
{
    if (self = [super init]) {
        self.isSuccess = NO;
        self.reqError = error;
        self.code = code;
        self.message = message;
    }
    return self;
}

- (kXQCHttpStatusCode)httpStatusCodes
{
    return (kXQCHttpStatusCode)self.code;
} 

- (NSString *)responseMessage
{
    if (self.message.length) {
        return self.message;
    }
    return self.responses[@"msg"];
}

- (void)showResponseMessages
{
    if (self.responseMessage) {
        HSYCOCOAKIT_IGNORED_SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([MBProgressHUD performSelector:NSSelectorFromString(@{@(YES) : @"showSuccessProgress:", @(NO) : @"showFailureProgress:"}[@(self.code == 0)]) withObject:self.responseMessage]);
    }
}

@end
