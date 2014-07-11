//
//  PVVISNumberValuePickerControllerViewController.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 08/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVVISCondition.h"
#import "PVVISQueryViewController.h"

@interface PVVISConditionEditorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, copy) void(^callback)(PVVISCondition* condition);

@property PVVISCondition *condition;

@property PVVISQueryViewController *queryView;

@end
