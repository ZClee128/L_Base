//
//  NSError+XQCHTTPClient.m
//  XQC
//
//  Created by huangwenwu on 2019/4/15.
//
//

#import "NSError+XQCHTTPClient.h"
#import "XQCHTTPTool.h"

@implementation NSError(XQCHTTPClient)

+ (NSError*)xqc_cannotAnalysisDataError {
    return [NSError xqc_errorWithErrorInfo:@"【服务器数据异常】"];
}

+ (NSError*)xqc_cannotConnectServiceError {
    return [NSError xqc_errorWithErrorInfo:@"【无法连接到服务器，请稍后再试】"];
}

+ (NSError*)xqc_cannotConnectNetworkError {
    return [[NSError alloc] initWithDomain:@""
                                      code:XQCHTTPNetworkNotReachable
                                  userInfo:@{
                                             NSLocalizedDescriptionKey : @"【网络不给力，请检查您的网络设置】"
                                             }];
}

+ (NSError*)xqc_errorWithNetworkErrorInfo:(NSString*)errorInfo {
    return [NSError xqc_errorWithErrorInfo:errorInfo];
}

+(NSError*)xqc_errorWithCode:(NSInteger)code msg:(NSString *)msg {
    return [[NSError alloc] initWithDomain:(NSString*)XQCHTTPNetWorkErrorDomain
                                      code:code
                                  userInfo:@{
                                             NSLocalizedDescriptionKey:msg?msg:@""
                                             }];
}

+ (NSError*)xqc_errorWithErrorInfo:(NSString*)errorInfo {
    return [[NSError alloc] initWithDomain:(NSString*)XQCHTTPNetWorkErrorDomain
                                      code:XQCHTTPNetworkErrorCode
                                  userInfo:@{
                                             NSLocalizedDescriptionKey:errorInfo?errorInfo:@""
                                             }];
}

+ (NSError *)xqc_errorWithCode:(NSInteger)code {
    NSString *errorMesg = nil;
    switch (code) {
        case NSURLErrorUnknown://-1
            errorMesg = @"【无效的URL地址】";
            break;
        case NSURLErrorCancelled://-999
            errorMesg = @"【无效的URL地址】";
            break;
        case NSURLErrorBadURL://-1000
            errorMesg = @"【无效的URL地址】";
            break;
        case NSURLErrorTimedOut://-1001
            errorMesg = @"【网络不给力，请稍后再试】";
            break;
        case NSURLErrorUnsupportedURL://-1002
            errorMesg = @"【不支持的URL地址】";
            break;
        case NSURLErrorCannotFindHost://-1003
            errorMesg = @"【找不到服务器】";
            break;
        case NSURLErrorCannotConnectToHost://-1004
            errorMesg = @"【连接不上服务器】";
            break;
        case NSURLErrorDataLengthExceedsMaximum://-1103
            errorMesg = @"【请求数据长度超出最大限度】";
            break;
        case NSURLErrorNetworkConnectionLost://-1005
            errorMesg = @"【网络连接异常】";
            break;
        case NSURLErrorDNSLookupFailed://-1006
            errorMesg = @"【DNS查询失败】";
            break;
        case NSURLErrorHTTPTooManyRedirects://-1007
            errorMesg = @"【HTTP请求重定向】";
            break;
        case NSURLErrorResourceUnavailable://-1008
            errorMesg = @"【资源不可用】";
            break;
        case NSURLErrorNotConnectedToInternet://-1009
            errorMesg = @"【网络不给力，请检查您的网络设置】";
            break;
        case NSURLErrorRedirectToNonExistentLocation://-1010
            errorMesg = @"【重定向到不存在的位置】";
            break;
        case NSURLErrorBadServerResponse://-1011
            errorMesg = @"【服务器响应异常】";
            break;
        case NSURLErrorUserCancelledAuthentication://-1012
            errorMesg = @"【用户取消授权】";
            break;
        case NSURLErrorUserAuthenticationRequired://-1013
            errorMesg = @"【需要用户授权】";
            break;
        case NSURLErrorZeroByteResource://-1014
            errorMesg = @"【零字节资源】";
            break;
        case NSURLErrorCannotDecodeRawData://-1015
            errorMesg = @"【无法解码原始数据】";
            break;
        case NSURLErrorCannotDecodeContentData://-1016
            errorMesg = @"【无法解码内容数据】";
            break;
        case NSURLErrorCannotParseResponse://-1017
            errorMesg = @"【无法解析响应】";
            break;
        case NSURLErrorInternationalRoamingOff://-1018
            errorMesg = @"【国际漫游关闭】";
            break;
        case NSURLErrorCallIsActive://-1019
            errorMesg = @"【被叫激活】";
            break;
        case NSURLErrorDataNotAllowed://-1020
            errorMesg = @"【数据不被允许】";
            break;
        case NSURLErrorRequestBodyStreamExhausted://-1021
            errorMesg = @"【请求体】";
            break;
        case NSURLErrorFileDoesNotExist://-1100
            errorMesg = @"【文件不存在】";
            break;
        case NSURLErrorFileIsDirectory://-1101
            errorMesg = @"【文件是个目录】";
            break;
        case NSURLErrorNoPermissionsToReadFile://-1102
            errorMesg = @"【无读取文件权限】";
            break;
        case NSURLErrorSecureConnectionFailed://-1200
            errorMesg = @"【安全连接失败】";
            break;
        case NSURLErrorServerCertificateHasBadDate://-1201
            errorMesg = @"【服务器证书失效】";
            break;
        case NSURLErrorServerCertificateUntrusted://-1202
            errorMesg = @"【不被信任的服务器证书】";
            break;
        case NSURLErrorServerCertificateHasUnknownRoot://-1203
            errorMesg = @"【未知Root的服务器证书】";
            break;
        case NSURLErrorServerCertificateNotYetValid://-1204
            errorMesg = @"【服务器证书未生效】";
            break;
        case NSURLErrorClientCertificateRejected://-1205
            errorMesg = @"【客户端证书被拒】";
            break;
        case NSURLErrorClientCertificateRequired://-1206
            errorMesg = @"【需要客户端证书】";
            break;
        case NSURLErrorCannotLoadFromNetwork://-2000
            errorMesg = @"【无法从网络获取】";
            break;
        case NSURLErrorCannotCreateFile://-3000
            errorMesg = @"【无法创建文件】";
            break;
        case NSURLErrorCannotOpenFile://-3001
            errorMesg = @"【无法打开文件】";
            break;
        case NSURLErrorCannotCloseFile://-3002
            errorMesg = @"【无法关闭文件】";
            break;
        case NSURLErrorCannotWriteToFile://-3003
            errorMesg = @"【无法写入文件】";
            break;
        case NSURLErrorCannotRemoveFile://-3004
            errorMesg = @"【无法删除文件】";
            break;
        case NSURLErrorCannotMoveFile://-3005
            errorMesg = @"【无法移动文件】";
            break;
        case NSURLErrorDownloadDecodingFailedMidStream://-3006
            errorMesg = @"【下载解码数据失败】";
            break;
        case NSURLErrorDownloadDecodingFailedToComplete://-3007
            errorMesg = @"【下载解码数据失败】";
            break;
        default:
            errorMesg = @"【未知请求错误】";
            break;
    }
    return [[NSError alloc] initWithDomain:(NSString*)XQCHTTPNetWorkErrorDomain
                                      code:code
                                  userInfo:@{
                                             NSLocalizedDescriptionKey:errorMesg
                                             }];
}

- (BOOL)xqc_isHTTPResponeError {
    if ([XQCHTTPResponseSerializationErrorDomain isEqualToString:self.domain]) {
        return YES;
    }
    return NO;
}

- (BOOL)xqc_isHTTPNetworkError {
    if ([XQCHTTPNetWorkErrorDomain isEqualToString:self.domain]) {
        return YES;
    }
    return NO;
}

@end
