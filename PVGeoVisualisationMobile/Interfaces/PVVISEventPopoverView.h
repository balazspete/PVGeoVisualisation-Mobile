//
//  PVVISEventView.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PVVISEventPopoverView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
