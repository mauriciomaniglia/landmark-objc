//
//  LandmarkLoader.h
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import "Landmark.h"

@protocol LandmarkLoader <NSObject>

- (void)loadWithCompletion:(void(^)(NSArray<Landmark *> *, NSError *))completion;

@end
