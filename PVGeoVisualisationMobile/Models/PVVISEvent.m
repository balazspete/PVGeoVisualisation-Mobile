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

+ (PVVISEvent*)eventWithDictionary:(NSDictionary*)dictionary
{
    NSString *URI = [PVVISEvent URIStringValueWithKey:@"url" fromDictionary:dictionary];
    NSString *description = [PVVISEvent stringValueWithKey:@"description" fromDictionary:dictionary];
    PVVISTag *category = [PVVISEvent tagWithKey:@"category" fromDictionary:dictionary];
    PVVISTag *motivation = [PVVISEvent tagWithKey:@"motivation" fromDictionary:dictionary];
    NSNumber *fatalities = [PVVISEvent numberValueWithKey:@"fatalities" fromDictionary:dictionary];
    NSNumber *date = [PVVISEvent numberValueWithKey:@"year" fromDictionary:dictionary];
    NSString *location = [PVVISEvent stringValueWithKey:@"location" fromDictionary:dictionary];
    NSNumber *lat = [PVVISEvent numberValueWithKey:@"latitude" fromDictionary:dictionary];
    NSNumber *lng = [PVVISEvent numberValueWithKey:@"longitude" fromDictionary:dictionary];
    
    PVVISEvent *event = [[PVVISEvent alloc] initWithURI:URI description:description category:category motivation:motivation fatalities:fatalities date:date locationName:location];
    event.location.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
    return event;
}

- (id)initWithURI:(NSString*)URI description:(NSString*)description category:(PVVISTag*)category motivation:(PVVISTag*)motivation fatalities:(NSNumber*)fatalities date:(NSNumber*)date locationName:(NSString*)location
{
    self = [super init];
    if (self)
    {
        self.details = @[@"category", @"motivation", @"fatalities", @"location"];
        
        self.URI = URI;
        self.description = description;
        self.category = category;
        self.motivation = motivation;
        self.fatalities = fatalities;
        self.date = date;
        self.location = [[PVVISLocation alloc] initWithUnstructuredLocation:location];
    }
    
    return self;
}

- (NSString*)title
{
    return self.URI;
}

- (NSString*)subtitle
{
    return self.description;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    self.location = [[PVVISLocation alloc] initWithCoordinate:newCoordinate];
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

+ (PVVISTag*)tagWithKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary
{
    return [PVVISTag tagWithURIString:[(RedlandNode*)[dictionary objectForKey:key] URIStringValue]];
}


@end
