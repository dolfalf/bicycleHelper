//
//  MainViewController.m
//  bicycleHelper
//
//  Created by Lee jaeeun on 12/11/10.
//  Copyright (c) 2012年 kjcode. All rights reserved.
//

#import "MainViewController.h"
#import "DashboardViewController.h"
@interface MainViewController ()

-(IBAction)goDashBoard:(id)sender;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goDashBoard:(id)sender {

    DashboardViewController *ctrl = [[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
    
}

@end
