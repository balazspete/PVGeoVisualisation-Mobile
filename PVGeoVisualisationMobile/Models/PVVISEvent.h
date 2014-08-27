//
//  PVVISEvent.h
//  PVGeoVisualisationMobile
//
//  Represents an event (i.e. USPV ebent)
//
//  Created by Balázs Pete on 01/06/2014.
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
#import <GoogleMaps/GoogleMaps.h>

#import "PVVISTag.h"
#import "PVVISLocation.h"

@interface PVVISEvent : NSManagedObject

@property (nonatomic, strong) NSString *descriptionText;

@property (nonatomic, strong) NSString *uri;

@property (nonatomic, weak, readonly) PVVISTag *category;
@property (nonatomic, weak, readonly) PVVISTag *motivation;

@property (nonatomic, strong) NSString *rawCategory;
@property (nonatomic, strong) NSString *rawMotivation;

@property (nonatomic, strong) NSNumber *fatalities;
@property (nonatomic, strong) NSNumber *date;
@property (nonatomic, strong) PVVISLocation *location;

@property (readonly) NSArray *details;
@property (readonly) GMSMarker *marker;

- (id)initWithURI:(NSString*)URI description:(NSString*)description category:(NSString*)category motivation:(NSString*)motivation fatalities:(NSNumber*)fatalities date:(NSNumber*)date locationName:(NSString*)location insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

+ (PVVISEvent*)eventWithDictionary:(NSDictionary*)dictionary insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

@end
