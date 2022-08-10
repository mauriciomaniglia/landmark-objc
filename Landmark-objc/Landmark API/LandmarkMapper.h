//
//  LandmarkMapper.h
//  Landmark-objc
//
//  Created by Mauricio Cesar on 10/08/22.
//

#import <Foundation/Foundation.h>
#import "Landmark.h"

@interface LandmarkMapper : NSObject

+(void)map: (NSData *)data andResponse: (NSHTTPURLResponse *)response completionHandler: (void (^)(NSArray<Landmark *> *, NSError *))completion;

@end
