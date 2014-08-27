//
//  PVVISQuery.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 04/06/2014.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Balázs Pete
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "PVVISQuery.h"
#import "GRMustacheFilter.h"

@interface PVVISQuery ()

- (BOOL)addEntry:(id)entry forKey:(NSString*)key;
- (BOOL)removeEntry:(id)entry forKey:(NSString*)key;

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
        [self.dictionary setValue:[NSMutableArray new] forKey:PVVISQueryKeyDate];
        [self.dictionary setValue:[NSMutableArray new] forKey:PVVISQueryKeyFatality];
        [self.dictionary setValue:limit forKey:PVVISQueryKeyLimit];
        [self.dictionary setValue:[GRMustacheFilter filterWithBlock:^id(id object) {
            return @([object count]==0);
        }] forKey:@"isEmpty"];
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        return helper(index+1, [dict objectForKey:chunks[index]]);
#pragma clang diagnostic pop
    } copy];
    
    return helper(0, self.dictionary);
}

- (BOOL)addMotivation:(PVVISTag*)motivation
{
    return [self addEntry:motivation forKey:PVVISQueryKeyMotivation];
}

- (BOOL)removeMotivation:(PVVISTag*)motivation
{
    return [self removeEntry:motivation forKey:PVVISQueryKeyMotivation];
}

- (BOOL)addCategory:(PVVISTag*)category
{
    return [self addEntry:category forKey:PVVISQueryKeyCategory];
}

- (BOOL)removeCategory:(PVVISTag*)category
{
    return [self removeEntry:category forKey:PVVISQueryKeyCategory];
}

- (BOOL)addLocation:(PVVISArea*)location
{
    return [self addEntry:location forKey:PVVISQueryKeyLocation];
}

- (BOOL)removeLocation:(PVVISArea*)location
{
    return [self removeEntry:location forKey:PVVISQueryKeyLocation];
}

- (BOOL)addFatalities:(NSNumber*)fatality
{
    return [self addEntry:fatality forKey:PVVISQueryKeyFatality];
}

- (BOOL)removeFatalities:(NSNumber*)fatality
{
    return [self removeEntry:fatality forKey:PVVISQueryKeyFatality];
}

- (BOOL)addDate:(NSNumber *)date
{
    return [self addEntry:date forKey:PVVISQueryKeyDate];
}

- (BOOL)removeDate:(NSNumber *)date
{
    return [self removeEntry:date forKey:PVVISQueryKeyDate];
}

- (void)setLimit:(NSNumber*)limit
{
    [self.dictionary setValue:limit forKey:@"limit"];
}

- (void)reset:(NSString*)key
{
    id data = [self getDataForKey:key];
    if ([data isKindOfClass:[NSMutableArray class]])
    {
        [((NSMutableArray*)data) removeAllObjects];
    }
    else
    {
        NSArray *chunks = [key componentsSeparatedByString:@"."];
        if (chunks.count == 3)
        {
            id _data = [self getDataForKey:[NSString stringWithFormat:@"%@.%@", chunks[0], chunks[1]]];
            [_data removeObjectForKey:chunks[2]];
        }
    }
}

#pragma mark - private helper methods

- (BOOL)addEntry:(id)entry forKey:(NSString*)key//toArray:(NSMutableArray*)array
{
    NSMutableArray *array = [self getDataForKey:key];
    if ([array containsObject:entry])
    {
        return NO;
    }
    
    [array addObject:entry];
    return YES;
}

- (BOOL)removeEntry:(id)entry forKey:(NSString*)key//fromArray:(NSMutableArray*)array
{
    NSMutableArray *array = [self getDataForKey:key];
    [array removeObject:entry];
    return YES;
}

@end
