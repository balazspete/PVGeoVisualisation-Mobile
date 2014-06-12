//
//  PVVISTag.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVVISTag : NSObject

@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong, readonly) NSString *value;

- (id)initWithURIString:(NSString*)URI;

+ (PVVISTag*)tagWithURIString:(NSString*)URI;

@end
