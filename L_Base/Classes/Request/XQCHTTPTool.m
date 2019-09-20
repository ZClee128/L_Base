//
//  XQCHTTPTool.m
//  XQC
//
//  Created by huangwenwu on 2019/4/15.
//
//

#import "XQCHTTPTool.h"

@implementation XQCHTTPTool

#pragma mark - 工具

#pragma mark - URL检测
+ (NSURL *)testURL:(id)url {
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

+ (NSURL *)mergeHost:(NSString *)host API:(NSString *)API {
    NSURL *hostURL = [NSURL URLWithString:host];
    NSURL *mergedURL = [NSURL URLWithString:API relativeToURL:hostURL];
    return mergedURL;
}

#pragma mark - HTTPS

+ (BOOL)extractIdentity:(SecIdentityRef *)outIdentity
               andTrust:(SecTrustRef *)outTrust
         fromPKCS12Data:(NSData *)inPKCS12Data
               password:(NSString *)password{
    
    OSStatus securityError = errSecSuccess;
    NSDictionary*optionsDictionary = [NSDictionary dictionaryWithObject:password?password:@""
                                                                 forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data, (__bridge CFDictionaryRef)optionsDictionary, &items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity =NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempTrust =NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failedwith error code %d",(int)securityError);
        return NO;
    }
    
    return YES;
}

+ (AFSecurityPolicy *)xqcSecurityPolicyWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:path];
    NSSet *dataSet = [NSSet setWithObject:cerData];
    
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:dataSet];
    policy.allowInvalidCertificates = YES;
    policy.validatesDomainName = YES;
    
    return policy;
}

@end
