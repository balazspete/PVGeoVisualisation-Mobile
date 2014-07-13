//
//  PVVISMarker.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 01/07/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "PVVISEvent.h"

@interface PVVISMarker : GMSMarker

@property PVVISEvent *event;

+ (UIImage *)eventMarkerImage;
+ (UIImage *)locationMarkerImage;

@property BOOL isLocationMarker;

@end
