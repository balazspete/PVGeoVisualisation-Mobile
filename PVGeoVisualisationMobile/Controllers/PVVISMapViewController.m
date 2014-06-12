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

static UIColor *_buttonColor;

- (id)init
{
    return [self initWithNibName:@"PVVISMapViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSArray *colorArray = @[@0.10f, @0.8f, @0.44f];
        _buttonColor = [UIColor colorWithRed:[colorArray[0] floatValue] green:[colorArray[1] floatValue] blue:[colorArray[2] floatValue] alpha:1.0f];
        
        self.results = [NSMutableArray new];
        self.dataStore = ((PVVISAppDelegate*)[[UIApplication sharedApplication] delegate]).dataStore;
        
        self.dataStore.actionCallback = ^(NSString* action, id data)
        {
            if ([action isEqualToString:@"done"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
//                [self.loadingLabel performSelectorOnMainThread:@selector(setHidden:) withObject:@YES waitUntilDone:YES ];
//                [self.loadingLabel performSelector:@selector(setHidden:) withObject:@YES afterDelay:0];
//                [self.dataStore performSelectorOnMainThread:@selector(reloadMap:) withObject:self.mapView waitUntilDone:YES];
                [self.dataStore performSelector:@selector(reloadMap:) withObject:self.mapView afterDelay:0];
#pragma clang diagnostic pop
            }
            else
            {
                [self.mapView removeAnnotations:self.mapView.annotations];
//                self.loadingLabel.hidden = NO;
            }
            
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    UITapGestureRecognizer *tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openQueryUI:)];
    tapGestureRecogniser.numberOfTapsRequired = 1;
    [self.filterButton addGestureRecognizer:tapGestureRecogniser];

    self.mapView.delegate = self.dataStore;
    
    
    self.loadingLabel.hidden = YES;
    
    self.filterButton.layer.borderWidth = 1.7f;
    self.filterButton.layer.cornerRadius = 15.0f;
    self.filterButton.layer.borderColor = _buttonColor.CGColor;
    self.filterButton.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.dataStore runQuery];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.dataStore dumpResources];
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
