//
//  PVVISQueryUITableViewCell.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 05/06/2014.
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
