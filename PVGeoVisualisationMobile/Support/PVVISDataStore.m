//
//  PVVISDataStore.m
//  PVGeoVisualisationMobile
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

#import "PVVISDataStore.h"
#import "PVVISEvent.h"
#import "PVVISArea.h"

#import "PVVISConfig.h"
#import "PVVISSparqlOverHTTP.h"
#import "PVVISEventPopoverView.h"
#import "PVVISMarker.h"

#import "PVVISEventPopoverViewController.h"

#import "GRMustache.h"

#import "PVVISAppDelegate.h"

@interface PVVISDataStore ()

@property (strong, nonatomic) RedlandStorage *storage;

@property NSMutableArray *results;

@property UIPopoverController *popover;

@end

@implementation PVVISDataStore

static dispatch_semaphore_t _activity;
static bool zoomToFit = YES;
static double minX = -100, maxX = 40, minY = 45, maxY = 70,
    _minX, _maxX, _minY, _maxY;

@synthesize fetchedResultsController, managedObjectContext;

- (id)init
{
    self = [super init];
    if (self)
    {
        PVVISAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = delegate.managedObjectContext;
        
        [self ensureModel];
        _activity = dispatch_semaphore_create(1);
        
        self.query = [PVVISQuery new];
        self.results = [NSMutableArray new];
    }
    
    return self;
}

- (void)ensureModel
{
    if (!self.storage)
    {
        self.storage = [[RedlandStorage alloc] initWithFactoryName:@"memory" identifier:@"db.rdf" options:nil];
    }
    
    if (!self.model)
    {
        self.model = [RedlandModel modelWithStorage:self.storage];
    }
}

#pragma mark - data loading

- (id)initWithRemoteData:(void (^)(bool success, NSError *error))callback
{
    self = [self init];
    
    [self loadRemoteData:callback];
    
    return self;
}

- (void)loadRemoteData:(void (^)(bool success, NSError *error))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *config = [PVVISConfig remoteEndPoint];
        
        NSString *query = [config objectForKey:@"query"];
        NSString *dataSet = [config objectForKey:@"ds"];
        
        [self ensureModel];
        
        [PVVISSparqlOverHTTP queryDataSet:dataSet withQuery:query intoModel:self.model callback:^(RedlandModel *model, NSError *error) {
            if (model)
            {
                self.model = model;
                [self createResults:callback];
            }
            else
            {
                callback(NO, error);
            }
        }];
        
        query = nil;
        dataSet = nil;
        config = nil;
    });
}

- (void)deleteAllObjectsInCoreData
{
    PVVISAppDelegate *delegate = (PVVISAppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray *allEntities = delegate.managedObjectModel.entities;
    for (NSEntityDescription *entityDescription in allEntities)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        
        fetchRequest.includesPropertyValues = NO;
        fetchRequest.includesSubentities = NO;
        
        NSError *error;
        NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"Error requesting items from Core Data: %@", [error localizedDescription]);
        }
        
        for (NSManagedObject *managedObject in items) {
            [self.managedObjectContext deleteObject:managedObject];
        }
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error deleting %@ - error:%@", entityDescription, [error localizedDescription]);
        }
    }  
}

- (void)reloadDataStore:(void (^)(bool success, NSError *error))callback
{
    [self deleteAllObjectsInCoreData];
    [self loadRemoteData:callback];
}

- (void)defaultWorldView:(double *)coords
{
    coords[0] = -130; // minX
    coords[1] = -50; // maxX
    coords[2] = 15; // minY
    coords[3] = 60; // maxY
}

//TODO: Add within polygon filtering
- (void)runQuery:(BOOL)fast withCallback:(ActionCallback)callback
{
    dispatch_semaphore_wait(_activity, DISPATCH_TIME_FOREVER);

    self.actionCallback(@"results", nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        double coords[4];
        [self defaultWorldView:coords];
        
        minX = 1.0/0, maxX = -1.0/0, minY = 1.0/0, maxY = -1.0/0;
        _minX = coords[0], _maxX = coords[1], _minY = coords[2], _maxY = coords[3];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSDictionary *localConfig = [PVVISConfig localEndPoint];
        NSString *queryString = [GRMustacheTemplate renderObject:self.query.dictionary fromString:[localConfig objectForKey:@"cd-query"] error:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (results.count == 0)
        {
            minX = coords[0], maxX = coords[1], minY = coords[2], maxY = coords[3];
            
            if (!fast)
            {
                self.results = [NSMutableArray new];
            }
            
            if (callback)
            {
                callback(@"done", @0);
            }
            else
            {
                self.actionCallback(@"done", @0);
            }
            
            dispatch_semaphore_signal(_activity);
            return;
        }
        
        NSArray *areas = [self.query getDataForKey:PVVISQueryKeyLocation];
        if (areas.count) {
            NSPredicate *locationFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                PVVISLocation *location = ((PVVISEvent *)evaluatedObject).location;
                for (PVVISArea *area in areas)
                {
                    for (GMSPolygon *polygon in area.polygons)
                    {
                        minX = MIN(minX, location.longitude.doubleValue);
                        minY = MIN(minY, location.latitude.doubleValue);
                        maxX = MAX(maxX, location.longitude.doubleValue);
                        maxY = MAX(maxY, location.latitude.doubleValue);
                        
                        if (GMSGeometryContainsLocation(location.coordinate,
                                                        polygon.path, NO))
                        {
                            return YES;
                        }
                    }
                }
                
                return NO;
            }];
            
            results = [results filteredArrayUsingPredicate:locationFilter];
        }
        else
        {
            minX = coords[0], maxX = coords[1], minY = coords[2], maxY = coords[3];
        }
        
        NSLog(@"Query results: %lu entries", results.count);
        
        zoomToFit = YES;
        
        if (!fast)
        {
            self.results = [NSMutableArray arrayWithArray:results];
        }
        
        if (callback)
        {
            callback(@"done", [NSNumber numberWithUnsignedInteger:results.count]);
        }
        else
        {
            self.actionCallback(@"done", [NSNumber numberWithUnsignedInteger:results.count]);
        }
        
        dispatch_semaphore_signal(_activity);
        return;
    });
}

- (void)createResults:(void (^)(bool success, NSError *error))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Started loading data!");
        
        NSDictionary *localConfig = [PVVISConfig localEndPoint];
        
        NSString *queryString = [GRMustacheTemplate renderObject:self.query.dictionary fromString:[localConfig objectForKey:@"query"] error:nil];
        
        RedlandQuery *query = [RedlandQuery queryWithLanguageName:RedlandSPARQLLanguageName queryString:queryString baseURI:[RedlandURI URIWithString:[localConfig objectForKey:@"baseURL"]]];
        
        [self ensureModel];
        RedlandQueryResultsEnumerator *result = [[query executeOnModel:self.model] resultEnumerator];
        
        
        for (NSDictionary *entry in result)
        {
            PVVISEvent *event = [PVVISEvent eventWithDictionary:entry insertIntoManagedObjectContext:self.managedObjectContext];
            [self.managedObjectContext insertObject:event];
        }
        
        NSError *error;
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Error saving data!");
            callback(NO, error);
        }
        
        result = nil;
        queryString = nil;
        localConfig = nil;
        
        NSLog(@"Done loading data!");
        
        callback(YES, nil);
    });
}

- (void)dumpResources
{
//    self.storage = nil;
//    self.results = [NSArray new];
//    self.model = nil;
}

#pragma mark - map view delegate

- (void)mapViewWillStartLoadingMap:(GMSMapView *)mapView
{
    [self reloadMap:mapView];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    if (((PVVISMarker *)marker).isLocationMarker)
    {
        return NO;
    }
    
    [self showCallout:((PVVISMarker *)marker) onMapView:mapView];
    return YES;
}
    
- (void)showCallout:(PVVISMarker *)marker onMapView:(GMSMapView *)mapView
{
    PVVISEventPopoverViewController *popoverView = [[PVVISEventPopoverViewController alloc] initWithEvent:marker.event];
    
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    
    CGPoint point = [mapView.projection pointForCoordinate:marker.position];
    [self.popover presentPopoverFromRect:CGRectMake(point.x-10, point.y-20, 20, 20) inView:mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [popoverView resizeContents];
    
    popoverView.actionCallback = ^(NSString* action, id data) {
        [self.popover dismissPopoverAnimated:YES];
        if ([action isEqualToString:@"show similar events"])
        {
            self.query = [PVVISQuery querySimilarToEvent:marker.event];
            self.actionCallback(@"openQueryUI", nil);
        }
        
//        , @"find nearby events"
    };
}

- (void)reloadMap:(GMSMapView *)mapView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView clear];
        
        for (PVVISEvent *event in self.results)
        {
            event.marker.map = mapView;
        }
        
        NSArray *locations = [self.query getDataForKey:PVVISQueryKeyLocation];
        for (PVVISArea *area in locations)
        {
            NSArray *arr = area.polygons;
            for (GMSPolygon *polygon in arr)
            {
                polygon.map = mapView;
            }
        }
        
        [mapView reloadInputViews];
        
        if (zoomToFit)
        {
            if (minY != INFINITY || maxY != -INFINITY || minX != INFINITY || maxX != -INFINITY)
            {
                GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:[[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(maxY, maxX) coordinate:CLLocationCoordinate2DMake(minY, minX)]];
                [mapView animateWithCameraUpdate:cameraUpdate];
            }
            zoomToFit = NO;
        }
    });
        
        NSLog(@"Reloading map");
//    });
}

- (void)zoomOutMap:(GMSMapView *)mapView
{
    double minx = minX, maxx = maxX, miny = minY, maxy = maxY;
    minX = _minX, maxX = _maxX, minY = _minY, maxY = _maxY;
    _minX = minx, _maxX = maxx, _minY = miny, _maxY = maxy;
    zoomToFit = YES;
    [self reloadMap:mapView];
}

@end
