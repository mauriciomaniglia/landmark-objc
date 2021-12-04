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
    }

    return self;
}

- (void)getFromURL:(NSURL *)url {
    [self.requestURLs addObject:url];
}

@end
