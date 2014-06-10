//
//  PVVISLocation.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PVVISLocation : NSManagedObject

@property NSString *location;
@property CLLocationCoordinate2D coordinate;

- (id)initWithUnstructuredLocation:(NSString*)location;
- (id)initWithLatitude:(double)latitude longitude:(double)longitude;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
