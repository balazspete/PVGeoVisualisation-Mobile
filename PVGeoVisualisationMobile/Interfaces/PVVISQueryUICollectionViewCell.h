//
//  PVVISQueryUICollectionViewCell.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 05/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVVISQueryUICollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;

@property NSString *name;
@property id data;
@property NSString *key;

@end
