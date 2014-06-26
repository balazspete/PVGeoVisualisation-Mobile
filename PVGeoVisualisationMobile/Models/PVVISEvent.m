//
//  PVVISEvent.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 01/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISEvent.h"
#import "PVVISTag.h"
#import <Redland-ObjC.h>

@interface PVVISEvent () <MKAnnotation>


@end

@implementation PVVISEvent

@synthesize uri = _uri,
    fatalities = _fatalities,
    date = _date,
    location = _location,
    descriptionText = _descriptionText,
    details = _details,
    rawMotivation, rawCategory;

@dynamic category, motivation;

+ (PVVISEvent*)eventWithDictionary:(NSDictionary*)dictionary insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *URI = [PVVISEvent URIStringValueWithKey:@"url" fromDictionary:dictionary];    NSString *description = [PVVISEvent stringValueWithKey:@"description" fromDictionary:dictionary];
    NSString *category = [PVVISEvent URIStringValueWithKey:@"category" fromDictionary:dictionary];
    NSString *motivation = [PVVISEvent URIStringValueWithKey:@"motivation" fromDictionary:dictionary];
    NSNumber *fatalities = [PVVISEvent numberValueWithKey:@"fatalities" fromDictionary:dictionary];
    NSNumber *date = [PVVISEvent numberValueWithKey:@"year" fromDictionary:dictionary];
    NSString *location = [PVVISEvent stringValueWithKey:@"location" fromDictionary:dictionary];
    NSNumber *lat = [PVVISEvent numberValueWithKey:@"latitude" fromDictionary:dictionary];
    NSNumber *lng = [PVVISEvent numberValueWithKey:@"longitude" fromDictionary:dictionary];
    
    PVVISEvent *event = [[PVVISEvent alloc] initWithURI:URI description:description category:category motivation:motivation fatalities:fatalities date:date locationName:location insertIntoManagedObjectContext:context];
    [event setCoordinate:CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue])];
    return event;
}

- (id)initWithURI:(NSString*)URI description:(NSString*)description category:(NSString*)category motivation:(NSString*)motivation fatalities:(NSNumber*)fatalities date:(NSNumber*)date locationName:(NSString*)location insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    if (self)
    {
        self.uri = URI;
        self.descriptionText = description;
        self.rawCategory = category;
        self.rawMotivation = motivation;
        self.fatalities = fatalities;
        self.date = date;
        
        self.location = [[PVVISLocation alloc] initWithUnstructuredLocation:location insertIntoManagedObjectContext:context];
        
        _details = @[@"category", @"motivation", @"fatalities", @"location"];
    }
    
    return self;
}

- (NSString*)title
{
    return self.uri;
}

- (NSString*)subtitle
{
    return self.description;
}

- (PVVISTag*)category
{
    return [PVVISTag tagWithURIString:self.rawCategory];
}

- (PVVISTag*)motivation
{
    return [PVVISTag tagWithURIString:self.rawMotivation];
}

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    [self.location setCoordinate:newCoordinate];
}

#pragma mark - RedlandNode helper

+ (NSString*)URIStringValueWithKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary
{
    return [(RedlandNode*)[dictionary objectForKey:key] URIStringValue];
}

+ (NSString*)stringValueWithKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary
{
    return [(RedlandNode*)[dictionary objectForKey:key] stringValue];
}

+ (NSNumber*)numberValueWithKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary
{
    RedlandNode *node = (RedlandNode*)[dictionary objectForKey:key];
    @try {
        return [NSNumber numberWithDouble:[node doubleValue]];
    }
    @catch (RedlandException *exception) {
        return [NSNumber numberWithInteger:[node intValue]];
    }
}

@end
