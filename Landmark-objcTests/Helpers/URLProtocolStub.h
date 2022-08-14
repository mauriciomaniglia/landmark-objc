//
//  URLProtocolStub.h
//  Landmark-objcTests
//
//  Created by Mauricio Cesar on 14/08/22.
//

#import <Foundation/Foundation.h>

@interface URLProtocolStub : NSURLProtocol

+ (void)startInterceptingRequests;
+ (void)stopInterceptingRequests;
+ (void)stubWithURL: (NSURL *)url andData:(NSData *)data andResponse: (NSURLResponse *)response andError: (NSError *)error;

@end
