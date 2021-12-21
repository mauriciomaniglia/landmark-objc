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

- (void)test_load_deliversErrorOnNon200HTTPClientResponse {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy * client = HTTPClientSpy.new;
    RemoteLandmarkLoader * sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];

    NSArray<NSNumber *> *samples = @[@199, @201, @300, @400, @500];

    for(NSInteger i = 0; i < [samples count]; i++) {

        NSMutableArray<NSError *> *capturedErrors = NSMutableArray.new;
        [sut loadWithCompletion: ^(NSError *error) {        
             [capturedErrors addObject: error];
        }];

        [client completeWithStatusCode: samples[i] at: i];

        XCTAssertTrue([capturedErrors count] == 1);
        XCTAssertTrue([capturedErrors[0].domain isEqual: @"invalid"]);        
    }
     
}

@end
