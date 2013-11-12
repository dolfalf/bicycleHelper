//
//  AFWeatherAPIClient.m
//  bicycleHelper
//
//  Created by Lee jaeeun on 12/11/10.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//
//天気情報取得先
//Homepage:www.worldweatheronline.com
//API-KEY:15b48b72bf021731121011
//
//Request example:
//http://free.worldweatheronline.com/feed/weather.ashx?q=35.77,139.72&format=json&num_of_days=3&key=15b48b72bf021731121011
//
//
//

#import "AFWeatherAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFWeatherAPIBaseURLString = @"http://free.worldweatheronline.com/feed/";

@implementation AFWeatherAPIClient

+ (AFWeatherAPIClient *)sharedClient {
    static AFWeatherAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFWeatherAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFWeatherAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

@end
