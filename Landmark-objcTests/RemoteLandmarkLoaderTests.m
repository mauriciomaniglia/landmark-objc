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

    [sut load];

    XCTAssertTrue([client.requestURLs isEqual: requestURLs]);
}

- (void)test_loadTwice_requestDataFromURLTwice {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy * client = HTTPClientSpy.new;
    RemoteLandmarkLoader * sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    NSArray *requestURLs = @[url, url];

    [sut load];
    [sut load];

    XCTAssertTrue([client.requestURLs isEqual: requestURLs]);
}

@end
