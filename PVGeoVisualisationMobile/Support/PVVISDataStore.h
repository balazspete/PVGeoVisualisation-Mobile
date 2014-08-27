//
//  PVVISDataStore.h
//  PVGeoVisualisationMobile
//
//  Represents a local data store
//
//  Created by Balázs Pete on 30/05/2014.
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
#import <Redland-ObjC.h>
#import <GoogleMaps/GoogleMaps.h>
#import "PVVISQuery.h"

typedef void(^ActionCallback)(NSString* action, id data);

@interface PVVISDataStore : NSObject <GMSMapViewDelegate, NSFetchedResultsControllerDelegate>

@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;

@property (nonatomic, copy) ActionCallback actionCallback;

@property (strong, nonatomic, getter = getModel) RedlandModel *model;

@property PVVISQuery *query;

- (id)initWithRemoteData:(void (^)(bool success, NSError *error))callback;
- (void)loadRemoteData:(void (^)(bool success, NSError *error))callback;

- (void)runQuery:(BOOL)fast withCallback:(ActionCallback)callback;

- (void)dumpResources;
- (void)createResults:(void (^)(bool success, NSError *error))callback;
- (void)reloadMap:(GMSMapView *)map;

- (void)reloadDataStore:(void (^)(bool success, NSError *error))callback;

- (void)zoomOutMap:(GMSMapView *)mapView;
- (void)defaultWorldView:(double *)coords;

@end
