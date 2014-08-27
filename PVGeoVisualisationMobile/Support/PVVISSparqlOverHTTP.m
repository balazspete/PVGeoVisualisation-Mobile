//
//  PVVISSparqlOverHTTP.m
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
