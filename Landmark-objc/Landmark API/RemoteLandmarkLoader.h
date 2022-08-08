//
//  RemoteLandmarkLoader.h
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import <Foundation/Foundation.h>
#import "HTTPClient.h"

@interface RemoteLandmarkLoader: NSObject

- (instancetype)initWithHTTPClient:(id<HTTPClient>) client andURL:(NSURL *)url;

- (void)loadWithCompletion:(void (^)(NSError *, NSArray *))completion;

@end
