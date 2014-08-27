//
//  PVVISTutorialView.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 12/07/2014.
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

#import "PVVISTutorialView.h"

@interface PVVISTutorialView ()

@end

@implementation PVVISTutorialView

static void (^_callback)(void);

+ (PVVISTutorialView *)tutorialViewForSize:(CGSize)size withOffset:(CGPoint)offset title:(NSString *)title description:(NSString *)description callback:(void (^)(void))callback
{
    PVVISTutorialView *tutorialView = (PVVISTutorialView *)[[[NSBundle mainBundle] loadNibNamed:@"PVVISTutorialView" owner:self options:nil] objectAtIndex:0];
    
    NSInteger top = offset.y - 15;
    [tutorialView addConstraint:[NSLayoutConstraint constraintWithItem:tutorialView.centerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:tutorialView attribute:NSLayoutAttributeTop multiplier:0 constant:(top)]];
    [tutorialView addConstraint:[NSLayoutConstraint constraintWithItem:tutorialView.centerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:tutorialView attribute:NSLayoutAttributeLeading multiplier:0 constant:(offset.x - 15)]];

    NSInteger height = size.height + 30;
    [tutorialView addConstraint:[NSLayoutConstraint constraintWithItem:tutorialView.centerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:tutorialView attribute:NSLayoutAttributeWidth multiplier:0 constant:(size.width + 30)]];
    [tutorialView addConstraint:[NSLayoutConstraint constraintWithItem:tutorialView.centerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:tutorialView attribute:NSLayoutAttributeHeight multiplier:0 constant:height]];

    NSInteger labelTop = 100;
    if (top+height < 500)
    {
        labelTop = top+height + CGRectGetHeight(tutorialView.centerView.frame);
    }
    else if (top + height == 965)
    {
        tutorialView.labelBox.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
        tutorialView.labelBox.layer.cornerRadius = 10;
    }

    [tutorialView addConstraint:[NSLayoutConstraint constraintWithItem:tutorialView.labelBox attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:tutorialView attribute:NSLayoutAttributeTop multiplier:0 constant:labelTop]];
    
    tutorialView.titleLabel.text = title;
    tutorialView.textBox.text = description;
    
    [tutorialView.centerView addGestureRecognizer:[PVVISTutorialView gestureRecogniserForView:tutorialView]];
    [tutorialView.proceedButton addGestureRecognizer:[PVVISTutorialView gestureRecogniserForView:tutorialView]];
    
    tutorialView.proceedButton.layer.cornerRadius = 10;
    
    _callback = callback;
    
    return tutorialView;
}

+ (UITapGestureRecognizer *)gestureRecogniserForView:(UIView *)view
{
    UITapGestureRecognizer *tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(clickedCenterView:)];
    tapGestureRecogniser.numberOfTapsRequired = 1;
    return tapGestureRecogniser;
}

- (void)clickedCenterView:(UITapGestureRecognizer *)sender
{
    _callback();
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
