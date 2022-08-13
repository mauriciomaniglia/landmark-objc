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
    NSDictionary *makeSUT = [self makeSUT];
    HTTPClientSpy *client = makeSUT[@"client"];

    XCTAssertTrue(client.requestURLs.count == 0);
}

- (void)test_load_requestDataFromURL {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    NSDictionary *makeSUT = [self makeSUTWithURL:url];
    RemoteLandmarkLoader *sut = makeSUT[@"sut"];
    HTTPClientSpy *client = makeSUT[@"client"];
    
    NSArray *requestURLs = @[url];
    [sut loadWithCompletion:^(NSArray<Landmark *> *landmarks, NSError *error) {}];

    XCTAssertTrue([client.requestURLs isEqual: requestURLs]);
}

- (void)test_loadTwice_requestDataFromURLTwice {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    NSDictionary *makeSUT = [self makeSUTWithURL:url];
    RemoteLandmarkLoader *sut = makeSUT[@"sut"];
    HTTPClientSpy *client = makeSUT[@"client"];
    NSArray *requestURLs = @[url, url];

    [sut loadWithCompletion: ^(NSArray<Landmark *> *landmarks, NSError *error) {}];
    [sut loadWithCompletion: ^(NSArray<Landmark *> *landmarks, NSError *error) {}];

    XCTAssertTrue([client.requestURLs isEqual: requestURLs]);
}

- (void)test_load_deliversErrorOnClientError {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    NSDictionary *makeSUT = [self makeSUTWithURL:url];
    HTTPClientSpy *client = makeSUT[@"client"];
    RemoteLandmarkLoader *sut = makeSUT[@"sut"];
        
    [self expect:sut toCompleteWithError:[self connectivityError] when:^{
        [client completeWithError:[self connectivityError]];
    }];
}

- (void)test_load_deliversErrorOnNon200HTTPClientResponse {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    NSDictionary *makeSUT = [self makeSUTWithURL:url];
    HTTPClientSpy *client = makeSUT[@"client"];
    RemoteLandmarkLoader *sut = makeSUT[@"sut"];

    NSArray<NSNumber *> *samples = @[@199, @201, @300, @400, @500];

    for(NSInteger i = 0; i < [samples count]; i++) {
        [self expect:sut toCompleteWithError:[self invalidError] when:^{
            NSString *jsonString = @"{\"items\": []}";
            NSData *emptyListJSON = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            [client completeWithStatusCode:(NSInteger)samples[i] withData: emptyListJSON at:i];
        }];
    }
}

- (void)test_load_deliversErrorOn200HTTPResponseWithInvalidJSON {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    NSDictionary *makeSUT = [self makeSUTWithURL:url];
    HTTPClientSpy *client = makeSUT[@"client"];
    RemoteLandmarkLoader *sut = makeSUT[@"sut"];
    
    [self expect:sut toCompleteWithError:[self invalidError] when:^{
        NSData *invalidJSON = [NSData dataWithBytes:@"invalid json".UTF8String length:0];
        [client completeWithStatusCode:200 withData:invalidJSON at:0];
    }];
}

- (void)test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList {
    NSURL *url = [[NSURL alloc] initWithString:@"https://some-url.com"];
    NSDictionary *makeSUT = [self makeSUTWithURL:url];
    HTTPClientSpy *client = makeSUT[@"client"];
    RemoteLandmarkLoader *sut = makeSUT[@"sut"];

    NSMutableArray *capturedLandmarks = NSMutableArray.new;
    NSMutableArray *capturedErrors = NSMutableArray.new;
    [sut loadWithCompletion: ^(NSArray<Landmark *> *landmarks, NSError *error) {
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
    NSDictionary *makeSUT = [self makeSUTWithURL:url];
    HTTPClientSpy *client = makeSUT[@"client"];
    RemoteLandmarkLoader *sut = makeSUT[@"sut"];
    
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

- (NSDictionary *)makeSUT {
    NSURL *url = [[NSURL alloc] initWithString:@"https://a-url.com"];
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    
    [self trackForMemoryLeaks:sut];
    [self trackForMemoryLeaks:client];
    
    return [[NSDictionary alloc] initWithObjects:@[sut, client] forKeys:@[@"sut", @"client"]];
}

- (NSDictionary *)makeSUTWithURL: (NSURL *)url {
    HTTPClientSpy *client = HTTPClientSpy.new;
    RemoteLandmarkLoader *sut = [[RemoteLandmarkLoader alloc] initWithHTTPClient:client andURL:url];
    
    [self trackForMemoryLeaks:sut];
    [self trackForMemoryLeaks:client];
    
    return [[NSDictionary alloc] initWithObjects:@[sut, client] forKeys:@[@"sut", @"client"]];
}

- (void)trackForMemoryLeaks: (NSObject *)instance {
    __weak NSObject *weakInstance = instance;
    
    [self addTeardownBlock:^{
        XCTAssertNil(weakInstance, "Instance should have been deallocated. Potential memory leak.");
    }];
}

- (void)expect: (RemoteLandmarkLoader *)sut toCompleteWithError:(NSError *)error when: (void (^)(void))action {
    NSMutableArray *capturedErrors = NSMutableArray.new;

    [sut loadWithCompletion:^(NSArray<Landmark *> *landmarks, NSError *error) {
        [capturedErrors addObject: error];
    }];
    
    action();
    
    XCTAssertTrue([capturedErrors isEqual: @[error]]);
}

- (void)expect: (RemoteLandmarkLoader *)sut toCompleteWithLandmarks:(NSArray<Landmark *> *)landmarks when: (void (^)(void))action {
    __block NSArray<Landmark *> *capturedLandmarks;
    
    [sut loadWithCompletion:^(NSArray<Landmark *> *landmarks, NSError *error) {
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

- (NSError *)invalidError {
    return [NSError errorWithDomain:@"invalid"
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey:@"Invalid error"}];
}

- (NSError *)connectivityError {
    return [NSError errorWithDomain:@"connectivity"
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey:@"Connectivity error"}];
}

@end
