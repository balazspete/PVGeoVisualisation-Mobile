//
//  PVVISEvent.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 01/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "PVVISTag.h"
#import "PVVISLocation.h"

@interface PVVISEvent : NSManagedObject

@property (nonatomic, strong) NSString *descriptionText;

@property (nonatomic, strong) NSString *uri;

@property (nonatomic, weak, readonly) PVVISTag *category;
@property (nonatomic, weak, readonly) PVVISTag *motivation;

@property (nonatomic, strong) NSString *rawCategory;
@property (nonatomic, strong) NSString *rawMotivation;

@property (nonatomic, strong) NSNumber *fatalities;
@property (nonatomic, strong) NSNumber *date;
@property (nonatomic, strong) PVVISLocation *location;

@property (readonly) NSArray *details;
@property (readonly) GMSMarker *marker;

- (id)initWithURI:(NSString*)URI description:(NSString*)description category:(NSString*)category motivation:(NSString*)motivation fatalities:(NSNumber*)fatalities date:(NSNumber*)date locationName:(NSString*)location insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

+ (PVVISEvent*)eventWithDictionary:(NSDictionary*)dictionary insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

@end
