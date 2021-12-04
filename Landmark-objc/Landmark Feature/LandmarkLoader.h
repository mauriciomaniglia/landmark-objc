//
//  LandmarkLoader.h
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

@class Landmark

@protocol LandmarkLoader <NSObject>

- (void)load:(void(^)(NSArray<Landmark> *, NSError *))completion

@end
