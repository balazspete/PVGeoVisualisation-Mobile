//
//  PVVISLocation.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISLocation.h"

@implementation PVVISLocation

@synthesize location = _unstructuredLocation,
    longitude = _longitude,
latitude = _latitude;

- (id)initWithUnstructuredLocation:(NSString*)location insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"Location" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    if (self)
    {
        self.location = location;
    }
    
    return self;
}

- (id)initWithLatitude:(double)latitude longitude:(double)longitude insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"Location" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    if (self)
    {
        self.latitude = [NSNumber numberWithDouble:latitude];
        self.longitude = [NSNumber numberWithDouble:longitude];
    }
    
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self initWithLatitude:coordinate.latitude longitude:coordinate.longitude insertIntoManagedObjectContext:context];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
}

@end
