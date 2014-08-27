//
//  PVVISTag.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
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
