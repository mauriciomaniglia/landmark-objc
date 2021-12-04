//
//  Landmark.h
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import <Foundation/Foundation.h>

@interface Landmark : NSObject

@property (nonatomic, copy) NSUUID *id;
@property (nonatomic, copy) NSString *landDescription;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSURL *imageURL;

@end
