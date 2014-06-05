//
//  PVVISEventViewPopoverController.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISEventPopoverViewController.h"
#import "PVVISEventPopoverTableViewCell.h"

#import <QuartzCore/QuartzCore.h>

@interface PVVISEventPopoverViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property PVVISEvent *event;

@property NSArray *actions;

@end

@implementation PVVISEventPopoverViewController

- (id)initWithEvent:(PVVISEvent*)event
{
    self = [super init];
    if (self)
    {
        self.event = event;
        self.actions = @[@"view in browser", @"show similar events"];
        
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"PVVISEventPopoverView"
                                                          owner:self
                                                        options:nil];
        
        self.eventView = [nibViews objectAtIndex:0];
        self.eventView.dateLabel.text = [NSString stringWithFormat:@"%u", [event.date intValue]];
        self.eventView.descriptionText.text = event.description;
        
        self.view = self.eventView;
        
//        self.tableView = eventView.tableView;
        self.eventView.tableView.delegate = self;
        self.eventView.tableView.dataSource = self;
        
//        self.eventView.tableView.allowsSelection = NO;
        
        [self styleComponents];
        
    }
    
    return self;
}

- (void)resizeContents
{
    
}

- (void)styleComponents
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"PVVISEventPopoverTableViewCell"
                                                      owner:self
                                                    options:nil];
    PVVISEventPopoverTableViewCell *cell;

    if (indexPath.section == 0)
    {
        cell = [nibViews objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *selectorText = [self.event.details objectAtIndex:indexPath.row];
        SEL selector = NSSelectorFromString(selectorText);
        
        if ([self.event respondsToSelector:selector])
        {
            cell.subLabel.text = [selectorText capitalizedString];
            id value = [self.event performSelector:selector withObject:nil];
            
            if ([value isKindOfClass:[NSString class]])
            {
                cell.label.text = value;
            }
            else if ([value isKindOfClass:[NSNumber class]])
            {
                cell.label.text = [value stringValue];
            }
            else if ([value isKindOfClass:[PVVISTag class]])
            {
                cell.label.text = [((PVVISTag*)value) value];
            }
            else if ([value isKindOfClass:[PVVISLocation class]])
            {
                cell.label.text = [((PVVISLocation*)value) location];
            }
            else
            {
                cell.label.text = @"Unknown value";
                cell.label.textColor = [UIColor grayColor];
            }
        }
    }
    else if (indexPath.section == 1)
    {
        cell = [nibViews objectAtIndex:1];
        cell.label.text = [[self.actions objectAtIndex:indexPath.row] capitalizedString];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.event.details.count;
    }
    else if (section == 1)
    {
        return self.actions.count;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Details";
    }
    
    return @"Actions";
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 30;
    }
    
    return 40;
}

#pragma mark - row highlighting
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section != 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.actionCallback && indexPath.section == 1)
    {
        self.actionCallback([self.actions objectAtIndex:indexPath.row], self.event);
    }
}

@end
