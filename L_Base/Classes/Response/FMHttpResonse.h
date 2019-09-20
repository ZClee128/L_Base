//
//  FMHttpResonse.h
//  ZFMRACNetwork
//
//  Created by todriver02 on 2018/7/31.
//  Copyright © 2018年 zhufaming. All rights reserved.
//

/**
 *  请求回调、模型
 */

#import <Foundation/Foundation.h>
#import "FMARCNetwork.h"

typedef NS_ENUM(NSUInteger, kXQCHttpStatusCode) {
    
    kXQCHttpStatusCode_200  = 200,              //服务器已成功处理了请求 -> 成功
    
    kXQCHttpStatusCode_400  = 400,              //服务器不理解请求的语法
    kXQCHttpStatusCode_401  = 401,              //请求要求身份验证 -> 对于需要登录的网页，服务器可能返回此响应 -> 签权
    kXQCHttpStatusCode_403  = 403,              //服务器拒绝请求
    kXQCHttpStatusCode_404  = 404,              //服务器找不到请求的网页
    kXQCHttpStatusCode_405  = 405,              //禁用请求中指定的方法 -> 检查请求方式格式是否正确[get、post、delete...]
    kXQCHttpStatusCode_406  = 406,              //无法使用请求的内容特性响应请求的网页
    kXQCHttpStatusCode_407  = 407,              //此状态代码与 401（未授权）类似，但指定请求者应当授权使用代理
    kXQCHttpStatusCode_408  = 408,              //服务器等候请求时发生超时
    kXQCHttpStatusCode_409  = 409,              //服务器在完成请求时发生冲突。 服务器必须在响应中包含有关冲突的信息
    kXQCHttpStatusCode_410  = 410,              //如果请求的资源已永久删除，服务器就会返回此响应
    kXQCHttpStatusCode_411  = 411,              //服务器不接受不含有效内容长度标头字段的请求
    kXQCHttpStatusCode_412  = 412,              //服务器未满足请求者在请求中设置的其中一个前提条件
    kXQCHttpStatusCode_413  = 413,              //服务器无法处理请求，因为请求实体过大，超出服务器的处理能力
    kXQCHttpStatusCode_414  = 414,              //（请求的 URI 过长） 请求的 URI（通常为网址）过长，服务器无法处理
    kXQCHttpStatusCode_415  = 415,              //不支持的媒体类型 -> 请求的格式不受请求页面的支持
    kXQCHttpStatusCode_416  = 416,              //如果页面无法提供请求的范围，则服务器会返回此状态代码
    kXQCHttpStatusCode_417  = 417,              //服务器未满足”期望”请求标头字段的要求
    
    kXQCHttpStatusCode_500  = 500,              //服务器遇到错误，无法完成请求
    kXQCHttpStatusCode_501  = 501,              //服务器不具备完成请求的功能。 例如，服务器无法识别请求方法时可能会返回此代码
    kXQCHttpStatusCode_502  = 502,              //服务器作为网关或代理，从上游服务器收到无效响应 -> 网关错误
    kXQCHttpStatusCode_503  = 503,              //服务器目前无法使用（由于超载或停机维护）-> 通常，这只是暂时状态
    kXQCHttpStatusCode_504  = 504,              //服务器作为网关或代理，但是没有及时从上游服务器收到请求
    kXQCHttpStatusCode_505  = 505,              //服务器不支持请求中所用的 HTTP 协议版本
    
};

@interface FMHttpResonse : NSObject

/**
 请求是否成功
 */
@property (nonatomic, assign, readonly) Boolean isSuccess;

/**
 code 码  成功错误、统一返回 reqError：也存在信息同样的信息，方便快速取
 */
@property (nonatomic, assign, readonly) NSInteger code;

/**
 反馈信息  错误的时候调用   reqError：也存在信息同样的信息，方便快速取
 */
@property (nonatomic, copy, readonly) NSString *message;

/**
 请求结果、用户需要的数据
 */
@property (nonatomic, strong, readonly) id reqResult;

/**
 请求的原始的reponse
 */
@property (nonatomic, strong, readonly) id responses;

/**
 请求错误、自定义处理 ，需要自取
 详细信息：在 userInfo 里面
 初始化：
 NSError *requestError = [NSError errorWithDomain:HTTPServiceErrorDomain code:statusCode userInfo:userInfo];
 
 userInfo:错误信息集
 key:   HTTPServiceErrorResponseCodeKey  code  错误的 code码
 key:   HTTPServiceErrorMessagesKey   message  错误的信息描述
 key:   HTTPServiceErrorRequestURLKey  vlaue: task.currentRequest.URL.absoluteString url 错误
 key:   NSUnderlyingErrorKey    value : task.error  服务端返回的错误信息
 */
@property (nonatomic, strong, readonly) NSError *reqError;


/**
 请求成功的初始化

 @param result json
 @param dict 剩余参数
 @return FMHttpResonse
 */
- (instancetype)initWithResponseSuccess:(id)result dict:(NSDictionary *)dict responseObject:(id)response;

/**
 请求错误的初始化

 @param error 错误信息
 @param code 码
 @param message 信息
 @return FMHttpResonse
 */
- (instancetype)initWithResponseError:(NSError *)error code:(NSInteger)code msg:(NSString *)message;

/**
 http常见请求状态码枚举

 @return kXQCHttpStatusCode
 */
- (kXQCHttpStatusCode)httpStatusCodes;

/**
 当解析reqResult可以得到时就返回message，否则返回responses的message

 @return message
 */
- (NSString *)responseMessage;

/**
 根据结果执行self.responseMessage的HUD提示
 */
- (void)showResponseMessages;

@end
