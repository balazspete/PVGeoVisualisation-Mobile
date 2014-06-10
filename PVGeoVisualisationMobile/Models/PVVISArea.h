//
//  PVVISArea.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 08/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PVVISArea : NSObject

- (id)initWithDictionary:(NSDictionary*)dictionary;

@property NSString *label;
@property MKPolygon *polygon;
@property NSArray *values;

@end
