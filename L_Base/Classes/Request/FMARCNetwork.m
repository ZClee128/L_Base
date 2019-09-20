//
//  FMARCNetwork.m
//  ZFMRACNetwork
//
//  Created by todriver02 on 2018/7/31.
//  Copyright © 2018年 zhufaming. All rights reserved.
//

#import "FMARCNetwork.h"
#import "FMHttpRequest.h"
#import "FMHttpResonse.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "JDStatusBarNotification.h"
#import "MBProgressHUD.h"
#import "XQCUserManager.h"
#import "XQCH5Manager.h"

NSInteger const kXQCHttpReponseSucessCode                       = 0;
NSInteger const kXQCUnionpayPayPasswordLockedStatusCode         = 77;

/// 请求数据返回的状态码、根据自己的服务端数据来
typedef NS_ENUM(NSUInteger, HTTPResponseCode) { 
    HTTPResponseCodeSuccess = kXQCHttpReponseSucessCode,            /// 请求成功
//    HTTPResponseCodeNotLogin = 1009,                              /// 用户尚未登录，一般在网络请求前判断处理，也可以在网络层处理
    HTTPResponseCodeOperationFailure = -1,                          /// 操作失败
    HTTPResponseCodeUnauthority = 401,                              /// 无权限
    HTTPResponseCoderRequestDoesnotSupportGet = 1001,               /// 请求不支付GET
    HTTPResponseCodeRequestDoesnotSupportGet = 1002,                /// 请求不支付POST
    HTTPResponseCodeUserNameCannotBeEmpty = 1003,                   /// 用户名不能为空
    HTTPResponseCodePasswordCannotBeEmpty = 1004,                   /// 密码不能为空
    HTTPResponseCodepasswordWrong = 1005,                           /// 密码有误
    HTTPResponseCodeVerificationCodeCannotBeEmpty = 1006,           /// 验证码不能为空
    HTTPResponseCodeVerificationCodeError = 1007,                   /// 验证码有误
    HTTPResponseCodeUserDoesNotExist = 1008,                        /// 用户不存在
    HTTPResponseCodeUserAlreadyExists = 1009,                       /// 用户已存在
    HTTPResponseCodeTokenFetchFailed = 1010,                        /// 获取token失败
    HTTPResponseCodeInterfaceRequestException = 9999,               /// 接口请求异常
    HTTPResponseCodeWranToken = 1011,                               /// 错误的token

};

/// The Http request error domain
NSString *const HTTPServiceErrorDomain = @"HTTPServiceErrorDomain";
/// 请求成功，但statusCode != 0
NSString *const HTTPServiceErrorResponseCodeKey = @"HTTPServiceErrorResponseCodeKey";

//请求地址错误
NSString * const HTTPServiceErrorRequestURLKey = @"HTTPServiceErrorRequestURLKey";
//请求错误的code码key: 请求成功了，但code码是错误提示的code,比如参数错误
NSString * const HTTPServiceErrorHTTPStatusCodeKey = @"HTTPServiceErrorHTTPStatusCodeKey";
//请求错误，详细描述key
NSString * const HTTPServiceErrorDescriptionKey = @"HTTPServiceErrorDescriptionKey";
//服务端错误提示，信息key
NSString * const HTTPServiceErrorMessagesKey = @"HTTPServiceErrorMessagesKey";

@interface FMARCNetwork()
//网络管理工具
@property (nonatomic,strong) AFHTTPSessionManager * manager;

@end

@interface FMARCNetwork()
{
    NSURL *xqcBaseURL;
}
@end

@implementation FMARCNetwork

static FMARCNetwork * _instance = nil;

#pragma mark -  HTTPService
+(instancetype) sharedInstance {
    if (_instance == nil) {
        _instance = [[super alloc] init];
        //初始化 网络管理器
        _instance.manager = [AFHTTPSessionManager manager];
        [_instance configHTTPService];
        
    }
    return _instance;
}
+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        
    });
    return _instance;
}
- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

/**
 检测URL格式
 @param     url NSString、NSURL
 @return    正确的NSURL或者nil
 */
+ (NSURL *)testURL:(id)url
{
    NSURL *normalURL = nil;
    
    if (url) {
        if ([url isKindOfClass:[NSURL class]]) {
            normalURL = url;
        } else if ([url isKindOfClass:[NSString class]]) {
            normalURL = [NSURL URLWithString:(NSString *)url];
        }
    }
    
    return normalURL;
}

- (void)setupBaseURL:(NSURL *)url
{
    xqcBaseURL = url;
    xqcBaseURL = [xqcBaseURL URLByAppendingPathComponent:@""];
}

/// config service
- (void)configHTTPService{
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.removesKeysWithNullValues = YES;
    responseSerializer.readingOptions = NSJSONReadingAllowFragments;
    /// config
    self.manager.responseSerializer = responseSerializer;
//    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    /// 安全策略
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO
    //主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    securityPolicy.validatesDomainName = NO;
    
    self.manager.securityPolicy = securityPolicy;
    /// 支持解析
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                      @"text/json",
                                                      @"text/javascript",
                                                      @"text/html",
                                                      @"text/plain",
                                                      @"text/html; charset=UTF-8",
                                                      nil];

    [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [self.manager.requestSerializer setValue:@"MOBILE" forHTTPHeaderField:@"channel"];
    XQCLappReqHeadModel *reqHead = [XQCLappReqHeadModel getRequestHead];
    [self.manager.requestSerializer setValue:[reqHead modelToJSONString] forHTTPHeaderField:@"reqHead"];

    /// 开启网络监测
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [self.manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusUnknown) {
            XYLog(@"--- 未知网络 ---");
            [JDStatusBarNotification showWithStatus:@"网络状态未知" styleName:JDStatusBarStyleWarning];
            [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
        }else if (status == AFNetworkReachabilityStatusNotReachable) {
  
            [JDStatusBarNotification showWithStatus:@"网络不给力，请检查网络" styleName:JDStatusBarStyleWarning];
            [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
            
        }else{
            XYLog(@"--- 有网络 ---");
             [JDStatusBarNotification dismiss];
        }
    }];
    [self.manager.reachabilityManager startMonitoring];
}

- (RACSignal *)requestSimpleNetworkPath:(NSString *)path params:(NSDictionary *)params
{
    FMHttpRequest *req = [FMHttpRequest urlParametersWithMethod:HTTP_METHOD_POST path:path parameters:params];
    return [self requestNetworkData:req];
}


- (RACSignal *)requestNetworkData:(FMHttpRequest *)req{
     /// request 必须的有值
    if (!req) return [RACSignal error:[NSError errorWithDomain:HTTPServiceErrorDomain code:-1 userInfo:nil]];
    
    NSString *accessToken = UserManager.accountModel.accessToken;
    NSString *tokenType = UserManager.accountModel.tokenType;
    if (accessToken && accessToken.length > 0 && tokenType && tokenType.length > 0) {
        
        if (![req.path isEqualToString:apiGetH5Version]) {
            
            [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@",tokenType,accessToken] forHTTPHeaderField:@"Authorization"];

        }
    }else {
        [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    
    @weakify(self);
    /// 创建信号
    RACSignal *signal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self);
        /// 获取request
        
        NSError *serializationError = nil;
        XYLog(@"[[NSURL URLWithString:req.path relativeToURL:self->xqcBaseURL] absoluteString]%@",[[NSURL URLWithString:req.path relativeToURL:self->xqcBaseURL] absoluteString]);
        NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:req.method URLString:[[NSURL URLWithString:req.path relativeToURL:self->xqcBaseURL] absoluteString] parameters:req.parameters error:&serializationError];
        
        if (serializationError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.manager.completionQueue ?: dispatch_get_main_queue(), ^{
                [subscriber sendError:serializationError];
            });
#pragma clang diagnostic pop
            return [RACDisposable disposableWithBlock:^{
            }];
        }
        /// 获取请求任务
        __block NSURLSessionDataTask *task = nil;
        task = [self.manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
             @strongify(self);
            NSInteger httpCode = [(NSHTTPURLResponse *)response statusCode];
            if (error) {
                NSError *parseError = [self errorFromRequestWithTask:task httpResponse:(NSHTTPURLResponse *)response responseObject:responseObject error:error];
    
                NSInteger code = [parseError.userInfo[HTTPServiceErrorHTTPStatusCodeKey] integerValue];
                NSString *msgStr = parseError.userInfo[HTTPServiceErrorDescriptionKey];
                //初始化、返回数据模型
                FMHttpResonse *response = [[FMHttpResonse alloc] initWithResponseError:parseError code:code msg:msgStr];
                //同样也返回到,调用的地址，也可处理，自己选择
                [subscriber sendNext:response];
                [subscriber sendCompleted];
                //错误可以在此处处理---比如加入自己弹窗，主要是服务器错误、和请求超时、网络开小差
                if (req.performShowErrorMessage) {
                    if ([req.parameters[kXQCNetworkPerformHiddenSomeErrorMessageCodeForKey] integerValue] != code) {
                        [self showMsgtext:msgStr];
                    }
                }
                
                if (httpCode == kXQCHttpStatusCode_401) {
                    [self loginPastDue];
                }
                
            } else {
              
                /// 判断
                NSInteger statusCode = [responseObject[HTTPServiceResponseCodeKey] integerValue];
                NSInteger pageNo = [responseObject[HTTPServiceResponsePageNo] integerValue];
                NSInteger pageSize = [responseObject[HTTPServiceResponsePageSize] integerValue];
                NSInteger totalPages = [responseObject[HTTPServiceResponseTotalPages] integerValue];
                NSInteger totalCount = [responseObject[HTTPServiceResponseTotalCount] integerValue];

                NSDictionary *dict = @{
                                       HTTPServiceResponseCodeKey : @(statusCode),
                                       HTTPServiceResponsePageNo : @(pageNo),
                                       HTTPServiceResponsePageSize : @(pageSize),
                                       HTTPServiceResponseTotalPages : @(totalPages),
                                       HTTPServiceResponseTotalCount : @(totalCount)
                                       };
                if (statusCode == HTTPResponseCodeSuccess) {
                    FMHttpResonse *response = [[FMHttpResonse alloc] initWithResponseSuccess:responseObject[HTTPServiceResponseDataKey] dict:dict responseObject:responseObject];
                   
                    [subscriber sendNext:response];
                    [subscriber sendCompleted];
                    
                } else {
                    NSArray *tokenErrors = @[@(HTTPResponseCodeTokenFetchFailed), @(HTTPResponseCodeWranToken), @(HTTPResponseCodeUnauthority), ];
                    if ([tokenErrors containsObject:@(statusCode)]) {
                        [self loginPastDue];
                    }
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    userInfo[HTTPServiceErrorResponseCodeKey] = @(statusCode);
                    //取出服务给的提示
                    NSString *msgTips = responseObject[HTTPServiceResponseMsgKey];
                    //服务器没有返回，错误信息
                    if ((msgTips.length == 0 || msgTips == nil || [msgTips isKindOfClass:[NSNull class]])) {
                        msgTips = @"服务器出错了，请稍后重试~";
                    }
                    
                    userInfo[HTTPServiceErrorMessagesKey] = msgTips;
                    if (task.currentRequest.URL != nil) userInfo[HTTPServiceErrorRequestURLKey] = task.currentRequest.URL.absoluteString;
                    if (task.error != nil) userInfo[NSUnderlyingErrorKey] = task.error;
                    NSError *requestError = [NSError errorWithDomain:HTTPServiceErrorDomain code:statusCode userInfo:userInfo];
                    //错误信息反馈回去了、可以在此做响应的弹窗处理，展示出服务器给我们的信息
                    FMHttpResonse *response = [[FMHttpResonse alloc] initWithResponseError:requestError code:statusCode msg:msgTips];
                    
                    [subscriber sendNext:response];
                    [subscriber sendCompleted];
                    //错误处理
                    if (req.performShowErrorMessage) {
                        if ([req.parameters[kXQCNetworkPerformHiddenSomeErrorMessageCodeForKey] integerValue] != statusCode) {
                            [self showMsgtext:msgTips];
                        }
                    }
                }
            }
        }];
        
        /// 开启请求任务
        [task resume];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
    return [signal replayLazily]; //多次订阅同样的信号，执行一次
}


- (RACSignal *)uploadNetworkPath:(NSString *)path params:(NSDictionary *)params fileDatas:(NSArray<NSData *> *)fileDatas name:(NSString *)name mimeType:(NSString *)mimeType
{
    return [[self UploadRequestWithPath:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSInteger count = fileDatas.count;
        for (int i = 0; i< count; i++) {
            /// 取出fileData
            NSData *fileData = fileDatas[i];
            
            /// 断言
            NSAssert([fileData isKindOfClass:NSData.class], @"fileData is not an NSData class: %@", fileData);
            
            // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
            // 要解决此问题，
            // 可以在上传时使用当前的系统事件作为文件名
            
            static NSDateFormatter *formatter = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formatter = [[NSDateFormatter alloc] init];
            });
            // 设置时间格式
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString  stringWithFormat:@"senba_empty_%@_%d.jpg", dateString , i];
            
            [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:!(mimeType.length == 0 || mimeType == nil || [mimeType isKindOfClass:[NSNull class]])?mimeType:@"application/octet-stream"];
            
        }
    }] replayLazily];
    
    
}

- (RACSignal *)UploadRequestWithPath:(NSString *)path parameters:(id)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block{
    @weakify(self);
    NSDictionary *realParamters = (NSDictionary *)[FMHttpRequest realRequestParamters:parameters].first;
    NSString *accessToken = UserManager.accountModel.accessToken;
    NSString *tokenType = UserManager.accountModel.tokenType;
    if (accessToken && accessToken.length > 0 && tokenType && tokenType.length > 0) {
        
        [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@",tokenType,accessToken] forHTTPHeaderField:@"Authorization"];
    }else {
        [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    /// 创建信号
    RACSignal *signal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self);
        /// 获取request
        NSError *serializationError = nil;
        
        NSMutableURLRequest *request = [self.manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:self->xqcBaseURL] absoluteString] parameters:realParamters constructingBodyWithBlock:block error:&serializationError];
        if (serializationError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.manager.completionQueue ?: dispatch_get_main_queue(), ^{
                [subscriber sendError:serializationError];
            });
#pragma clang diagnostic pop
            
            return [RACDisposable disposableWithBlock:^{
            }];
        }
        
        __block NSURLSessionDataTask *task = [self.manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
            @strongify(self);
            NSInteger httpCode = [(NSHTTPURLResponse *)response statusCode];
            if (error) {
                NSError *parseError = [self errorFromRequestWithTask:task httpResponse:(NSHTTPURLResponse *)response responseObject:responseObject error:error];
                
                NSInteger code = [parseError.userInfo[HTTPServiceErrorHTTPStatusCodeKey] integerValue];
                
                NSString *msgStr = parseError.userInfo[HTTPServiceErrorDescriptionKey];
                //初始化、返回数据模型
                FMHttpResonse *response = [[FMHttpResonse alloc] initWithResponseError:parseError code:code msg:msgStr];
                //错误可以在此处处理---比如加入自己弹窗，主要是服务器错误、和请求超时、网络开小差
                //同样也返回到,调用的地址，也可处理，自己选择
                [subscriber sendNext:response];
                //[subscriber sendError:parseError];
                [subscriber sendCompleted];
                if ([[FMHttpRequest realRequestParamters:parameters].second isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dictionarySource = [FMHttpRequest realRequestParamters:parameters].second;
                    if (dictionarySource[kXQCNetworkPerformShowErrorMessageForKey] && [dictionarySource[kXQCNetworkPerformShowErrorMessageForKey] boolValue]) {
                        if ([parameters[kXQCNetworkPerformHiddenSomeErrorMessageCodeForKey] integerValue] != code) {
                            [self showMsgtext:msgStr];
                        }
                    }
                }
                if (httpCode == kXQCHttpStatusCode_401) {
                    [self loginPastDue];
                }
                
            } else {
                
                /// 判断
                NSInteger statusCode = [responseObject[HTTPServiceResponseCodeKey] integerValue];
                NSDictionary *dict = @{
                                       HTTPServiceErrorHTTPStatusCodeKey : @(statusCode)
                                       };
                if (statusCode == HTTPResponseCodeSuccess) {
                    FMHttpResonse *response = [[FMHttpResonse alloc] initWithResponseSuccess:responseObject[HTTPServiceResponseDataKey] dict:dict responseObject:responseObject];
                    
                    [subscriber sendNext:response];
                    [subscriber sendCompleted];
                    
                }else{
                    NSArray *tokenErrors = @[@(HTTPResponseCodeTokenFetchFailed), @(HTTPResponseCodeWranToken), @(HTTPResponseCodeUnauthority), ];
                    if ([tokenErrors containsObject:@(statusCode)]) {
                        [self loginPastDue];
                    } else{
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        userInfo[HTTPServiceErrorResponseCodeKey] = @(statusCode);
                        //取出服务给的提示
                        NSString *msgTips = responseObject[HTTPServiceResponseMsgKey];
                        //服务器没有返回，错误信息
                        if ((msgTips.length == 0 || msgTips == nil || [msgTips isKindOfClass:[NSNull class]])) {
                            msgTips = @"服务器出错了，请稍后重试~";
                        }
                        
                        userInfo[HTTPServiceErrorMessagesKey] = msgTips;
                        if (task.currentRequest.URL != nil) userInfo[HTTPServiceErrorRequestURLKey] = task.currentRequest.URL.absoluteString;
                        if (task.error != nil) userInfo[NSUnderlyingErrorKey] = task.error;
                        NSError *requestError = [NSError errorWithDomain:HTTPServiceErrorDomain code:statusCode userInfo:userInfo];
                        //错误信息反馈回去了、可以在此做响应的弹窗处理，展示出服务器给我们的信息
                        FMHttpResonse *response = [[FMHttpResonse alloc] initWithResponseError:requestError code:statusCode msg:msgTips];
                        [subscriber sendNext:response];
                        [subscriber sendCompleted];
                        if ([[FMHttpRequest realRequestParamters:parameters].second isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *dictionarySource = [FMHttpRequest realRequestParamters:parameters].second;
                            if (dictionarySource[kXQCNetworkPerformShowErrorMessageForKey] && [dictionarySource[kXQCNetworkPerformShowErrorMessageForKey] boolValue]) {
                                [self showMsgtext:msgTips];
                            }
                        }
                    }
                }
            
            }
        }];
        
        [task resume];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
        
    }];
    /// replayLazily:replayLazily会在第一次订阅的时候才订阅sourceSignal
    /// 会提供所有的值给订阅者 replayLazily还是冷信号 避免了冷信号的副作用
    return [[signal
             replayLazily]
            setNameWithFormat:@"-enqueueUploadRequestWithPath: %@ parameters: %@", path, parameters];
}



/// 请求错误解析
- (NSError *)errorFromRequestWithTask:(NSURLSessionTask *)task httpResponse:(NSHTTPURLResponse *)httpResponse responseObject:(NSDictionary *)responseObject error:(NSError *)error
{
    /// 不一定有值，则HttpCode = 0;
    NSInteger HTTPCode = httpResponse.statusCode;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSString *errorDesc = (!self.manager.reachabilityManager.isReachable ? @"网络开小差了，请稍后重试~" : self.class.httpStatusCodeParamters[@((kXQCHttpStatusCode)HTTPCode)]);
    if (!errorDesc.length) {
        errorDesc = @"服务器出错了，请稍后重试~";
    }
    userInfo[HTTPServiceErrorHTTPStatusCodeKey] = @(HTTPCode);
    userInfo[HTTPServiceErrorDescriptionKey] = errorDesc;
    if (task.currentRequest.URL != nil) userInfo[HTTPServiceErrorRequestURLKey] = task.currentRequest.URL.absoluteString;
    if (task.error != nil) userInfo[NSUnderlyingErrorKey] = task.error;
    
    return [NSError errorWithDomain:HTTPServiceErrorDomain code:HTTPCode userInfo:userInfo];
    
}

#pragma 错误提示
- (void)showMsgtext:(NSString *)text
{
    [MBProgressHUD showAlertProgress:text];
}

- (void)loginPastDue
{
    [UserManager deleteAccount];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyDidLoginSuccess object:nil userInfo:@{@"isLogin": @(NO)}];
    [AppDelegate resetFirstTabBarItem];
}


+ (NSDictionary *)httpStatusCodeParamters
{
    NSString *errorDesc = @"服务器出错了，请稍后重试~";
    NSDictionary *httpCodes = @{@(kXQCHttpStatusCode_200) : @"请求成功!",
                                @(kXQCHttpStatusCode_400) : errorDesc,
                                @(kXQCHttpStatusCode_401) : @"登陆过期，请重新登陆您的账号！",
                                @(kXQCHttpStatusCode_403) : errorDesc,
                                @(kXQCHttpStatusCode_404) : errorDesc,
                                @(kXQCHttpStatusCode_405) : errorDesc,
                                @(kXQCHttpStatusCode_406) : errorDesc,
                                @(kXQCHttpStatusCode_407) : @"登陆过期，请重新登陆您的账号！",
                                @(kXQCHttpStatusCode_408) : @"请求超时，请稍后再试~",
                                @(kXQCHttpStatusCode_409) : errorDesc,
                                @(kXQCHttpStatusCode_410) : errorDesc,
                                @(kXQCHttpStatusCode_411) : errorDesc,
                                @(kXQCHttpStatusCode_412) : errorDesc,
                                @(kXQCHttpStatusCode_413) : errorDesc,
                                @(kXQCHttpStatusCode_414) : errorDesc,
                                @(kXQCHttpStatusCode_415) : errorDesc,
                                @(kXQCHttpStatusCode_416) : errorDesc,
                                @(kXQCHttpStatusCode_417) : errorDesc,
                                @(kXQCHttpStatusCode_500) : @"服务器内部错误！请稍后再试！",
                                @(kXQCHttpStatusCode_501) : errorDesc,
                                @(kXQCHttpStatusCode_502) : @"服务器网关错误！",
                                @(kXQCHttpStatusCode_503) : @"服务器维护中，请稍后再试！",
                                @(kXQCHttpStatusCode_504) : errorDesc,
                                @(kXQCHttpStatusCode_505) : errorDesc, };
    return httpCodes;
}

@end
























