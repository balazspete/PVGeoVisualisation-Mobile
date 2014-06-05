//
//  PVVISEventViewPopoverController.h
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVVISEvent.h"
#import "PVVISEventPopoverView.h"

typedef void(^ActionCallback)(NSString* action, id data);

@interface PVVISEventPopoverViewController : UITableViewController

@property PVVISEventPopoverView *eventView;

@property (nonatomic, copy) ActionCallback actionCallback;

- (id)initWithEvent:(PVVISEvent*)event;

- (void)resizeContents;

@end
