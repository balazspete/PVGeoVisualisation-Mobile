//
//  PVVISTutorialView.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 12/07/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVVISTutorialView : UIView

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *labelBox;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textBox;
@property (weak, nonatomic) IBOutlet UIButton *proceedButton;

+ (PVVISTutorialView *)tutorialViewForSize:(CGSize)size withOffset:(CGPoint)offset title:(NSString *)title description:(NSString *)description callback:(void (^)(void))callback;

@end
