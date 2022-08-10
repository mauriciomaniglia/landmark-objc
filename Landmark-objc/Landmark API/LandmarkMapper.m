//
//  LandmarkMapper.m
//  Landmark-objc
//
//  Created by Mauricio Cesar on 10/08/22.
//

#import "LandmarkMapper.h"
#import "Landmark.h"

@implementation LandmarkMapper

+(void)map: (NSData *)data andResponse: (NSHTTPURLResponse *)response completionHandler: (void (^)(NSArray<Landmark *> *, NSError *))completion {
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

+(NSError *)invalidError {
    return [NSError errorWithDomain:@"invalid"
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey:@"Invalid error"}];
}

@end
