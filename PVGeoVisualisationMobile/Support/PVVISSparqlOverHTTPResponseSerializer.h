//
//  PVVISSparqlOverHTTPResponseSerializer.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "AFURLResponseSerialization.h"
#import <Redland-ObjC.h>

@interface PVVISSparqlOverHTTPResponseSerializer : AFHTTPResponseSerializer

- (id)initWithModel:(RedlandModel*)model;

@end
