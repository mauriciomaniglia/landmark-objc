//
//  URLSessionHTTPClientTests.m
//  Landmark-objcTests
//
//  Created by Mauricio Cesar on 13/08/22.
//

#import <XCTest/XCTest.h>
#import "URLProtocolStub.h"

@interface URLSessionHTTPClient: NSObject

@property (nonatomic, strong) NSURLSession *session;

- (instancetype)initWithSession:(NSURLSession *)session;

- (void)getFromURL:(NSURL *)url completionHandler: (void (^)(NSData *, NSHTTPURLResponse *, NSError *))completion;

@end

@implementation URLSessionHTTPClient

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
