//
//  PVVISQueryViewController.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 05/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISQueryViewController.h"
#import "PVVISAppDelegate.h"
#import "PVVISMapViewController.h"
#import "PVVISTagCollectionViewController.h"

@interface PVVISQueryViewController ()

@property BOOL initial;
@property PVVISDataStore *dataStore;

@property PVVISMapViewController *mapViewController;

@property UITableViewController *left;
@property UICollectionViewController *right;

- (void)presentMap;

@end

@implementation PVVISQueryViewController

- (id)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.initial = YES;
        
        self.dataStore = ((PVVISAppDelegate*)[[UIApplication sharedApplication] delegate]).dataStore;
        
        self.left = [UITableViewController new];
        self.right = [[PVVISTagCollectionViewController alloc] init];
        
        self.viewControllers = @[self.left, self.right];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.initial)
    {
        self.mapViewController = [[PVVISMapViewController alloc] init];
        self.initial = NO;
        [self presentMap];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentMap
{
    [self presentViewController:self.mapViewController animated:YES completion:^{
        NSLog(@"MAP PRESENTED");
    }];
}

@end
