//
//  PVVISQueryUITableViewCell.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 05/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISQueryUITableViewCell.h"

@implementation PVVISQueryUITableViewCell

@synthesize backgroundView = _backgroundView;

static UIColor *_labelColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    NSArray *colorArray = @[@0.10f, @0.8f, @0.44f];
    _labelColor = [UIColor colorWithRed:[colorArray[0] floatValue] green:[colorArray[1] floatValue] blue:[colorArray[2] floatValue] alpha:1.0f];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    self.backgroundView = backView;
    
    self.cellBackgroundView.alpha = 0.8f;
    
    self.cellBackgroundView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.cellBackgroundView.layer.borderWidth = 0.7f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    if (selected)
    {
        [self cellSelected];
    }
    else
    {
        [self cellDeselected];
    }
}

- (void)cellSelected
{
    self.counterLabel.textColor = [UIColor whiteColor];
    self.label.textColor = [UIColor whiteColor];
    self.cellBackgroundView.backgroundColor = _labelColor;//[UIColor colorWithWhite:0.8f alpha:0.8f];
    self.separator.backgroundColor = [UIColor whiteColor];
    self.clearButton.imageView.image = [UIImage imageNamed:@"closeWhite"];
    self.selectedTextLabel.textColor = [UIColor whiteColor];
}

- (void)cellDeselected
{
    self.counterLabel.textColor = _labelColor;
    self.label.textColor = [UIColor darkGrayColor];
    self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
    self.separator.backgroundColor = [UIColor lightGrayColor];
    self.clearButton.imageView.image = [UIImage imageNamed:@"close"];
    self.selectedTextLabel.textColor = [UIColor lightGrayColor];
}

@end
