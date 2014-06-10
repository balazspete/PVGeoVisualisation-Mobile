//
//  PVVISQuery.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 04/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISQuery.h"

@interface PVVISQuery ()

- (void)addEntry:(id)entry forKey:(NSString*)key;
- (void)removeEntry:(id)entry forKey:(NSString*)key;

@end

@implementation PVVISQuery

- (id)init
{
    return [self initWithLimit:@300];
}

- (id)initWithLimit:(NSNumber*)limit
{
    self = [super init];
    if (self)
    {
        self.dictionary = [NSMutableDictionary new];
        [self.dictionary setValue:[NSMutableArray new] forKey:PVVISQueryKeyMotivation];
        [self.dictionary setValue:[NSMutableArray new] forKey:PVVISQueryKeyCategory];
        [self.dictionary setValue:[NSMutableArray new] forKey:PVVISQueryKeyLocation];
        [self.dictionary setValue:@{
                         @"values": [NSMutableArray new],
                         @"range": [NSMutableDictionary new]} forKey:PVVISQueryKeyDate];
        [self.dictionary setValue:@{
                         @"values": [NSMutableArray new],
                         @"range": [NSMutableDictionary new]} forKey:PVVISQueryKeyFatality];
        [self.dictionary setValue:limit forKey:PVVISQueryKeyLimit];
    }
    
    return self;
}

+ (PVVISQuery*)querySimilarToEvent:(PVVISEvent*)event
{
    PVVISQuery *query = [[PVVISQuery alloc] init];
    [query addMotivation:event.motivation];
    [query addCategory:event.category];
    return query;
}

- (id)getDataForKey:(NSString*)key
{
    NSArray *chunks = [key componentsSeparatedByString:@"."];
    __block id (^helper)(int, NSDictionary*);
    helper = [(id)^(int index, NSDictionary *dict)
    {
        if (index >= chunks.count)
        {
            return (id)dict;
        }
        
        return helper(index+1, [dict objectForKey:chunks[index]]);
    } copy];
    
    return helper(0, self.dictionary);
}

- (void)addMotivation:(PVVISTag*)motivation
{
    [self addEntry:motivation forKey:PVVISQueryKeyMotivation];
}

- (void)removeMotivation:(PVVISTag*)motivation
{
    [self removeEntry:motivation forKey:PVVISQueryKeyMotivation];
}

- (void)addCategory:(PVVISTag*)category
{
    [self addEntry:category forKey:PVVISQueryKeyCategory];
}

- (void)removeCategory:(PVVISTag*)category
{
    [self removeEntry:category forKey:PVVISQueryKeyCategory];
}

- (void)addLocation:(PVVISLocation*)location
{
    [self addEntry:location forKey:PVVISQueryKeyLocation];
}

- (void)removeLocation:(PVVISLocation*)location
{
    [self removeEntry:location forKey:PVVISQueryKeyLocation];
}

- (void)addFatality:(NSNumber*)fatality
{
    [self addEntry:fatality forKey:@"fatality.values"];
}

- (void)removeFatality:(NSNumber*)fatality
{
    [self removeEntry:fatality forKey:@"fatality.values"];
}

- (NSNumber*)minFatality
{
    return [self getDataForKey:@"fatality.range.min"];
}

- (void)setMinFatality:(NSNumber *)min
{
    NSMutableDictionary *range = [self getDataForKey:@"fatality.range"];
    [range setValue:min forKey:@"min"];
}

- (NSNumber*)maxFatality
{
    return [self getDataForKey:@"fatality.range.max"];
}

- (void)setMaxFatality:(NSNumber *)max
{
    NSMutableDictionary *range = [self getDataForKey:@"fatality.range"];
    [range setValue:max forKey:@"max"];
}

- (void)addDate:(NSNumber *)date
{
    [self addEntry:date forKey:@"date.values"];
}

- (void)removeDate:(NSNumber *)date
{
    [self removeEntry:date forKey:@"date.values"];
}

- (NSNumber*)minDate
{
    return [self getDataForKey:@"date.range.min"];
}

- (void)setMinDate:(NSNumber *)min
{
    NSMutableDictionary *range = [self getDataForKey:@"date.range"];
    [range setValue:min forKey:@"min"];
}

- (NSNumber*)maxDate
{
    return [self getDataForKey:@"date.range.max"];
}

- (void)setMaxDate:(NSNumber *)max
{
    NSMutableDictionary *range = [self getDataForKey:@"date.range"];
    [range setValue:max forKey:@"max"];
}

- (void)setLimit:(NSNumber*)limit
{
    [self.dictionary setValue:limit forKey:@"limit"];
}

#pragma mark - private helper methods

- (void)addEntry:(id)entry forKey:(NSString*)key//toArray:(NSMutableArray*)array
{
    NSMutableArray *array = [self getDataForKey:key];
    if ([array containsObject:entry])
    {
        return;
    }
    
    [array addObject:entry];
}

- (void)removeEntry:(id)entry forKey:(NSString*)key//fromArray:(NSMutableArray*)array
{
    NSMutableArray *array = [self getDataForKey:key];
    [array removeObject:entry];
}

@end
