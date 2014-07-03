//
//  PVVISArea.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 08/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISArea.h"
#import "PVVISPolygon.h"
#import "UIColor+PVVISColorSet.h"

@interface PVVISArea ()

@property NSArray *polygonsInfo;

@end

@implementation PVVISArea

@synthesize boundingBox = _boundingBox,
    polygons = _polygons;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self)
    {
        self.label = [dictionary objectForKey:@"label"];
        self.values = [dictionary objectForKey:@"value"];
        self.polygonsInfo = [dictionary objectForKey:@"polygon"];
        _polygons = [self setupPolygons];
    }
    
    return self;
}

- (NSArray *)setupPolygons
{
    double minX = 1.0/0, maxX = -1.0/0, minY = 1.0/0, maxY = -1.0/0;
        
    NSMutableArray *__polygons = [NSMutableArray new];
    for (NSArray *floats in self.polygonsInfo)
    {
        GMSMutablePath *path = [GMSMutablePath path];
        for (int i = 0; i < floats.count; i+=2)
        {
            double x = [floats[i] doubleValue];
            minX = MIN(x, minX);
            maxX = MAX(x, maxX);
            
            double y = [floats[i+1] doubleValue];
            minY = MIN(y, minY);
            maxY = MAX(y, maxY);
            
            CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(y, x);
            [path addCoordinate:coords];
        }
        
        [__polygons addObject:[self polygonFromPath:path]];
    }
    
    _boundingBox = @{
                     @"minX": @(minX),
                     @"minY": @(minY),
                     @"maxX": @(maxX),
                     @"maxY": @(maxY)};
    return __polygons;
}

- (PVVISPolygon *)polygonFromPath:(GMSMutablePath *)path
{
    PVVISPolygon *polygon = [PVVISPolygon polygonWithPath:path];
    polygon.fillColor = [[UIColor labelColor] colorWithAlphaComponent:0.35f];
    polygon.strokeColor = [[UIColor labelColor] colorWithAlphaComponent:1.0f];
    polygon.strokeWidth = 1.7f;
    
    polygon.area = self;
    
    return polygon;
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
