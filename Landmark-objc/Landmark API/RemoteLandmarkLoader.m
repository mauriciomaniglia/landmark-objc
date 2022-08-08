//
//  RemoteLandmarkLoader.m
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import "RemoteLandmarkLoader.h"
#import "Landmark.h"

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
                [self map:data andResponse:response completionHandler:^(NSArray *landmarks, NSError *error) {
                    completion(error, landmarks);
                }];
            } else {
                completion([self invalidError], nil);
            }
        } else {
            completion([self connectivityError], nil);
        } 

	}];
}

- (void)map: (NSData *)data andResponse: (NSHTTPURLResponse *)response completionHandler: (void (^)(NSArray<Landmark *> *, NSError *))completion {

    if (response.statusCode != 200) {
        completion(nil, [self invalidError]);
        return;
    }
    
    NSError *error;
    id landmarksResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        completion(nil, [self invalidError]);
        return;
    }
    
    if ([landmarksResponse isKindOfClass: [NSDictionary class]]) {
        NSDictionary *dictResponse = landmarksResponse;
        NSArray *landmarks = dictResponse[@"items"];
        NSMutableArray<Landmark *> *finalResult = [NSMutableArray array];
        
        for (NSDictionary *landmark in landmarks) {
            Landmark *item = [Landmark new];
            item.id = landmark[@"id"];
            item.landDescription = landmark[@"description"] != nil ? landmark[@"description"] : @"";
            item.location = landmark[@"location"] != nil ? landmark[@"location"] : @"";
            item.imageURL = [NSURL URLWithString: landmark[@"image"]];
            
            [finalResult addObject:item];
        }
        
        completion(finalResult, nil);
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
