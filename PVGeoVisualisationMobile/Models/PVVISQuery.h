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
#define PVVISQueryKeyFatality @"fatalities"
#define PVVISQueryKeyDate @"date"
#define PVVISQueryKeyLimit @"limit"

@interface PVVISQuery : NSObject

@property NSMutableDictionary *dictionary;

+ (PVVISQuery*)querySimilarToEvent:(PVVISEvent*)event;

- (id)init;
- (id)initWithLimit:(NSNumber*)limit;

- (id)getDataForKey:(NSString*)key;

- (BOOL)addMotivation:(PVVISTag*)motivation;
- (BOOL)removeMotivation:(PVVISTag*)motivation;

- (BOOL)addCategory:(PVVISTag*)category;
- (BOOL)removeCategory:(PVVISTag*)category;

- (BOOL)addLocation:(PVVISLocation*)location;
- (BOOL)removeLocation:(PVVISLocation*)location;

- (BOOL)addFatalities:(NSNumber*)date;
- (BOOL)removeFatalities:(NSNumber*)date;

- (BOOL)addDate:(NSNumber*)date;
- (BOOL)removeDate:(NSNumber*)date;

- (void)setLimit:(NSNumber*)limit;

- (void)reset:(NSString*)key;

@end
