//
//  PVVISSparqlOverHTTPResponseSerializer.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
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
