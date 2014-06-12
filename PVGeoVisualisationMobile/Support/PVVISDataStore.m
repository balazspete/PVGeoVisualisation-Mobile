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

#import "PVVISAppDelegate.h"

@interface PVVISDataStore ()

@property (strong, nonatomic) RedlandStorage *storage;

@property NSMutableArray *results;

@property UIPopoverController *popover;

@end

@implementation PVVISDataStore

@synthesize fetchedResultsController, managedObjectContext;

- (id)init
{
    self = [super init];
    if (self)
    {
        PVVISAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = delegate.managedObjectContext;
        
        [self ensureModel];
        
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

- (void)reloadDataStore
{
    [self deleteAllObjectsInCoreData];
    [self loadRemoteData:^(bool success, NSError *error) {
        
        
        //TODO: notify or something...
    }];
}

- (void)runQuery {
    self.actionCallback(@"results", nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSDictionary *localConfig = [PVVISConfig localEndPoint];
        NSString *queryString = [GRMustacheTemplate renderObject:self.query.dictionary fromString:[localConfig objectForKey:@"cd-query"] error:nil];
        NSLog(@"%@", queryString);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
        [request setPredicate:predicate];
        
        NSError *error;
        self.results = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];
        
        self.actionCallback(@"done", [NSNumber numberWithUnsignedInteger:self.results.count]);
    });
}
- (NSError *)willPresentError:(NSError *)error {
    
    // Only deal with Core Data Errors
    if (!([[error domain] isEqualToString:NSCocoaErrorDomain])) {
        return error;
    }
    NSInteger errorCode = [error code];
    if ((errorCode < NSValidationErrorMinimum) || (errorCode > NSValidationErrorMaximum)) {
        return error;
    }
    
    // If there is only 1 error, let the usual alert display it
    if (errorCode != NSValidationMultipleErrorsError) {
        return error;
    }
    
    // Get the errors. NSValidationMultipleErrorsError - the errors are in an array in the userInfo dictionary for key NSDetailedErrorsKey
    NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    NSUInteger errorCount = [detailedErrors count];
    NSMutableString *errorString = [NSMutableString stringWithFormat:@"There are %lu validation errors:-", errorCount];
    for (int i = 0; i < errorCount; i++) {
        [errorString appendFormat:@"%@\n",
         [[detailedErrors objectAtIndex:i] localizedDescription]];
    }
    
    // Create a new error with the new userInfo and return it
    NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
    [newUserInfo setObject:errorString forKey:NSLocalizedDescriptionKey];
    NSError *newError = [NSError errorWithDomain:[error domain] code:[error code] userInfo:newUserInfo];
    return newError;
}
- (void)createResults
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            [self willPresentError:error];
        }
        
        result = nil;
        queryString = nil;
        localConfig = nil;
        
        [self runQuery];
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
