//
//  PVVISConfig.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 30/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVVISConfig : NSObject

+ (NSDictionary*)localEndPoint;
+ (NSDictionary*)remoteEndPoint;

+ (NSString *)documentsDirectory;

@end
