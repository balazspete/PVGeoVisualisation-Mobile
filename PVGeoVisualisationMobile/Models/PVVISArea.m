//
//  PVVISArea.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 08/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISArea.h"

@implementation PVVISArea

@synthesize polygonRenderer = _polygonRenderer,
    boundingBox = _boundingBox;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        self.label = [dictionary objectForKey:@"label"];
        self.values = [dictionary objectForKey:@"value"];
        self.polygons = [self getPolygonsFromArray:[dictionary objectForKey:@"polygon"]];
    }
    
    return self;
}

- (NSArray*)getPolygonsFromArray:(NSArray*)array
{
    double minX = 1.0/0, maxX = -1.0/0, minY = 1.0/0, maxY = -1.0/0;
    
    NSMutableArray *polygons = [NSMutableArray new];
    for (NSArray *floats in array)
    {
        CLLocationCoordinate2D coordinates[floats.count/2];
        for (int i = 0; i < floats.count; i+=2)
        {
            double x = [floats[i] doubleValue];
            minX = MIN(x, minX);
            maxX = MAX(x, maxX);
            
            double y = [floats[i+1] doubleValue];
            minY = MIN(y, minY);
            maxY = MAX(y, maxY);
            
            coordinates[i/2] = CLLocationCoordinate2DMake(x, y);
        }
        
        [polygons addObject:[MKPolygon polygonWithCoordinates:coordinates count:(floats.count/2)]];
    }
    
    _boundingBox = @{
                     @"minX": @(minX),
                     @"minY": @(minY),
                     @"maxX": @(maxX),
                     @"maxY": @(maxY)};
    
    return polygons;
}

- (MKPolygonRenderer *)polygonRenderer
{
    if (!_polygonRenderer)
    {
        
    }
    
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
