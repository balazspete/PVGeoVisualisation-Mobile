//
//  PVVISTutorial.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 13/07/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
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
