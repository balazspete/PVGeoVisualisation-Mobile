//
//  PVVISQuery.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 04/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISQuery.h"

@interface PVVISQuery ()

- (void)addEntry:(id)entry toArray:(NSMutableArray*)array;

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
        [self.dictionary setValue:[NSMutableArray new] forKey:@"motivations"];
        [self.dictionary setValue:[NSMutableArray new] forKey:@"categories"];
        [self.dictionary setValue:[NSMutableArray new] forKey:@"locations"];
        [self.dictionary setValue:@{
                         @"values": [NSMutableArray new],
                         @"range": [NSMutableDictionary new]} forKey:@"year"];
        [self.dictionary setValue:@{
                         @"values": [NSMutableArray new],
                         @"range": [NSMutableDictionary new]} forKey:@"fatalities"];
        [self.dictionary setValue:limit forKey:@"limit"];
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

- (void)addMotivation:(PVVISTag*)motivation
{
    [self addEntry:motivation toArray:[self.dictionary objectForKey:@"motivations"]];
}

- (void)addCategory:(PVVISTag*)category
{
    [self addEntry:category toArray:[self.dictionary objectForKey: @"categories"]];
}

- (void)addLocation:(PVVISLocation*)location
{
    [self addEntry:location toArray:[self.dictionary objectForKey: @"locations"]];
}

- (void)addFatality:(NSNumber*)fatality
{
    [self addEntry:fatality toArray:[[self.dictionary objectForKey:@"fatalities"] objectForKey:@"values"]];
}

- (void)setMinFatality:(NSNumber *)min
{
    NSMutableDictionary *range = [[self.dictionary objectForKey:@"fatalities"] objectForKey:@"range"];
    [range setValue:min forKey:@"min"];
}

- (void)setMaxFatality:(NSNumber *)max
{
    NSMutableDictionary *range = [[self.dictionary objectForKey:@"fatalities"] objectForKey:@"range"];
    [range setValue:max forKey:@"max"];
}

- (void)addDate:(NSNumber *)date
{
    [self addEntry:date toArray:[[self.dictionary objectForKey:@"year"] objectForKey:@"values"]];
}

- (void)setMinDate:(NSNumber *)min
{
    NSMutableDictionary *range = [[self.dictionary objectForKey:@"year"] objectForKey:@"range"];
    [range setValue:min forKey:@"min"];
}

- (void)setMaxDate:(NSNumber *)max
{
    NSMutableDictionary *range = [[self.dictionary objectForKey:@"year"] objectForKey:@"range"];
    [range setValue:max forKey:@"max"];
}

- (void)setLimit:(NSNumber*)limit
{
    [self.dictionary setValue:limit forKey:@"limit"];
}

- (void)addEntry:(id)entry toArray:(NSMutableArray*)array
{
    if ([array containsObject:entry])
    {
        return;
    }
    
    [array addObject:entry];
}



@end
