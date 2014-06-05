//
//  PVVISConfig.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 30/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISConfig.h"

@interface PVVISConfig ()

@property NSDictionary *config;

@end

static PVVISConfig *instance;

@implementation PVVISConfig

- (id)init
{
    self = [super init];
    if (self)
    {
        self.config = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
    }
    return self;
}

+ (NSDictionary*)remoteEndPoint
{
    return [PVVISConfig getConfigForKey:@"remote-end-point"];
}

+ (NSDictionary*)localEndPoint
{
    return [PVVISConfig getConfigForKey:@"local-end-point"];
}

+ (NSDictionary*)getConfigForKey:(NSString*)key
{
    [PVVISConfig ensureInstance];
    return [instance.config objectForKey:key];
}

+ (void)ensureInstance
{
    if (!instance)
    {
        instance = [PVVISConfig new];
    }
}

+ (NSString *)documentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

@end
