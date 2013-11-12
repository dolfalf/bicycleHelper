//
//  WeatherModel.h
//  bicycleHelper
//
//  Created by Lee jaeeun on 12/11/10.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>

@interface WeatherModel : NSObject

@property (nonatomic, retain) NSString *cloudcover;
@property (nonatomic, retain) NSString *humidity;
@property (nonatomic, retain) NSString *observation_time;
@property (nonatomic, retain) NSString *precipMM;
@property (nonatomic, retain) NSString *pressure;
@property (nonatomic, retain) NSString *temp_C;
@property (nonatomic, retain) NSString *temp_F;
@property (nonatomic, retain) NSString *visibility;
@property (nonatomic, retain) NSString *weatherCode;
@property (nonatomic, retain) NSString *weatherDesc;
@property (nonatomic, retain) NSString *weatherIconUrl;
@property (nonatomic, retain) NSString *winddir16Point;
@property (nonatomic, retain) NSString *winddirDegree;
@property (nonatomic, retain) NSString *windspeedKmph;
@property (nonatomic, retain) NSString *windspeedMiles;

- (id)initWithAttributes:(NSDictionary *)attributes;
+ (void)publicWeatherModelWithBlock:(void (^)(WeatherModel *model, NSError *error))block;

@end
