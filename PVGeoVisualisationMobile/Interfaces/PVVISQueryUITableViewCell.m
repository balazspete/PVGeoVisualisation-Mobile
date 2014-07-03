//
//  PVVISQueryUITableViewCell.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 05/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISQueryUITableViewCell.h"
#import "UIColor+PVVISColorSet.h"

@implementation PVVISQueryUITableViewCell

@synthesize backgroundView = _backgroundView;

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
    self.cellBackgroundView.backgroundColor = [UIColor labelColor];
    self.separator.backgroundColor = [UIColor whiteColor];
    self.clearButton.imageView.image = [UIImage imageNamed:@"closeWhite"];
    self.selectedTextLabel.textColor = [UIColor whiteColor];
}

- (void)cellDeselected
{
    self.counterLabel.textColor = [UIColor labelColor];
    self.label.textColor = [UIColor darkGrayColor];
    self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
    self.separator.backgroundColor = [UIColor lightGrayColor];
    self.clearButton.imageView.image = [UIImage imageNamed:@"close"];
    self.selectedTextLabel.textColor = [UIColor lightGrayColor];
}

@end
