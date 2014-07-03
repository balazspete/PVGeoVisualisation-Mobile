//
//  UIColor+PVVISColorSet.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/07/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "UIColor+PVVISColorSet.h"

@implementation UIColor (PVVISColorSet)

+ (UIColor *)labelColor
{
    return [UIColor colorWithRed:0.1f green:0.8f blue:0.44f alpha:1.0f];
}

+ (UIColor *)selectedAreaColor
{
    //249, 105, 14
    return [UIColor colorWithRed:0.97265625f green:0.41015625f blue:0.0546875 alpha:1.0f];
}

+ (UIColor *)unselectedAreaColor
{
    //210, 215, 211
    return [UIColor colorWithRed:0.8203125f green:0.83984375f blue:0.82421875f alpha:1.0f];
}

@end
