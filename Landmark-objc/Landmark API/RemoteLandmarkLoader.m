//
//  RemoteLandmarkLoader.m
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import "RemoteLandmarkLoader.h"
#import "Landmark.h"
#import "LandmarkMapper.h"

@interface RemoteLandmarkLoader()

@property (nonatomic, weak) id<HTTPClient> client;
@property (nonatomic, weak) NSURL *url;

@end

@implementation RemoteLandmarkLoader

- (instancetype)initWithHTTPClient:(id<HTTPClient>)client andURL:(NSURL *)url {
    if (self = [self init]) {
        _client = client;
        _url = url;
    }

    return self;
}

- (void)loadWithCompletion:(void (^)(NSArray<Landmark *> *, NSError *))completion {
    [_client getFromURL:_url withCompletion: ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {

        if (response) {
            [LandmarkMapper map:data andResponse:response completionHandler:^(NSArray *landmarks, NSError *error) {
                completion(landmarks, error);
            }];
        } else {
            completion(nil, [self connectivityError]);
        }

    }];
}

- (NSError *)connectivityError {
    return [NSError errorWithDomain:@"connectivity"
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey:@"Connectivity error"}];
}

@end
