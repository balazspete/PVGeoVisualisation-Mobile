//
//  PVVISQueryUITableViewCell.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 05/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVVISQueryUITableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end
