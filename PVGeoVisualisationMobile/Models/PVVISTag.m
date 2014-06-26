//
//  PVVISTag.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISTag.h"

@implementation PVVISTag

@synthesize uri = _uri;

- (id)initWithURIString:(NSString*)URI;
{
    self = [super init];
    if (self)
    {
        _uri = URI;
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

- (NSString*)value
{
    return [PVVISTag getValueFromURIString:self.uri];
}

- (NSString*)description
{
    return self.uri;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PVVISTag class]])
    {
        return [self.uri isEqualToString:((PVVISTag *)object).uri];
    }
    
    return false;
}

@end
