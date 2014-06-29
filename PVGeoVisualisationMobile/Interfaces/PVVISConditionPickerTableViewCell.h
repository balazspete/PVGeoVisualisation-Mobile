//
//  PVVISConditionPickerTableViewCell.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 28/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVVISConditionPickerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *conditionLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;

- (void)setCellValue:(NSInteger)value;

@end
