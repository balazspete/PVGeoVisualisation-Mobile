//
//  PVVISEventViewPopoverController.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 02/06/2014.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Balázs Pete
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
        self.actions = @[@"show similar events"/*, @"find nearby events"*/];
        
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"PVVISEventPopoverView"
                                                          owner:self
                                                        options:nil];
        
        self.eventView = [nibViews objectAtIndex:0];
        self.eventView.dateLabel.text = [NSString stringWithFormat:@"%u", [event.date intValue]];
        self.eventView.descriptionText.text = event.descriptionText;
        
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
