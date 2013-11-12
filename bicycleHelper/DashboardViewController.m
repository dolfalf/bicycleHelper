//
//  ViewController.m
//  bicycleHelper
//
//  Created by 高 成洙 on 12/10/06.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//

#import "DashboardViewController.h"

@interface DashboardViewController ()
{
    BOOL lightFlag;
    SystemSoundID horn;
}

- (void)initRegion:(CLLocationCoordinate2D)coors;
- (void)drawRootLine:(CLLocationCoordinate2D)coors;
- (void)clearRootLine;
- (void)initMeterView;

@end

@implementation DashboardViewController

@synthesize torchSession = _torchSession;
@synthesize mutablePoints = _mutablePoints;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    lightFlag = false;
    _torchSession = [self session];
    [self loadSounds];
    
    //    [self setRoutePoints:steps];
    //速度表示のため
    CalculateManager *calculateMgr = [CalculateManager sharedManager];
    calculateMgr.delegate = self;
    calculateMgr.interval = 3.0f;
    [calculateMgr start];
    
    //経路情報
    _mutablePoints = [[NSMutableArray alloc] init];
    
    // 地図の設定
    mapView.delegate = self;
    
    [self initMeterView];

    counter = 0;
    
    NSString *test = [[NSString alloc] initWithString:@"aaa"];
    
    bbb.k = test;
    
    
    ccc.k = test;
    [test release];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [_torchSession release];
    [_mutablePoints release];
    
    AudioServicesDisposeSystemSoundID(horn);
    
    [super dealloc];

}

#pragma mark Costom methods
- (void)initRegion:(CLLocationCoordinate2D)coors {
    
    MKCoordinateRegion region = mapView.region;
    
    // 地図の表示倍率
    region.span.latitudeDelta = 0.05;
    region.span.longitudeDelta = 0.05;
    region.center = coors;
    [mapView setRegion:region animated:YES];
    
    [bbb release];
    
}

- (void)drawRootLine:(CLLocationCoordinate2D)coors {

//    [_mutablePoints addObject:[NSValue valueWithMKCoordinate:coors]];
    
    [_mutablePoints addObject:[NSValue valueWithBytes:&coors objCType:@encode(CLLocationCoordinate2D)]];
    
    // unpacking an array of NSValues into memory
    CLLocationCoordinate2D *points = malloc([_mutablePoints count] * sizeof(CLLocationCoordinate2D));
    for(int i = 0; i < [_mutablePoints count]; i++) {
        [[_mutablePoints objectAtIndex:i] getValue:(points + i)];
    }
    
    MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:points count:[_mutablePoints count]];
    
    free(points);
    
    [mapView addOverlay:myPolyline];
    
}

- (void)clearRootLine {
    
    [_mutablePoints removeAllObjects];
    
    CalculateManager *calculateMgr = [CalculateManager sharedManager];
    [calculateMgr resetData];
}

- (void)initMeterView {
    
    speedometerView.textLabel.text = @"km/h";
	speedometerView.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0];
	speedometerView.lineWidth = 2.5;
	speedometerView.minorTickLength = 15.0;
	speedometerView.needle.width = 3.0;
	speedometerView.textLabel.textColor = [UIColor colorWithRed:0.7 green:1.0 blue:1.0 alpha:1.0];
    speedometerView.maxNumber = 160.f;
	speedometerView.value = 0.0;
}

#pragma mark MKMapViewDelegate methods
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *view = [[[MKPolylineView alloc] initWithOverlay:overlay]
                            autorelease];
    view.strokeColor = [UIColor blueColor];
    view.lineWidth = 5.0;
    return view;
}

#pragma mark -Custom Method
- (void)loadSounds
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"horn" ofType:@"wav"] isDirectory:NO];
    AudioServicesCreateSystemSoundID((CFURLRef)beepWavURL, &horn);
}

- (AVCaptureSession *)session
{
    NSError *error = nil;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    AVCaptureMovieFileOutput *movieFileOutput = [[[AVCaptureMovieFileOutput alloc] init] autorelease];
    AVCaptureSession *captureSession_ = [[[AVCaptureSession alloc] init] autorelease];
    
    [captureSession_ beginConfiguration];
    if ([captureSession_ canAddInput:videoInput]) {
        [captureSession_ addInput:videoInput];
    }
    if ([captureSession_ canAddOutput:movieFileOutput]) {
        [captureSession_ addOutput:movieFileOutput];
    }
    captureSession_.sessionPreset = AVCaptureSessionPresetLow;
    [captureSession_ commitConfiguration];
    
    return captureSession_;
}

#pragma mark - CalculateManagerDelegate Methods

- (void)notifiedCurrentSpeed:(double)speed moveDistance:(double)distance taxiFares:(double)fares didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //速度表示を更新する
    lblSpeed.text = (speed < 1)?@"0":[NSString stringWithFormat:@"%.2f",speed];
    speedometerView.value = speed;
    
    lblDistance.text = (distance < 1)?@"0":[NSString stringWithFormat:@"%.2f", distance];
    
    //経路を更新する
    if ([_mutablePoints count] == 0) {
        //開始位置をセット
        [self initRegion:newLocation.coordinate];
        [self drawRootLine:newLocation.coordinate];
    }
    
    //taximeter
    lblTaximeter.text = [NSString stringWithFormat:@"%.0f",fares];    
    
    if ((counter % 30) == 0) {
        //거의 1초에 한번씩 이벤트가 오기때문에 30초에 한번씩 선을 그리도록 조정
        [self drawRootLine:newLocation.coordinate];
        
        counter = 0;
    }
    counter++;
    
    
}

- (void) setRoutePoints:(NSArray*)locations {
    CLLocationCoordinate2D *pointsCoOrds = (CLLocationCoordinate2D*)malloc(sizeof(CLLocationCoordinate2D) * [locations count]);
    NSUInteger i, count = [locations count];
    for (i = 0; i < count; i++) {
        CLLocation* obj = [locations objectAtIndex:i];
        pointsCoOrds[i] = CLLocationCoordinate2DMake(obj.coordinate.latitude, obj.coordinate.longitude);
    }
    
    [mapView addOverlay:[MKPolyline polylineWithCoordinates:pointsCoOrds count:locations.count]];
    free(pointsCoOrds);
}

#pragma mark - IBAction
- (IBAction)clickLight:(id)sender
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    [captureDevice lockForConfiguration:&error];
    captureDevice.torchMode = !lightFlag ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    lightFlag = !lightFlag;
    [captureDevice unlockForConfiguration];    
}

- (IBAction)clickHorn:(id)sender
{
    AudioServicesPlaySystemSound(horn);
}

- (IBAction)rootReset:(id)sender {
    
    [self clearRootLine];
}

- (IBAction)requestWeather:(id)sender {
    
    [self reqeustWeather];
}

- (void)reqeustWeather {

    [WeatherModel publicWeatherModelWithBlock:^(WeatherModel *model, NSError *error) {
        if (error) { 
            [[[UIAlertView alloc] initWithTitle:@"" message:@"天気情報を取得できませんでした。" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil] show];
            
        } else {
            //画面更新
            NSString *str = model.weatherIconUrl;
            NSLog(@"str = %@", str);
            NSURL *url = [NSURL URLWithString:str];
            NSData *dt = [NSData dataWithContentsOfURL:url];
            UIImage *weatherImage = [[[UIImage alloc] initWithData:dt] autorelease];
            imgViewWeather.image = weatherImage;
            
            lblWeather.text = model.weatherDesc;
            
        }
        
    }];
    
}



@end
