//
//  CalculateManager.m
//  bicycleHelper
//
//  Created by leeje on 12/10/24.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//

#import "CalculateManager.h"

@interface CalculateManager ()

- (double)distance:(double)latitude longitude:(double)longitude latitude2:(double)latitude2 longitude2:(double)longitude2;
- (double)elapsedTimeValue:(NSDate *)currentTime;
- (double)taxiFares:(double)distance startTime:(NSDate *)stime;

@end

@implementation CalculateManager

@synthesize delegate = _delegate;
@synthesize locationManager = _locationManager;

@synthesize startTime = _startTime;
@synthesize checkTime = _checkTime;

@synthesize interval = _interval;
@synthesize currentSpeed = _currentSpeed;
@synthesize currentLocation = _currentLocation;
@synthesize elapsedTime = _elapsedTime;
@synthesize distances = _distances;
@synthesize moveDistance = _moveDistance;

#pragma mark - singleton Mehtod
static CalculateManager* sharedCalculateManager = nil;

+ (CalculateManager*)sharedManager {
    @synchronized(self) {
        if (sharedCalculateManager == nil) {
            sharedCalculateManager = [[self alloc] init];
        }
    }
    return sharedCalculateManager;
}

- (id)init {
    
    self = [super init];
    if (self) {
        //初期化
        _currentSpeed = 0.0f;
        _currentLocation.latitude = 0.0f;
        _currentLocation.longitude = 0.0f;
        _elapsedTime = 0.0f;
        
        _interval = 5.0f;
        
        _locationManager=[[CLLocationManager alloc] init];
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
        
        _distances = [[NSMutableArray alloc] init];
        calcCounter = 0;
        _moveDistance = 0.0f;
    }
    return self;
}

#pragma mark - start, stop Methods
- (void)start {
    
    if (_recordTimer != nil) {
        [_recordTimer invalidate];
    }
    
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:_interval
                                                   target:self
                                                 selector:@selector(onDrawRootLine:)
                                                 userInfo:nil
                                                  repeats:YES];
    self.startTime = [NSDate date];
    self.checkTime = [NSDate date];
}

- (void)stop {
    
    [self resetData];
    
    [_recordTimer invalidate];
}

- (void)resetData {
    
    self.startTime = nil;
    self.checkTime = nil;
    _moveDistance = 0.0f;
}

- (void) onDrawRootLine:(NSTimer*)timer {
    
//    NSLog(@"%s",__FUNCTION__);
    
    //テストのため
//    double temp = arc4random() %100;
    
//    [_delegate notifyedCurrentSpeed:temp];
    
}

//#pragma mark - MKReverseGeocoderDelegate
//- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
//    
//}
//
//- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
//	NSLog(@"Geocoder completed");
//	mPlacemark=placemark;
//	[mapView addAnnotation:placemark];
//}

#pragma mark - CLLocationManagerDelegate Methods
// 좌표 업데이트 델리게이트
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	double distance = [self distance:oldLocation.coordinate.latitude longitude:oldLocation.coordinate.longitude latitude2:newLocation.coordinate.latitude longitude2:newLocation.coordinate.longitude];
    
    //일단 거리값 저장
    [_distances addObject:[NSNumber numberWithDouble:distance]];
    
    //거리를 5번 취득한후 최소값과 최대값을 제외한 평균값으로 거리를 계산한다.
    //GPS가 가끔씩 엉뚱한 데이타 값이 들어오는거 같아서...대응함.
    if (calcCounter > 5) {
        //
        
        //거리값 보정계산
        double minValue = 9999999.0f;
        double maxValue = 0.0f;
        double totalValue = 0.0f;
        
        //min
        for(NSNumber *num in _distances) {
            double tmpValue = [num doubleValue];
            if (minValue >= tmpValue) {
                minValue = tmpValue;
            }
            totalValue += tmpValue;
        }
        
        //max
        for(NSNumber *num in _distances) {
            double tmpValue = [num doubleValue];
            if(maxValue <= tmpValue) {
                maxValue = tmpValue;
            }
        }
        
        double avgDistance = (totalValue - minValue - maxValue)/3;
        
        NSLog(@"min:%f, max:%f",minValue,maxValue);
        
        //ここで距離と速度を計算し、デリゲートを実行
        double sec = fabs([_checkTime timeIntervalSinceNow]);
        double speed = (avgDistance / 1000) / (sec / 60 / 60);
        
        _moveDistance += avgDistance;
        double fares = [self taxiFares:_moveDistance startTime:_startTime];
        
        [_delegate notifiedCurrentSpeed:speed moveDistance:avgDistance taxiFares:fares didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation];
        
        NSLog(@"sec[%f], hour[%f],avgDistance[%f], speed[%f], taxi[%f], stime[%@]", sec, (sec / 60 / 60),avgDistance,speed,fares, _startTime );
        
        //초기화
        calcCounter = 0;
        self.checkTime = [NSDate date];
        [_distances removeAllObjects];
    }
    
    calcCounter++;
    
}

// 나침반 델리게이트
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
//    NSString *headingStr = [NSString stringWithFormat:
//                            @"%.4lf", newHeading.magneticHeading];
//    //NSLog(@"%@",headingStr);
//	[self.Heading setText:headingStr];
}


// GPS 오류 델리게이트
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	// GPS 좌표 업데이트에 오류가 발생할 때 호출 됨
}


#pragma mark - taxi payment calculate Method
- (double)taxiFares:(double)distance startTime:(NSDate *)stime {

    //    東京23区、武蔵野市、三鷹市
    //    普通車	距離制運賃	初乗運賃	2000mまで710円
    //    加算運賃	以後288mごとに90円
    //    時間距離併用制運賃※	1分45秒ごとに90円加算
    
    double result = 0;
    
    if (distance <= 2000) {
        //基本料金
        result = 710;
    }else {
        result = 710 + ((floor(distance - 2000)/288) * 90);
    }
    
    double seconds = fabs([stime timeIntervalSinceNow]);
    double addValue = floor(seconds/(60+45)) * 90;
    
    return result + addValue;
    
}

#pragma mark - distance calculate Mehtod
- (double)distance:(double)latitude longitude:(double)longitude latitude2:(double)latitude2 longitude2:(double)longitude2 {
    
    //-------------------------------------------------------------
    //距離計算
    // ヒュベニの距離計算式
    // D=sqrt((M*dP)*(M*dP)+(N*cos(P)*dR)*(N*cos(P)*dR))
    //
    // D: ２点間の距離(m)
    // P: ２点の平均緯度
    // dP: ２点の緯度差
    // dR: ２点の経度差
    // M: 子午線曲率半径
    // N: 卯酉線曲率半径
    // M=6334834/sqrt((1-0.006674*sin(P)*sin(P))^3)
    // N=6377397/sqrt(1-0.006674*sin(P)*sin(P))
    //-------------------------------------------------------------
    
    //始点　緯度 度分秒を度（小数）に変換後さらにラジアンに変換
    double sirad = latitude * M_PI / 180;
    // 始点　経度　度分秒を度（小数）に変換後さらにラジアンに変換
    double skrad = longitude * M_PI / 180;
    // 終点　緯度　度分秒を度（小数）に変換後さらにラジアンに変換
    double syirad = latitude2 * M_PI / 180;
    // 終点　経度　度分秒を度（小数）に変換後さらにラジアンに変換
    double sykrad = longitude2 * M_PI / 180;
    //２点間の平均緯度を計算
    double aveirad = (sirad + syirad)/2;
    //２点間の緯度差を計算
    double deffirad = sirad - syirad;
    //２点間の経度差を計算
    double deffkrad = skrad - sykrad;
    //子午線曲率半径を計算
    double temp = 1 - 0.006674 * (sin(aveirad) * sin(aveirad));
    double dmrad = 6334834 / sqrt(temp * temp * temp);
    //卯酉線曲率半径を取得
    double dvrad = 6377397 / sqrt(temp);
    //ヒュベニの距離計算式
    double t1 = dmrad * deffirad;
    double t2 = dvrad * cos(aveirad) * deffkrad;
    
    return sqrt(t1 * t1 + t2 * t2);
    
}

- (double)elapsedTimeValue:(NSDate *)currentTime {
    
    return _elapsedTime;
}

#pragma mark - memory Methods

- (void)dealloc {
    
    [super dealloc];
    
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedCalculateManager == nil) {
            sharedCalculateManager = [super allocWithZone:zone];
            return sharedCalculateManager;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone {
    return self;  // シングルトン状態を保持するため何もせず self を返す
}

- (id)retain {
    return self;  // シングルトン状態を保持するため何もせず self を返す
}

- (unsigned)retainCount {
    return UINT_MAX;  // 解放できないインスタンスを表すため unsigned int 値の最大値 UINT_MAX を返す
}

- (oneway void)release {
    // シングルトン状態を保持するため何もしない
}

- (id)autorelease {
    return self;  // シングルトン状態を保持するため何もせず self を返す
}

@end
