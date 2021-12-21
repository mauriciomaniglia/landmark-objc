//
//  RemoteLandmarkLoaderTests.m
//  Landmark-objcTests
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import <XCTest/XCTest.h>
#import "RemoteLandmarkLoader.h"
#import "HTTPClientSpy.h"

@interface RemoteLandmarkLoaderTests: XCTestCase
@end

@implementation RemoteLandmarkLoaderTests

- (void)test_init_doesNotRequestDataFromURL {
    NSURL *url = [[NSURL alloc] initWithString:@"https://a-url.com"];
    HTTPClientSpy * client = HTTPClientSpy.new;
    RemoteLandmarkLoader * sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];

    XCTAssertTrue(client.requestURLs.count == 0);
}

- (void)test_load_requestDataFromURL {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy * client = HTTPClientSpy.new;
    RemoteLandmarkLoader * sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    NSArray *requestURLs = @[url];

    [sut loadWithCompletion: ^(NSError *error) {}];

    XCTAssertTrue([client.requestURLs isEqual: requestURLs]);
}

- (void)test_loadTwice_requestDataFromURLTwice {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy * client = HTTPClientSpy.new;
    RemoteLandmarkLoader * sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    NSArray *requestURLs = @[url, url];

    [sut loadWithCompletion: ^(NSError *error) {}];
    [sut loadWithCompletion: ^(NSError *error) {}];

    XCTAssertTrue([client.requestURLs isEqual: requestURLs]);
}

- (void)test_load_deliversErrorOnClientError {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy * client = HTTPClientSpy.new;
    RemoteLandmarkLoader * sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];

    NSMutableArray *capturedErrors = NSMutableArray.new;
    [sut loadWithCompletion: ^(NSError *error) {
        [capturedErrors addObject: error];
    }];

    NSError *error = [NSError errorWithDomain:@"connectivity" code:0 userInfo:@{ NSLocalizedDescriptionKey:@"Connectivity error" }];
    [client completeWithError:error];

    XCTAssertTrue([capturedErrors isEqual: @[error]]); 
}

@end
