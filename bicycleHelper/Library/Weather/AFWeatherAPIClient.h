//
//  AFWeatherAPIClient.h
//  bicycleHelper
//
//  Created by Lee jaeeun on 12/11/10.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFWeatherAPIClient : AFHTTPClient

+ (AFWeatherAPIClient *)sharedClient;

@end
