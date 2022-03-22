//
//  HTTPClientSpy.m
//  Landmark-objcTests
//
//  Created by Mauricio Maniglia on 27/11/21.
//

#import "HTTPClientSpy.h"

@implementation HTTPClientSpy

- (instancetype)init {
    if (self = [super init]) {
        _requestURLs = NSMutableArray.new;
	    _completions = NSMutableArray.new;
    }

    return self;
}

- (void)getFromURL:(NSURL *)url withCompletion:(void (^)(NSData *, NSHTTPURLResponse *, NSError *))completion {
    [self.completions addObject:[completion copy]];
    [self.requestURLs addObject:url];
}

- (void)completeWithError:(NSError *)error {
    void (^ completionError)(NSData *, NSHTTPURLResponse *, NSError *) = self.completions[0];
    completionError(NSData.new, nil, error);
}

- (void)completeWithStatusCode:(NSInteger)code withData:(NSData *)data at:(NSInteger)index {
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.requestURLs[index]
                                                            statusCode:code
                                                            HTTPVersion:nil
                                                            headerFields:nil];
    void (^ completion)(NSData *, NSHTTPURLResponse *, NSError *) = self.completions[index];
    completion(data, response, nil);
}

@end
