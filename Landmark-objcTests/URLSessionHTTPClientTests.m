//
//  URLSessionHTTPClientTests.m
//  Landmark-objcTests
//
//  Created by Mauricio Cesar on 13/08/22.
//

#import <XCTest/XCTest.h>

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

@interface URLProtocolStub: NSURLProtocol

+ (void)startInterceptingRequests;
+ (void)stopInterceptingRequests;
+ (void)stubWithURL: (NSURL *)url andData:(NSData *)data andResponse: (NSURLResponse *)response andError: (NSError *)error;

@end

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

@interface URLSessionHTTPClient: NSObject

@property (nonatomic, strong) NSURLSession *session;

- (instancetype)initWithSession:(NSURLSession *)session;

- (void)getFromURL:(NSURL *)url completionHandler: (void (^)(NSData *, NSHTTPURLResponse *, NSError *))completion;

@end

@implementation URLSessionHTTPClient

//NSURLSession *_session;

- (instancetype)initWithSession:(NSURLSession *)session {
    if (self = [self init]) {
        self.session = session;
    }
    
    return self;
}

- (void)getFromURL:(NSURL *)url completionHandler: (void (^)(NSData *, NSHTTPURLResponse *, NSError *))completion {
    [[self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            completion(nil, nil, error);
        }
    }] resume];
}

@end

@interface URLSessionHTTPClientTests: XCTestCase
@end

@implementation URLSessionHTTPClientTests

- (void)test_getFromURL_failsOnRequestError {
    [URLProtocolStub startInterceptingRequests];
    URLSessionHTTPClient *sut = [[URLSessionHTTPClient alloc] initWithSession:[NSURLSession sharedSession]];
    NSURL *url = [NSURL URLWithString:@"http://any-url.com"];
    NSError *requestError = [NSError errorWithDomain:@"any error" code:1 userInfo:nil];
    [URLProtocolStub stubWithURL:url andData:nil andResponse:nil andError:requestError];
    
    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"Wait for completion"];
    
    [sut getFromURL:url completionHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *receivedError) {
        XCTAssertEqual(receivedError.domain, requestError.domain);
        XCTAssertEqual(receivedError.code, requestError.code);

        [exp fulfill];
    }];

    [self waitForExpectations:@[exp] timeout:1.0];

    [URLProtocolStub stopInterceptingRequests];
}

@end
