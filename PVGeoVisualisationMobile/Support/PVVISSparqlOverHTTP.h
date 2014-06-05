//
//  PVVISSparqlOverHTTP.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Redland-ObjC.h>

@interface PVVISSparqlOverHTTP : NSObject

typedef void (^callback)(RedlandModel *model, NSError *error);

+ (void)queryDataSet:(NSString*)dataSet withQuery:(NSString*)query intoModel:(RedlandModel*)model callback:(callback)callback;

//+ (void)fetchDataSet:(NSString*)dataSet intoModel:(RedlandModel*)model callback:(callback)callback;

@end
