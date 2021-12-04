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

- (instancetype)initWithHTTPClient: (id<HTTPClient>)client andURL: (NSURL *)url {
    if (self = [self init]) {
        _client = client;
        _url = url;
    }

    return self;
}

- (void)load {
    [_client getFromURL:_url];
}

@end
