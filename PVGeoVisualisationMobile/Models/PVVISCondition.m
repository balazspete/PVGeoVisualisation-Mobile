//
//  PVVISCondition.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISCondition.h"

@interface PVVISCondition ()

- (NSString *)operatorToString;
- (NSString *)operatorToStringOp;

@end

@implementation PVVISCondition

+ (PVVISCondition *)conditionWithProperty:(NSString*)property opeartion:(NSInteger)op value:(NSNumber*)value
{
    PVVISCondition *condition = [PVVISCondition new];
    condition.property = property;
    condition.op = op;
    condition.value = value;
    return condition;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.property, [self operatorToStringOp], [self.value stringValue]];
}

- (NSString*)humanDescription
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.property, [PVVISCondition operatorToSymbol:self.op], [self.value stringValue]];
}

- (NSString *)operatorToStringOp
{
    switch (self.op) {
        case 1:
            return @"<=";
        case 2:
            return @"==";
        case 3:
            return @">=";
        case 4:
            return @">";
        default:
            return @"<";
    }
}

+ (NSString *)operatorToString:(NSInteger)op
{
    switch (op) {
        case 1:
            return @"less than or equal to";
        case 2:
            return @"equal to";
        case 3:
            return @"greater than or equal to";
        case 4:
            return @"greater than";
        default:
            return @"less than";
    }
}

+ (NSString *)operatorToSymbol:(NSInteger)op
{
    switch (op) {
        case 1:
            return @"≤";
        case 2:
            return @"=";
        case 3:
            return @"≥";
        case 4:
            return @">";
        default:
            return @"<";
    }
}

@end
