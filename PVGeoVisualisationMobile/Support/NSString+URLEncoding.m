//
//  NSString+URLEncoding.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 30/05/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

- (NSString*)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    return (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                              NULL,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'\"();:@&=+$,/?%#[]%",
                                                              CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end
