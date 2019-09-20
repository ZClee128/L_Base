//
//  FMARCNetwork+Interface.m
//  XQC
//
//  Created by anmin on 2019/4/15.
//  Copyright © 2019 xqc. All rights reserved.
//

#import "FMARCNetwork+Interface.h"
#import "FMHttpRequest.h"
@implementation FMARCNetwork (Interface)

- (RACSignal *)xqc_request:(FMHttpRequest *)request
{
    return [self requestNetworkData:request];
}

- (RACSignal *)xqc_requestSimpleNetwork:(NSString *)path paramters:(nullable NSDictionary *)paramters
{
    return [self requestSimpleNetworkPath:path params:paramters];
}

- (RACSignal *)xqc_getRequest:(NSString *)path paramters:(nullable NSDictionary *)paramters
{
    FMHttpRequest *request = [FMHttpRequest urlParametersWithMethod:HTTP_METHOD_GET path:path parameters:paramters];
    return [self xqc_request:request];
}

- (RACSignal *)xqc_postRequest:(NSString *)path paramters:(nullable NSDictionary *)paramters
{
    FMHttpRequest *request = [FMHttpRequest urlParametersWithMethod:HTTP_METHOD_POST path:path parameters:paramters];
    return [self xqc_request:request];
}

- (RACSignal *)xqc_putRequest:(NSString *)path paramters:(nullable NSDictionary *)paramters
{
    FMHttpRequest *request = [FMHttpRequest urlParametersWithMethod:HTTP_METHOD_PUT path:path parameters:paramters];
    return [self xqc_request:request];
} 

@end
