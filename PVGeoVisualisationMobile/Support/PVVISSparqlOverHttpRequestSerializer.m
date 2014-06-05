//
//  PVVISSparqlOverHttpRequestSerializer.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISSparqlOverHttpRequestSerializer.h"

@interface PVVISSparqlOverHttpRequestSerializer ()

@end

@implementation PVVISSparqlOverHttpRequestSerializer

- (id)init
{
    self = [super init];
    
    return self;
}


- (NSMutableURLRequest *)GETRequest:(NSURL*)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    
    // Hack to force virtuoso to return RDF for non browser apps
//    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    
    return request;
}


@end
