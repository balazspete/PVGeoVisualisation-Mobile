//
//  PVVISQuery.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 04/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVVISEvent.h"
#import "PVVISTag.h"

@interface PVVISQuery : NSObject

@property NSMutableDictionary *dictionary;

+ (PVVISQuery*)querySimilarToEvent:(PVVISEvent*)event;

- (id)init;
- (id)initWithLimit:(NSNumber*)limit;

- (void)addMotivation:(PVVISTag*)motivation;
- (void)addCategory:(PVVISTag*)category;

- (void)addLocation:(PVVISLocation*)location;

- (void)addFatality:(NSNumber*)date;
- (void)setMinFatality:(NSNumber*)min;
- (void)setMaxFatality:(NSNumber*)max;

- (void)addDate:(NSNumber*)date;
- (void)setMinDate:(NSNumber*)min;
- (void)setMaxDate:(NSNumber*)max;

- (void)setLimit:(NSNumber*)limit;

@end
