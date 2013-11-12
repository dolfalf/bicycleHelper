//
//  ViewController.h
//  bicycleHelper
//
//  Created by 高 成洙 on 12/10/06.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CalculateManager.h"
#import <MapKit/MapKit.h>
#import "MeterView.h"
#import "WeatherModel.h"

@interface DashboardViewController : UIViewController <CalculateManagerDelegate, MKMapViewDelegate> {
    
    IBOutlet UILabel *lblSpeed;
    IBOutlet UILabel *lblDistance;
    IBOutlet UILabel *lblTaximeter;
    IBOutlet MKMapView *mapView;
    IBOutlet MeterView *speedometerView;
    IBOutlet UIImageView *imgViewWeather;
    IBOutlet UILabel *lblWeather;
    
    NSInteger counter;

}

@property (nonatomic, retain) AVCaptureSession *torchSession;
@property (nonatomic, retain) NSMutableArray *mutablePoints;


- (IBAction)clickLight:(id)sender;
- (IBAction)clickHorn:(id)sender;
- (IBAction)rootReset:(id)sender;
- (IBAction)requestWeather:(id)sender;

@end
