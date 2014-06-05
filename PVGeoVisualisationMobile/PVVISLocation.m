//
//  PVVISLocation.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISLocation.h"

@implementation PVVISLocation

- (id)initWithUnstructuredLocation:(NSString*)location
{
    self = [super init];
    if (self)
    {
        self.location = location;
    }
    
    return self;
}

- (id)initWithLatitude:(double)latitude longitude:(double)longitude
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self)
    {
        self.coordinate = coordinate;
    }
    
    return self;
}

@end
