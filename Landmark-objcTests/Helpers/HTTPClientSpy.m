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

- (void)getFromURL:(NSURL *)url withCompletion: (void (^)(NSError *))completion {
    [self.completions addObject: [completion copy]];
    [self.requestURLs addObject:url];
}

- (void)completeWithError:(NSError *)error {
    void (^ completionError)(NSError *) = self.completions[0];
    completionError(error);
}

@end
