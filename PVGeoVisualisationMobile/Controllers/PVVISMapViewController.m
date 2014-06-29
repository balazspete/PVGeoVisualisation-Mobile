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

#import "UIImage+StackBlur.h"

@interface PVVISMapViewController ()

@property NSMutableArray *results;
@property PVVISDataStore *dataStore;

- (void)addGestureRecogniser:(UIButton*)button selector:(SEL)selector;

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
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([action isEqualToString:@"done"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                    [self.dataStore performSelector:@selector(reloadMap:) withObject:self.mapView afterDelay:0];
#pragma clang diagnostic pop
                    self.loadingLabel.hidden = YES;
                }
                else
                {
                    [self.mapView removeAnnotations:self.mapView.annotations];
                }
                self.resultsCounter.text = [data stringValue];
            });
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mapView.delegate = self.dataStore;
    
    self.loadingLabel.hidden = YES;
    
    self.toolbar.layer.borderWidth = 0.5f;
    self.toolbar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.toolbar.layer.cornerRadius = 5;
    
    self.toolbar.opaque = YES;
    
    [self addGestureRecogniser:self.filterButton selector:@selector(openQueryUI:)];
    [self addGestureRecogniser:self.magnifyingGlassButton selector:@selector(openQueryUI:)];
    [self addGestureRecogniser:self.zoomButton selector:@selector(zoomToggle:)];
}

- (void)addGestureRecogniser:(UIButton*)button selector:(SEL)selector
{
    UITapGestureRecognizer *tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    tapGestureRecogniser.numberOfTapsRequired = 1;
    [button addGestureRecognizer:tapGestureRecogniser];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.loadingLabel.hidden = NO;
    
    if (self.runQuery)
    {
        [self.dataStore runQuery:NO withCallback:nil];
    }
    else
    {
        [self.dataStore reloadMap:self.mapView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.dataStore dumpResources];
}

#pragma mark - query UI tap handler

- (void)openQueryUI:(UITapGestureRecognizer *)sender
{
    [self captureMapImage];
    [self dismissViewControllerAnimated:NO completion:^{
        [self.dataStore reloadMap:self.mapView];
    }];
}

- (void)captureMapImage
{
    UIGraphicsBeginImageContext(self.mapView.frame.size);
    [[self.mapView layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.mapImage.image = [image stackBlur:30];
    self.mapImage.alpha = 0.8f;
    UIGraphicsEndImageContext();
}

#pragma mark - zooming

static bool inMode = YES;
- (void)zoomToggle:(UITapGestureRecognizer *)sender
{
    NSString *title = inMode ? @"Zoom out" : @"Zoom in";
    inMode = !inMode;
    [self.zoomButton setTitle:title forState:UIControlStateNormal];
    
    [self.dataStore zoomOutMap:self.mapView];
}

@end
