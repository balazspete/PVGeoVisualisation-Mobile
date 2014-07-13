//
//  PVVISTutorial.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 13/07/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVVISTutorial : NSObject

- (id)initWithName:(NSString *)name inSuperView:(UIView *)view;
- (void)begin:(void (^)(NSString *name))completed;

@end
