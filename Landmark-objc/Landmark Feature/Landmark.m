//
//  Landmark.m
//  Landmark-objc
//
//  Created by Mauricio Cesar on 05/08/22.
//

#import <Foundation/Foundation.h>
#import "Landmark.h"

@implementation Landmark

-(instancetype)initWithUUID:(NSString *)id andDescription:(NSString *)landDescription andLocation:(NSString *)location andImage:(NSURL *)imageURL {
    if (self = [super init]) {
        _id = id;
        _landDescription = landDescription;
        _location = location;
        _imageURL = imageURL;
    }
    
    return self;
}

@end
