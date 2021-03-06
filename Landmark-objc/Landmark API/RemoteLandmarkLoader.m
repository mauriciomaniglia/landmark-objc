//
//  RemoteLandmarkLoader.m
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import "RemoteLandmarkLoader.h"

@implementation RemoteLandmarkLoader

id<HTTPClient> _client;
NSURL * _url;

- (instancetype)initWithHTTPClient:(id<HTTPClient>)client andURL:(NSURL *)url {
    if (self = [self init]) {
        _client = client;
        _url = url;
    }

    return self;
}

- (void)loadWithCompletion:(void (^)(NSError *, NSArray *))completion {
    [_client getFromURL:_url withCompletion: ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {

        if (response) {
            NSError *error = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            
            if (jsonArray) {
                completion(nil, @[]);
            } else {
                NSError *invalidError = [NSError errorWithDomain:@"invalid" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Invalid error"}];
                completion(invalidError, nil);
            }
        } else {
            NSError *conectivityError = [NSError errorWithDomain:@"connectivity" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Connectivity error"}];
            completion(conectivityError, nil);
        } 

	}];
}

@end
