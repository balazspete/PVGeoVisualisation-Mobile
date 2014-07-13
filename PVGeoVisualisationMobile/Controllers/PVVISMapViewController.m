//
//  PVVISMapViewController.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 26/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISMapViewController.h"

#import "PVVISAppDelegate.h"
#import "PVVISSparqlOverHTTP.h"
#import "PVVISDataStore.h"
#import "PVVISQueryViewController.h"
#import "PVVISMarker.h"

#import <Redland-ObjC.h>

#import "UIImage+StackBlur.h"
#import "UIColor+PVVISColorSet.h"

#import "GCGeocodingService.h"

@interface PVVISMapViewController () <UIAlertViewDelegate>

@property NSMutableArray *results;
@property PVVISDataStore *dataStore;
@property UITextField *locationInputField;

@property PVVISMarker *locationMarker;
@property GCGeocodingService *geocode;

- (void)addGestureRecogniser:(UIButton*)button selector:(SEL)selector;
- (void)searchForLocation:(UITapGestureRecognizer *)sender;

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
        self.geocode = [[GCGeocodingService alloc] init];
        
        self.dataStore.actionCallback = ^(NSString* action, id data)
        {
            if ([action isEqualToString:@"openQueryUI"])
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [self openQueryUI:nil];
                return;
            }
            
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
                    [self.mapView clear];
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
    
    self.mapView.myLocationEnabled = NO;
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.rotateGestures = NO;
    
    self.mapView.delegate = self.dataStore;
    
    self.loadingLabel.hidden = YES;
    
    self.toolbar.layer.borderWidth = 0.5f;
    self.toolbar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.toolbar.layer.cornerRadius = 5;
    
    self.toolbar.opaque = YES;
    
    self.locationSearchBar.hidden = YES;
    
    [self addGestureRecogniser:self.filterButton selector:@selector(openQueryUI:)];
    [self addGestureRecogniser:self.magnifyingGlassButton selector:@selector(openQueryUI:)];
    [self addGestureRecogniser:self.zoomButton selector:@selector(zoomToggle:)];
    [self addGestureRecogniser:self.locationSearchButton selector:@selector(searchForLocation:)];
    [self addGestureRecogniser:self.locationSearchBarCloseButton selector:@selector(dismissLocationSearch:)];
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
    UIImage *image = [UIImage imageNamed:(inMode ? @"zoom-out.png" : @"zoom-in.png")];
    inMode = !inMode;
    [self.zoomButton setImage:image forState:UIControlStateNormal];
    
    [self.dataStore zoomOutMap:self.mapView];
}

#pragma mark - location search

- (void)searchForLocation:(UITapGestureRecognizer *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location search" message:@"Enter the address or the name of the place you are looking for" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.locationInputField = [alertView textFieldAtIndex:0];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *address = self.locationInputField.text;
        if (address.length > 0)
        {
            [self.geocode geocodeAddress:address withCallback:@selector(presentLocationSearch) withDelegate:self];
        }
    }
}

- (void)presentLocationSearch
{
    [self.geocode.geocode objectForKey:@"lat"];
    self.locationMarker = [PVVISMarker markerWithPosition:CLLocationCoordinate2DMake([[self.geocode.geocode objectForKey:@"lat"] doubleValue], [[self.geocode.geocode objectForKey:@"lng"] doubleValue])];
    self.locationMarker.icon = [PVVISMarker markerImageWithColor:[UIColor locationColor]];
    self.locationMarker.isLocationMarker = YES;
    self.locationMarker.appearAnimation = kGMSMarkerAnimationPop;
    self.locationMarker.map = self.mapView;
    self.locationNameDisplayField.text = self.locationInputField.text;
    self.locationSearchBar.hidden = NO;
}

- (void)dismissLocationSearch:(UITapGestureRecognizer *)sender
{
    self.locationSearchBar.hidden = YES;
    self.locationMarker.map = nil;
}

@end
