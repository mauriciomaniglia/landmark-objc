//
//  HTTPClientSpy.h
//  Landmark-objcTests
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import "HTTPClient.h"

@interface HTTPClientSpy: NSObject <HTTPClient>

@property (nonatomic, strong) NSMutableArray *requestURLs;
@property (nonatomic, strong) NSMutableArray *completions;

- (void)completeWithError:(NSError *)error;
- (void)completeWithStatusCode:(NSInteger)code withData:(NSData *)data at:(NSInteger)index;

@end
