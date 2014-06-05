//
//  PVVISMapViewController.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 26/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISMapViewController.h"
#import <MapKit/MapKit.h>

#import "PVVISAppDelegate.h"
#import "PVVISSparqlOverHTTP.h"
#import "PVVISDataStore.h"
#import "PVVISQueryViewController.h"
#import <Redland-ObjC.h>

@interface PVVISMapViewController ()

@property NSMutableArray *results;
@property PVVISDataStore *dataStore;

@end

@implementation PVVISMapViewController

- (id)init
{
    return [self initWithNibName:@"PVVISMapViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.results = [NSMutableArray new];
        self.dataStore = ((PVVISAppDelegate*)[[UIApplication sharedApplication] delegate]).dataStore;
        
        self.dataStore.actionCallback = ^(NSString* action, id data)
        {
            NSLog(@"Action: %@\nData: %@", action, data);
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    
    UITapGestureRecognizer *tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openQueryUI:)];
    tapGestureRecogniser.numberOfTapsRequired = 1;
    [self.filterButton addGestureRecognizer:tapGestureRecogniser];

    [self loadDataFromDatabase];
    self.mapView.delegate = self.dataStore;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.dataStore dumpResources];
}

#pragma mark - initial data load

- (void)loadDataFromDatabase
{
    self.loadingLabel.hidden = NO;
    [self.dataStore loadRemoteData:^(bool success, NSError *error) {
        if (!success)
        {
            NSLog(@"Error: %@", error.description);
        }
        self.loadingLabel.hidden = YES;
        [self.mapView reloadInputViews];
    }];
}

#pragma mark - query UI tap handler

- (void)openQueryUI:(UITapGestureRecognizer *)sender
{
    NSLog(@"button pressed");
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed");
    }];
}



@end
