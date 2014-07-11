//
//  PVVISConditionPickerTableViewCell.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 28/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISConditionPickerTableViewCell.h"
#import "PVVISCondition.h"

#import "UIColor+PVVISColorSet.h"

@implementation PVVISConditionPickerTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor clearColor];
    self.mainView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.mainView.layer.borderWidth = 0.7f;
    self.mainView.layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
    {
        self.conditionLabel.textColor = [UIColor whiteColor];
        self.symbolLabel.textColor = [UIColor whiteColor];
        self.mainView.backgroundColor = [UIColor labelColor];
    }
    else
    {
        self.conditionLabel.textColor = [UIColor labelColor];
        self.symbolLabel.textColor = [UIColor labelColor];
        self.mainView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setCellValue:(NSInteger)value
{
    self.conditionLabel.text = [PVVISCondition operatorToString:value];
    self.symbolLabel.text = [PVVISCondition operatorToSymbol:value];
}

@end
