//
//  PVVISSparqlOverHTTPResponseSerializer.m
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

#import "PVVISSparqlOverHTTPResponseSerializer.h"
#import "PVVISConfig.h"
#import <Redland-ObjC.h>

@interface PVVISSparqlOverHTTPResponseSerializer ()

@property RedlandModel *model;

@end

@implementation PVVISSparqlOverHTTPResponseSerializer

- (id)initWithModel:(RedlandModel*)model
{
    self = [super init];
    self.model = model;
    
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:[@200 unsignedIntegerValue]];
    self.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
    
    return self;
}


- (BOOL)validateResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    return response && data;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    // instantiate and parse the model
    RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
    
    NSURL *baseURL = [NSURL URLWithString:[[PVVISConfig localEndPoint] objectForKey:@"baseURL"]];
    RedlandURI *uri = [RedlandURI URIWithURL:baseURL];

    RedlandModel *model = self.model;
    if (!model)
    {
        model = [RedlandModel new];
    }
    
    @try
    {
        [parser parseData:data intoModel:model withBaseURI:uri];
        return model;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Failed to parse RDF: %@", [exception reason]]);
        return nil;
    }
}

@end
