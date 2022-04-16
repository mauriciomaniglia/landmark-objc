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
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];

    XCTAssertTrue(client.requestURLs.count == 0);
}

- (void)test_load_requestDataFromURL {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    NSArray *requestURLs = @[url];

    [sut loadWithCompletion: ^(NSError *error, NSArray *landmarks) {}];

    XCTAssertTrue([client.requestURLs isEqual: requestURLs]);
}

- (void)test_loadTwice_requestDataFromURLTwice {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    NSArray *requestURLs = @[url, url];

    [sut loadWithCompletion: ^(NSError *error, NSArray *landmarks) {}];
    [sut loadWithCompletion: ^(NSError *error, NSArray *landmarks) {}];

    XCTAssertTrue([client.requestURLs isEqual: requestURLs]);
}

- (void)test_load_deliversErrorOnClientError {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    
    NSError *error = [NSError errorWithDomain:@"connectivity" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Connectivity error"}];
    [self expect:sut toCompleteWithError:error when:^{
        [client completeWithError:error];
    }];
}

- (void)test_load_deliversErrorOnNon200HTTPClientResponse {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];

    NSArray<NSNumber *> *samples = @[@199, @201, @300, @400, @500];

    for(NSInteger i = 0; i < [samples count]; i++) {
        NSError *error = [NSError errorWithDomain:@"invalid" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Invalid error"}];
        [self expect:sut toCompleteWithError:error when:^{
            [client completeWithStatusCode:(NSInteger)samples[i] withData: NSData.new at:i];
        }];
    }
     
}

- (void)test_load_deliversErrorOn200HTTPResponseWithInvalidJSON {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];

    NSError *error = [NSError errorWithDomain:@"invalid" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Invalid error"}];
    [self expect:sut toCompleteWithError:error when:^{
        NSData *invalidJSON = [NSData dataWithBytes:@"invalid json".UTF8String length:0];
        [client completeWithStatusCode:200 withData:invalidJSON at:0];
    }];
}

// MARK: - Helpers

- (void)expect: (RemoteLandmarkLoader *)sut toCompleteWithError:(NSError *)error when: (void (^)(void))action {
    NSMutableArray *capturedErrors = NSMutableArray.new;
    [sut loadWithCompletion: ^(NSError *error, NSArray *landmarks) {
        [capturedErrors addObject: error];
    }];
    
    action();
    
    XCTAssertTrue([capturedErrors isEqual: @[error]]);
}

@end
