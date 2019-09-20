//
//  XQCHTTPTool.h
//  XQC
//
//  Created by huangwenwu on 2019/4/15.
//
//

#import <Foundation/Foundation.h>
#import "FMHttpRequest.h"
#import <AFNetworking/AFNetworking.h>
// 预设超时时长:秒
const static NSInteger XQCHttpRequestTimeoutDefault     = 60;
const static NSInteger XQCHttpRequestTimeoutOneMinute   = 60;
const static NSInteger XQCHttpRequestTimeoutFiveMinut   = 5*60;

// 预设NSError的domain
const static NSString* XQCHTTPResponseSerializationErrorDomain = @"com.xqc.error.serialization.response";
const static NSString* XQCHTTPNetWorkErrorDomain               = @"com.xqc.error.serialization.network";
// 预设NSError的Code
const static NSInteger XQCHTTPResponseSerializationErrorCode = 888888;
const static NSInteger XQCHTTPNetworkErrorCode               = 444444;
const static NSInteger XQCHTTPNetworkNotReachable            = 404404;
// 相应状态码
const static NSInteger XQCHTTPResponseStatusCodeNeedToken    = 499;
const static NSInteger XQCHTTPResponseStatusCodeTokenInvalid = 498;

// 响应状态
typedef NS_ENUM(NSInteger, XQCHttpResponseStatus) {
    XQCHttpResponseStatusSuccess    = 0,    // 成功
    XQCHttpResponseStatusFailure    = 1,    // 失败
    
};

@class XCQBaseModel;
// 响应结果的回调方法块
typedef void(^XQCResponseVoidBlock)(void);
typedef void(^XQCResponseStringBlock)(NSString *info, NSError *error);
typedef void(^XQCResponseBoolBlock)(BOOL flag, NSError *error);
typedef void(^XQCResponseModelBlock)(id model, NSError *error);
typedef void(^XQCResponseArrayBlock)(NSMutableArray *models, NSError *error);
typedef void(^XQCResponseDictionaryBlock)(NSMutableDictionary *infoDict, NSError *error);


// 网络请求Block
typedef void(^XQCHTTPSessionTaskSuccessBlock)(NSURLSessionTask *task, id responseObject);
typedef void(^XQCHTTPSessionTaskFailureBlock)(NSURLSessionTask *task, NSError *error);


// 日志打印
#ifndef __OPTIMIZE__
#define XQCHTTPDefaultShowLog YES
#else
#define XQCHTTPDefaultShowLog NO
#endif

@interface XQCHTTPTool : NSObject

#pragma mark - 工具

/**
 检测URL格式

 @param     url NSString、NSURL
 @return    正确的NSURL或者nil
 */
+ (NSURL *)testURL:(id)url;


/**
 拼接URL

 @param     host 主机地址
 @param     API 接口
 @return    主机地址和接口合并成的URL
 */
+ (NSURL *)mergeHost:(NSString *)host API:(NSString *)API;

#pragma mark - HTTP SSL
+ (BOOL)extractIdentity:(SecIdentityRef *)outIdentity
               andTrust:(SecTrustRef *)outTrust
         fromPKCS12Data:(NSData *)inPKCS12Data
               password:(NSString *)password;

+ (AFSecurityPolicy *)xqcSecurityPolicyWithName:(NSString *)name;

@end
