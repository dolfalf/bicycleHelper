//
//  WeatherModel.m
//  bicycleHelper
//
//  Created by Lee jaeeun on 12/11/10.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//

#import "WeatherModel.h"
#import "AFWeatherAPIClient.h"
#import "CalculateManager.h"

NSString *const kNumOfDays = @"2";
NSString *const kKey = @"15b48b72bf021731121011";

@interface WeatherModel ()
- (NSString *)arrayInString:(NSArray *)params;

@end

@implementation WeatherModel

@synthesize cloudcover = _cloudcover;
@synthesize humidity = _humidity;
@synthesize observation_time = _observation_time;
@synthesize precipMM = _precipMM;
@synthesize pressure = _pressure;
@synthesize temp_C = _temp_C;
@synthesize temp_F = _temp_F;
@synthesize visibility = _visibility;
@synthesize weatherCode = _weatherCode;
@synthesize weatherDesc = _weatherDesc;
@synthesize weatherIconUrl = _weatherIconUrl;
@synthesize winddir16Point = _winddir16Point;
@synthesize winddirDegree = _winddirDegree;
@synthesize windspeedKmph = _windspeedKmph;
@synthesize windspeedMiles = _windspeedMiles;

#pragma mark - initialize
- (id)initWithAttributes:(NSDictionary *)attributes {

    NSArray *arrays = [attributes objectForKey:@"current_condition"];
    NSDictionary *data = nil;
    if ([arrays count] > 0) {
        data = [arrays objectAtIndex:0];
    }
    else {
        return self;
    }
    
    
    
    _cloudcover = [data objectForKey:@"cloudcover"];
    _humidity = [data objectForKey:@"humidity"];
    _observation_time = [data objectForKey:@"observation_time"];
    _precipMM = [data objectForKey:@"precipMM"];
    _pressure = [data objectForKey:@"pressure"];
    _temp_C = [data objectForKey:@"temp_C"];
    _temp_F = [data objectForKey:@"temp_F"];
    _visibility = [data objectForKey:@"visibility"];
    _weatherCode = [data objectForKey:@"weatherCode"];
    _weatherDesc = [self arrayInString:[data objectForKey:@"weatherDesc"]];
    _weatherIconUrl = [self arrayInString:[data objectForKey:@"weatherIconUrl"]];
    _winddir16Point = [data objectForKey:@"winddir16Point"];
    _winddirDegree = [data objectForKey:@"winddirDegree"];
    _windspeedKmph = [data objectForKey:@"windspeedKmph"];
    _windspeedMiles = [data objectForKey:@"windspeedMiles"];
    
    return self;
}

#pragma mark - Custom Methods
- (NSString *)arrayInString:(NSArray *)params {
    
    NSString *result = @"";
    
    for (NSDictionary *dic in params ) {
        //
        result = [dic objectForKey:@"value"];
        break;
    }
    
    return result;
}

+ (void)publicWeatherModelWithBlock:(void (^)(WeatherModel *model, NSError *error))block {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    //座標
    CalculateManager *mgr = [CalculateManager sharedManager];
    NSString *coorsString = [NSString stringWithFormat:@"%.2f,%.2f", mgr.currentLocation.latitude, mgr.currentLocation.longitude];
    [params setObject:coorsString forKey:@"q"];         //xx.xx,xx.xx
    
    [params setObject:@"json" forKey:@"format"];
    [params setObject:kNumOfDays forKey:@"num_of_days"];
    [params setObject:kKey forKey:@"key"];
    
    [[AFWeatherAPIClient sharedClient] getPath:@"weather.ashx" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {

        WeatherModel *model = [[[WeatherModel alloc] initWithAttributes:[JSON objectForKey:@"data"]] autorelease];
//        NSLog(@".....%@",[JSON objectForKey:@"data"]);

        if (block) {
            block(model, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([[WeatherModel alloc] init], error);
        }
    }];
}

@end
