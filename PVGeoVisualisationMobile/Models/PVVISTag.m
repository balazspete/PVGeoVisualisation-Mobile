//
//  PVVISTag.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISTag.h"

@implementation PVVISTag

- (id)initWithURIString:(NSString*)URI
{
    self = [super init];
    if (self)
    {
        _URI = URI;
        _value = [PVVISTag getValueFromURIString:URI];
    }
    
    return self;
}

+ (PVVISTag*)tagWithURIString:(NSString*)URI
{
    PVVISTag *newTag = [[PVVISTag alloc] initWithURIString:URI];
    return newTag;
}

+ (NSString*)getValueFromURIString:(NSString*)URI
{
    NSArray *chunks = [URI componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/#"]];
    return chunks.lastObject;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PVVISTag class]])
    {
        return ((PVVISTag *)object).URI == self.URI;
    }
    
    return false;
}

- (NSString*)description
{
    return self.URI;
}

@end
