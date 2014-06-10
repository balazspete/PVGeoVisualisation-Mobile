//
//  PVVISTag.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVVISTag : NSObject

@property (readonly, nonatomic) NSString *URI;
@property (readonly, nonatomic) NSString *value;

+ (PVVISTag*)tagWithURIString:(NSString*)tag;

@end
