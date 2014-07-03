//
//  PVVISPolygon.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/07/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "PVVISArea.h"

@interface PVVISPolygon : GMSPolygon

@property PVVISArea *area;

@end
