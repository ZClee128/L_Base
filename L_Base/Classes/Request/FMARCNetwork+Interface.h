//
//  FMARCNetwork+Interface.h
//  XQC
//
//  Created by anmin on 2019/4/15.
//  Copyright © 2019 xqc. All rights reserved.
//

#import "FMARCNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMARCNetwork (Interface)

//预留两个接口层方法，上层调用时使用，预留加密或者头部信息操作等
- (RACSignal *)xqc_request:(FMHttpRequest *)request;
- (RACSignal *)xqc_requestSimpleNetwork:(NSString *)path paramters:(nullable NSDictionary *)paramters;

//GET-POST-PUT
- (RACSignal *)xqc_getRequest:(NSString *)path paramters:(nullable NSDictionary *)paramters;
- (RACSignal *)xqc_postRequest:(NSString *)path paramters:(nullable NSDictionary *)paramters;
- (RACSignal *)xqc_putRequest:(NSString *)path paramters:(nullable NSDictionary *)paramters;

@end

NS_ASSUME_NONNULL_END
