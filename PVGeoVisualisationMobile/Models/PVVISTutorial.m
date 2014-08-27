//
//  PVVISTutorial.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 13/07/2014.
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

#import "PVVISTutorial.h"
#import "PVVISTutorialView.h"

@interface PVVISTutorial ()

@property NSArray *data;
@property UIView *superview;
@property NSUInteger index;
@property NSString *name;
@property PVVISTutorialView *tutorialView;

- (void)presentTutorialView:(void (^)(NSString *name))callback;

@end

@implementation PVVISTutorial

- (id)initWithName:(NSString *)name inSuperView:(UIView *)view;
{
    self = [super init];
    if (self)
    {
        self.name = name;
        self.data = [PVVISTutorial dataForTutorialNamed:name];
        self.superview = view;
        self.index = 0;
    }
    
    return self;
}

- (void)begin:(void (^)(NSString *name))completed
{
    [self presentTutorialView:completed];
}

- (void)presentTutorialView:(void (^)(NSString *name))callback
{
    NSUInteger max = self.data.count;
    if (self.index < max)
    {
        NSDictionary *data = [self.data objectAtIndex:self.index];
        if (data)
        {
            self.tutorialView = [PVVISTutorialView tutorialViewForSize:CGSizeMake([[data objectForKey:@"width"] doubleValue], [[data objectForKey:@"height"] doubleValue]) withOffset:CGPointMake([[data objectForKey:@"x"] doubleValue], [[data objectForKey:@"y"] doubleValue]) title:[data objectForKey:@"title"] description:[data objectForKey:@"description"] callback:^{
                self.index++;
                [self.tutorialView removeFromSuperview];
                [self presentTutorialView:callback];
            }];
            
            [self.superview addSubview:self.tutorialView];
            return;
        }
    }
    
    callback(self.name);
}

+ (NSArray *)dataForTutorialNamed:(NSString *)name
{
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
    return (NSArray *)[[config objectForKey:@"tutorial"] objectForKey:name];
}

@end
