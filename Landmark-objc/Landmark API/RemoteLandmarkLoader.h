//
//  RemoteLandmarkLoader.h
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import <Foundation/Foundation.h>
#import "HTTPClient.h"
#import "LandmarkLoader.h"

@interface RemoteLandmarkLoader: NSObject <LandmarkLoader>

- (instancetype)initWithHTTPClient:(id<HTTPClient>) client andURL:(NSURL *)url;

@end
