//
//  PVVISNumberValuePickerControllerViewController.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 08/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVVISNumberValuePickerControllerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UIPickerView *chooser;

@property NSNumber* value;
@property (nonatomic, copy) void(^callback)(NSNumber* number);

@end
