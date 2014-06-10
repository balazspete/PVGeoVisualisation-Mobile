//
//  PVVISArea.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 08/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISArea.h"

@implementation PVVISArea

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        self.label = [dictionary objectForKey:@"label"];
        self.values = [dictionary objectForKey:@"value"];
        self.polygon = [self getPolygonFromArray:[dictionary objectForKey:@"polygon"]];
    }
    
    return self;
}

//TODO: implement
- (MKPolygon*)getPolygonFromArray:(NSArray*)array
{
    
    return nil;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PVVISArea class]])
    {
        return [[object label] isEqualToString:self.label];
    }
    
    return NO;
}

@end
