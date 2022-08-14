//
//  URLProtocolStub.m
//  Landmark-objcTests
//
//  Created by Mauricio Cesar on 14/08/22.
//

#import "URLProtocolStub.h"


// MARK: Stub

@interface Stub: NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;

- (instancetype)initWithData:(NSData *)data andResponse: (NSURLResponse *)response andError:(NSError *)error;

@end

@implementation Stub

- (instancetype)initWithData:(NSData *)data andResponse: (NSURLResponse *)response andError:(NSError *)error {
    
    if (self = [self init]) {
        _data = data;
        _response = response;
        _error = error;
    }
    
    return self;
}

@end

// end Stub



@implementation URLProtocolStub

static NSMutableDictionary *stubs;

+ (void)stubWithURL: (NSURL *)url andData:(NSData *)data andResponse: (NSURLResponse *)response andError: (NSError *)error {
    if (stubs == nil) {
        stubs = [NSMutableDictionary dictionary];
    }

    stubs[url] = [[Stub alloc] initWithData:data andResponse:response andError:error];
}

+ (void)startInterceptingRequests {
    [NSURLProtocol registerClass: [URLProtocolStub self]];
}

+ (void)stopInterceptingRequests {
    [NSURLProtocol unregisterClass:[URLProtocolStub self]];
    stubs = nil;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSURL *url = request.URL;
    
    if (url == nil) { return NO; }
    
    return stubs[url] != nil;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSURL *url = self.request.URL;
    Stub *stub = stubs[url];
    
    if (url == nil && stub == nil) return;
    
    NSData *data = stub.data;
    NSURLResponse *response = stub.response;
    NSError *error = stub.error;
    
    if (data != nil) [self.client URLProtocol:self didLoadData:data];
    if (response != nil) [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:(NSURLCacheStorageNotAllowed)];
    if (error != nil) [self.client URLProtocol:self didFailWithError:error];
    
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {}

@end
