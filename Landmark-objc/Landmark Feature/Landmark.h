//
//  Landmark.h
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import <Foundation/Foundation.h>

@interface Landmark : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *landDescription;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSURL *imageURL;

-(instancetype)initWithUUID: (NSString *)id andDescription: (NSString *) landDescription andLocation: (NSString *)location andImage: (NSURL *)imageURL;

@end
