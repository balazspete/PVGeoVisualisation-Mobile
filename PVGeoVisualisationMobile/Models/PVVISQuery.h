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

#define PVVISQueryKeyMotivation @"motivation"
#define PVVISQueryKeyCategory @"category"
#define PVVISQueryKeyLocation @"location"
#define PVVISQueryKeyFatality @"fatality"
#define PVVISQueryKeyDate @"date"
#define PVVISQueryKeyLimit @"limit"

@interface PVVISQuery : NSObject

@property NSMutableDictionary *dictionary;

+ (PVVISQuery*)querySimilarToEvent:(PVVISEvent*)event;

- (id)init;
- (id)initWithLimit:(NSNumber*)limit;

- (id)getDataForKey:(NSString*)key;

- (void)addMotivation:(PVVISTag*)motivation;
- (void)removeMotivation:(PVVISTag*)motivation;
- (void)addCategory:(PVVISTag*)category;
- (void)removeCategory:(PVVISTag*)category;

- (void)addLocation:(PVVISLocation*)location;
- (void)removeLocation:(PVVISLocation*)location;

- (void)addFatality:(NSNumber*)date;
- (void)removeFatality:(NSNumber*)date;

@property NSNumber *minDFatality;
@property NSNumber *maxDFatality;

- (void)addDate:(NSNumber*)date;
- (void)removeDate:(NSNumber*)date;

@property NSNumber *minDate;
@property NSNumber *maxDate;

- (void)setLimit:(NSNumber*)limit;

@end
