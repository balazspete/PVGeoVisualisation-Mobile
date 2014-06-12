//
//  PVVISQueryUICollectionReusableView.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 06/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVVISQueryUICollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@property NSString *key;

@end
