//
//  PVVISTag.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISTag.h"

@implementation PVVISTag

+ (PVVISTag*)tagWithURIString:(NSString*)URI
{
    //temp
    PVVISTag *newTag = [PVVISTag new];
    newTag.URI = URI;
    newTag.value = [PVVISTag getValueFromURIString:URI];
    return newTag;
}

+ (NSString*)getValueFromURIString:(NSString*)URI
{
    NSArray *chunks = [URI componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/#"]];
    return chunks.lastObject;
}

@end
