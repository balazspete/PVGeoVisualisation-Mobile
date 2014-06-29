//
//  PVVISCondition.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVVISCondition : NSObject

@property NSString *property;
@property NSInteger op;
@property NSNumber *value;

+ (PVVISCondition *)conditionWithProperty:(NSString*)property opeartion:(NSInteger)op value:(NSNumber*)value;
+ (NSString *)operatorToString:(NSInteger)op;
+ (NSString *)operatorToSymbol:(NSInteger)op;

- (NSString*)humanDescription;

@end
