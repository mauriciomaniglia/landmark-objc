//
//  RemoteLandmarkLoaderTests.m
//  Landmark-objcTests
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import <XCTest/XCTest.h>
#import "RemoteLandmarkLoader.h"
#import "Landmark.h"
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

-(void)test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];

    NSMutableArray *capturedLandmarks = NSMutableArray.new;
    NSMutableArray *capturedErrors = NSMutableArray.new;
    [sut loadWithCompletion: ^(NSError *error, NSArray *landmarks) {
        if ([landmarks count] > 0) { [capturedLandmarks addObject: landmarks]; }
        if (error) { [capturedErrors addObject:error]; }
    }];

    
    NSString *jsonString = @"{\"items\": []}";
    NSData *emptyListJSON = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    [client completeWithStatusCode:200 withData:emptyListJSON at:0];
    
    XCTAssertTrue([capturedErrors isEqual: @[]]);
    XCTAssertTrue([capturedLandmarks isEqual: @[]]);
}

- (void)test_load_deliversItemsOn200HTTPResponseWithJsonItems {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    
    Landmark *item1 = [Landmark new];
    item1.id = [NSUUID new].UUIDString;
    item1.landDescription = @"";
    item1.location = @"";
    item1.imageURL = [[NSURL alloc] initWithString:@"https://some-url.com"];
    
    Landmark *item2 = [Landmark new];
    item2.id = [NSUUID new].UUIDString;
    item2.landDescription = @"a description";
    item2.location = @"a location";
    item2.imageURL = [[NSURL alloc] initWithString:@"https://another-url.com"];

    [self expect: sut toCompleteWithLandmarks:@[item1, item2] when:^{
        NSMutableDictionary *item1Json = [NSMutableDictionary dictionary];
        item1Json[@"id"] = item1.id;
        item1Json[@"description"] = item1.landDescription;
        item1Json[@"location"] = item1.location;
        item1Json[@"image"] = item1.imageURL.absoluteString;
        
        NSMutableDictionary *item2Json = [NSMutableDictionary dictionary];
        item2Json[@"id"] = item2.id;
        item2Json[@"description"] = item2.landDescription;
        item2Json[@"location"] = item2.location;
        item2Json[@"image"] = item2.imageURL.absoluteString;

        NSDictionary *itemsJson = @{ @"items": @[item1Json, item2Json] };
        NSError *error;
        NSData *json = [NSJSONSerialization dataWithJSONObject:itemsJson options:kNilOptions error:&error];

        [client completeWithStatusCode:200 withData:json at:0];
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

- (void)expect: (RemoteLandmarkLoader *)sut toCompleteWithLandmarks:(NSArray<Landmark *> *)landmarks when: (void (^)(void))action {
    __block NSArray<Landmark *> *capturedLandmarks;
    [sut loadWithCompletion: ^(NSError *error, NSArray *landmarks) {
        capturedLandmarks = landmarks;
    }];
    
    action();
    
    for (int i = 0; i < landmarks.count; i++) {
        Landmark *landmark = landmarks[i];
        Landmark *capturedLandmark = capturedLandmarks[i];
        
        XCTAssertTrue([landmark.id isEqualToString:capturedLandmark.id]);
        XCTAssertTrue([landmark.landDescription isEqualToString:capturedLandmark.landDescription]);
        XCTAssertTrue([landmark.location isEqualToString:capturedLandmark.location]);
        XCTAssertTrue([landmark.imageURL.absoluteString isEqualToString:capturedLandmark.imageURL.absoluteString]);
    }
}

@end
