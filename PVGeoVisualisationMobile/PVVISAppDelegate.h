//
//  PVVISAppDelegate.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 23/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVVISDataStore.h"

static NSString *storagePath;

@interface PVVISAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PVVISDataStore *dataStore;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property NSString *googleAPIKey;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)resetTutorials;
- (void)presentedTutorialNamed:(NSString *)name;
- (BOOL)shouldPresentTutorialNamed:(NSString *)name;

+ (void)startTutorialNamed:(NSString *)name forView:(UIView *)view completed:(void (^)(NSString *name))callback;

@end
