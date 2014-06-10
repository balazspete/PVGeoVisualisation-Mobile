//
//  PVVISDataStore.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 30/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISDataStore.h"
#import "PVVISEvent.h"

#import "PVVISConfig.h"
#import "PVVISSparqlOverHTTP.h"
#import "PVVISEventPopoverView.h"

#import "PVVISEventPopoverViewController.h"

#import "GRMustache.h"

#import <sqlite3.h>

@interface PVVISDataStore ()

@property (strong, nonatomic) RedlandStorage *storage;

@property NSArray *results;

@property UIPopoverController *popover;

@end

@implementation PVVISDataStore

- (id)init
{
    self = [super init];
    if (self)
    {
        [self ensureModel];
        
        self.query = [PVVISQuery new];
        self.results = [NSArray new];
    }
    
    return self;
}

-(void)testSqlitePresence
{
    // List available storage factories.
    for(int counter = 0;;counter++) {
        const char *name = NULL;
        const char *label = NULL;
        if(0 != librdf_storage_enumerate([RedlandWorld defaultWrappedWorld], counter, &name, &label))
            break;
        if (0 == strcmp("sqlite", name)) {
            // how nice - found it.
            return;
        }
    }
    NSLog(@"storage factory 'sqlite' not present.");
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
                callback(YES, nil);
            }
            else
            {
                callback(NO, error);
            }
            
            [self createResults];
        }];
        
        query = nil;
        dataSet = nil;
        config = nil;
    });
}

- (void)createResults
{
    self.actionCallback(@"results", nil);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *localConfig = [PVVISConfig localEndPoint];
        
        NSString *queryString = [GRMustacheTemplate renderObject:self.query.dictionary fromString:[localConfig objectForKey:@"query-template"] error:nil];
        NSLog(@"%@", queryString);
        
        RedlandQuery *query = [RedlandQuery queryWithLanguageName:RedlandSPARQLLanguageName queryString:queryString baseURI:[RedlandURI URIWithString:[localConfig objectForKey:@"baseURL"]]];
        
        [self ensureModel];
        RedlandQueryResultsEnumerator *result = [[query executeOnModel:self.model] resultEnumerator];
        
        NSMutableArray *results = [NSMutableArray new];
        
        for (NSDictionary *entry in result)
        {
            PVVISEvent *event = [PVVISEvent eventWithDictionary:entry];
            [results addObject:event];
        }
        
        
        self.results = results;
        
        NSLog(@"SPARQL query results count: %lu", self.results.count);
        
        self.actionCallback(@"results", [NSNumber numberWithUnsignedInteger:self.results.count]);
        
        result = nil;
        queryString = nil;
        localConfig = nil;
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
    [mapView removeAnnotations:mapView.annotations];
    [mapView addAnnotations:self.results];
    [mapView reloadInputViews];
}


@end
