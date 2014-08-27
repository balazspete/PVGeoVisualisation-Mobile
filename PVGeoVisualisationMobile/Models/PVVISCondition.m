//
//  PVVISCondition.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 27/06/2014.
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
