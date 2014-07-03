//
//  PVVISDataStore.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 30/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
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
