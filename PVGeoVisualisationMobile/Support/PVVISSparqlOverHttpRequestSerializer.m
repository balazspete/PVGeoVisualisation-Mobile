//
//  PVVISSparqlOverHttpRequestSerializer.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/05/2014.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Balázs Pete
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
