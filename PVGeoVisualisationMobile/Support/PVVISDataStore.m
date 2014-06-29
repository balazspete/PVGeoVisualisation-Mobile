//
//  PVVISDataStore.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 30/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISDataStore.h"
#import "PVVISEvent.h"
#import "PVVISArea.h"

#import "PVVISConfig.h"
#import "PVVISSparqlOverHTTP.h"
#import "PVVISEventPopoverView.h"

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

//TODO: Add within polygon filtering
- (void)runQuery:(BOOL)fast withCallback:(ActionCallback)callback
{
    dispatch_semaphore_wait(_activity, DISPATCH_TIME_FOREVER);

    self.actionCallback(@"results", nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        minX = 1.0/0, maxX = -1.0/0, minY = 1.0/0, maxY = -1.0/0;
        _minX = -115, _maxX = -75, _minY = 15, _maxY = 60;
        
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
            minX = -115, maxX = -75, minY = 15, maxY = 60;
            
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
                    NSDictionary *box = area.boundingBox;
                    if ([[box objectForKey:@"minX"] doubleValue] <= location.longitude.doubleValue && location.longitude.doubleValue <= [[box objectForKey:@"maxX"] doubleValue] && [[box objectForKey:@"minY"] doubleValue] <= location.latitude.doubleValue && location.latitude.doubleValue <= [[box objectForKey:@"maxY"] doubleValue])
                    {
                        // TODO: add polygon filtering
                        
                        minX = MIN(minX, location.longitude.doubleValue);
                        minY = MIN(minY, location.latitude.doubleValue);
                        maxX = MAX(maxX, location.longitude.doubleValue);
                        maxY = MAX(maxY, location.latitude.doubleValue);
                        
                        return YES;
                    }
                }
                
                return false;
            }];
            
            results = [results filteredArrayUsingPredicate:locationFilter];
        }
        else
        {
            minX = -115, maxX = -75, minY = 15, maxY = 60;
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

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    [self reloadMap:mapView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    view.canShowCallout = NO;
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCallout:)]];
    
    return view;
}

- (void)showCallout:(UITapGestureRecognizer *)sender
{
    MKPinAnnotationView *view = (MKPinAnnotationView*) sender.view;

    PVVISEventPopoverViewController *popoverView = [[PVVISEventPopoverViewController alloc] initWithEvent:view.annotation];
    
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    [self.popover presentPopoverFromRect:view.frame inView:view.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [popoverView resizeContents];
    
    popoverView.actionCallback = ^(NSString* action, id data) {
        [self.popover dismissPopoverAnimated:YES];
        
        if (self.actionCallback)
        {
            self.actionCallback(action, data);
        }
    };
}

- (void)reloadMap:(MKMapView *)mapView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView removeAnnotations:mapView.annotations];
        [mapView addAnnotations:self.results];
        [mapView reloadInputViews];
        
        if (zoomToFit)
        {
            if (minY != INFINITY || maxY != -INFINITY || minX != INFINITY || maxX != -INFINITY)
            {
                [mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake((minY+maxY)/2, (minX + maxX)/2), MKCoordinateSpanMake(maxY-minY+4, maxX-minX+4)) animated:YES];
            }
            zoomToFit = NO;
        }
        
        NSLog(@"Reloading map");
    });
}

- (void)zoomOutMap:(MKMapView *)mapView
{
    double minx = minX, maxx = maxX, miny = minY, maxy = maxY;
    minX = _minX, maxX = _maxX, minY = _minY, maxY = _maxY;
    _minX = minx, _maxX = maxx, _minY = miny, _maxY = maxy;
    zoomToFit = YES;
    [self reloadMap:mapView];
}

@end
