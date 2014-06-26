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

@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property CLLocationCoordinate2D coordinate;

- (id)initWithUnstructuredLocation:(NSString*)location insertIntoManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initWithLatitude:(double)latitude longitude:(double)longitude insertIntoManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

@end
