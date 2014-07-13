//
//  PVVISMapViewController.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 26/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface PVVISMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomButton;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *magnifyingGlassButton;

@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultsCounter;

@property (weak, nonatomic) IBOutlet UIButton *locationSearchButton;

@property (weak, nonatomic) IBOutlet UIView *locationSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *locationSearchBarCloseButton;
@property (weak, nonatomic) IBOutlet UILabel *locationNameDisplayField;

@property UIImageView *mapImage;
@property BOOL runQuery;

@end
