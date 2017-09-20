//
//  MyURLProtocol.m
//  NSURLProtocolExample
//
//  Created by kimiLin on 2017/9/13.
//  Copyright © 2017年 Rocir Santiago. All rights reserved.
//

#import "MyURLProtocol.h"

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface MyURLProtocol () <NSURLSessionDataDelegate, NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@end

@implementation MyURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"foo"]) {
        return YES;
    }
    return NO;
    
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    if ([request.URL.scheme isEqualToString:@"foo"]) {
        NSMutableURLRequest *req = request.mutableCopy;
        if (request.URL.path.length > 0) {
            /*
             Webview加载原始URL: foo://xxx的时候，会默认尝试加载一些URL对应的资源，如foo://iOS%20Developer/images/nav_logo285.png
             这里需要将这些加载的URL重定向到Google去，如https://www.google.com/images/nav_logo285.png
             */
            NSString *urlPath = [NSString stringWithFormat:@"https://www.google.com/%@", request.URL.path];
            req.URL = [NSURL URLWithString:urlPath];
            return req;
        }
        else {
            NSString *host = request.URL.host;
            host = [host stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSString *urlPath = [NSString stringWithFormat:@"https://www.google.com/search?q=%@",host];
            req.URL = [NSURL URLWithString:urlPath];
            return req;
        }
        
    }
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    BOOL rst = [super requestIsCacheEquivalent:a toRequest:b];
    return rst;
}

- (void)startLoading {
    NSMutableURLRequest *req = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:req];
    self.task = [self.session dataTaskWithRequest:req];
    [self.task resume];
}

- (void)stopLoading {
    [self.task cancel];
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

#pragma mark - Lazy load
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _session;
}

@end
