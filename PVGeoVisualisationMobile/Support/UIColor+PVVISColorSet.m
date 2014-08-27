//
//  UIColor+PVVISColorSet.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/07/2014.
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

#import "UIColor+PVVISColorSet.h"

@implementation UIColor (PVVISColorSet)

+ (UIColor *)labelColor
{
    return [UIColor colorWithRed:0.1f green:0.8f blue:0.44f alpha:1.0f];
}

+ (UIColor *)locationColor
{
    return [UIColor colorWithRed:0.203125f green:0.59375f blue:0.85546875f alpha:1.0f];
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
