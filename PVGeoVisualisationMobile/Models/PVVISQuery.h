//
//  PVVISQuery.h
//  PVGeoVisualisationMobile
//
//  Represents an instance of a data set query
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

#import <Foundation/Foundation.h>

#import "PVVISEvent.h"
#import "PVVISTag.h"
#import "PVVISArea.h"

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

- (BOOL)addLocation:(PVVISArea*)location;
- (BOOL)removeLocation:(PVVISArea*)location;

- (BOOL)addFatalities:(NSNumber*)date;
- (BOOL)removeFatalities:(NSNumber*)date;

- (BOOL)addDate:(NSNumber*)date;
- (BOOL)removeDate:(NSNumber*)date;

- (void)setLimit:(NSNumber*)limit;

- (void)reset:(NSString*)key;

@end
