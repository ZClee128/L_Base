//
//  NSError+XQCHTTPClient.h
//  XQC
//
//  Created by huangwenwu on 2019/4/15.
//
//

#import <Foundation/Foundation.h>

@interface NSError(XQCHTTPClient)

+ (NSError*)xqc_cannotAnalysisDataError;

+ (NSError*)xqc_cannotConnectServiceError;

+ (NSError*)xqc_cannotConnectNetworkError;

+ (NSError*)xqc_errorWithCode:(NSInteger)code msg:(NSString *)msg;

+ (NSError*)xqc_errorWithNetworkErrorInfo:(NSString*)errorInfo;

+ (NSError*)xqc_errorWithCode:(NSInteger)code;

- (BOOL)xqc_isHTTPNetworkError;
- (BOOL)xqc_isHTTPResponeError;

@end
