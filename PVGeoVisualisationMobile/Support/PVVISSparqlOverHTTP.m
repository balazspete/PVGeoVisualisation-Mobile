//
//  PVVISSparqlOverHTTP.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISSparqlOverHTTP.h"
#import "PVVISSparqlOverHttpRequestSerializer.h"
#import "PVVISSparqlOverHttpResponseSerializer.h"
#import "NSString+URLEncoding.h"
#import <AFNetworking/AFNetworking.h>

@implementation PVVISSparqlOverHTTP

+ (void)queryDataSet:(NSString*)dataSet withQuery:(NSString*)query intoModel:(RedlandModel*)model callback:(callback)callback;
{
    NSString *queryString = [NSString stringWithFormat:@"%@/query?query=%@&output=xml", dataSet, [query urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:queryString]];
    
    [PVVISSparqlOverHTTP executeRequest:request intoModel:model callback:callback];
}

//+ (void)fetchDataSet:(NSString*)dataSet intoModel:(RedlandModel*)model callback:(callback)callback
//{
//    NSString *queryString = [NSString stringWithFormat:@"%@/data", dataSet, [query urlEncodeUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSLog(@"%@", queryString);
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:queryString]];
//    
//    [PVVISSparqlOverHTTP executeRequest:request intoModel:model callback:callback];
//}

+ (void)executeRequest:(NSMutableURLRequest*)request intoModel:(RedlandModel*)model callback:(callback)callback
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    PVVISSparqlOverHttpRequestSerializer *requestSerialiser = [PVVISSparqlOverHttpRequestSerializer new];
    [manager setRequestSerializer:requestSerialiser];
    
    PVVISSparqlOverHTTPResponseSerializer *responseSerializer = [[PVVISSparqlOverHTTPResponseSerializer alloc] initWithModel:model];
    [manager setResponseSerializer:responseSerializer];
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(model, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil, error);
    }];
    
    [operation start];
}

@end
