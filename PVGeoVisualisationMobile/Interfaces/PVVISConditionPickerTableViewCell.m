//
//  PVVISConditionPickerTableViewCell.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 28/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISConditionPickerTableViewCell.h"
#import "PVVISCondition.h"

@implementation PVVISConditionPickerTableViewCell

static UIColor *_labelColor;
static NSArray *_colorArray;

- (void)awakeFromNib
{
    // Initialization code
    _colorArray = @[@0.10f, @0.8f, @0.44f];
    _labelColor = [UIColor colorWithRed:[_colorArray[0] floatValue] green:[_colorArray[1] floatValue] blue:[_colorArray[2] floatValue] alpha:1.0f];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor clearColor];
    self.mainView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.mainView.layer.borderWidth = 0.7f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
    {
        self.conditionLabel.textColor = [UIColor whiteColor];
        self.symbolLabel.textColor = [UIColor whiteColor];
        self.mainView.backgroundColor = _labelColor;
    }
    else
    {
        self.conditionLabel.textColor = _labelColor;
        self.symbolLabel.textColor = _labelColor;
        self.mainView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setCellValue:(NSInteger)value
{
    self.conditionLabel.text = [PVVISCondition operatorToString:value];
    self.symbolLabel.text = [PVVISCondition operatorToSymbol:value];
}

@end
