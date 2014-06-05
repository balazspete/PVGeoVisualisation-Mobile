//
//  PVVISSparqlOverHttpRequestSerializer.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "AFURLRequestSerialization.h"

@interface PVVISSparqlOverHttpRequestSerializer : AFHTTPRequestSerializer

- (NSMutableURLRequest*)GETRequest:(NSURL*)URL;

@end
