//
//  CalculateManager.h
//  bicycleHelper
//
//  Created by leeje on 12/10/24.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>

@protocol CalculateManagerDelegate;

@interface CalculateManager : NSObject <CLLocationManagerDelegate>{
    
    NSTimer *_recordTimer;
    
    CLLocationManager	*locationManager;
    
    NSInteger calcCounter;
}

@property(nonatomic, assign) id<CalculateManagerDelegate> delegate;
@property(nonatomic, retain) CLLocationManager *locationManager;

@property(readwrite, nonatomic) double interval;

@property(nonatomic, retain) NSDate *startTime;
@property(nonatomic, retain) NSDate *checkTime;

@property(readonly, nonatomic) double currentSpeed;
@property(readonly, nonatomic) CLLocationCoordinate2D currentLocation;
@property(readonly, nonatomic) double elapsedTime;

@property(nonatomic,retain) NSMutableArray *distances;
@property (nonatomic, assign) double moveDistance;

+ (CalculateManager*)sharedManager;
- (void)start;
- (void)stop;
- (void)resetData;

@end

@protocol CalculateManagerDelegate <NSObject>

@optional
- (void)notifiedCurrentSpeed:(double)speed moveDistance:(double)distance taxiFares:(double)fares didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end
