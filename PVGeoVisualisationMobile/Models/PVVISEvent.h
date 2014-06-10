//
//  PVVISEvent.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 01/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "PVVISTag.h"
#import "PVVISLocation.h"

@interface PVVISEvent : NSManagedObject <MKAnnotation>

@property NSString *descriptionText;

@property NSString *URI;

@property PVVISTag *category;
@property PVVISTag *motivation;
@property NSNumber *fatalities;
@property NSNumber *date;
@property PVVISLocation *location;

@property NSArray *details;

- (id)initWithURI:(NSString*)URI description:(NSString*)description category:(PVVISTag*)category motivation:(PVVISTag*)motivation fatalities:(NSNumber*)fatalities date:(NSNumber*)date locationName:(NSString*)location;


+ (PVVISEvent*)eventWithDictionary:(NSDictionary*)dictionary;

@end
