//
//  HTTPClient.h
//  Landmark-objc
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import <Foundation/Foundation.h>

@protocol HTTPClient

- (void)getFromURL:(NSURL *)url withCompletion:(void (^)(NSData *, NSHTTPURLResponse *, NSError *))completion;

@end
