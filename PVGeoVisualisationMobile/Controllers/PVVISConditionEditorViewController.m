//
//  PVVISNumberValuePickerControllerViewController.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 08/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISConditionEditorViewController.h"
#import "PVVISConditionPickerTableViewCell.h"

@interface PVVISConditionEditorViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

- (void)addGestureRecogniser:(UIBarButtonItem*)item;
- (void)closeNumberValuePicker:(UITapGestureRecognizer *)sender;

@end

@implementation PVVISConditionEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setCondition:[PVVISCondition new]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self addGestureRecogniser:self.cancelButton];
    [self addGestureRecogniser:self.doneButton];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"PVVISConditionPickerTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"cell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString *property = self.condition.property;
    self.label.text = property.length > 0 ? self.condition.property : @"property";
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.condition.op inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.valueField.text = [self.condition.value stringValue];
    
    [self.valueField becomeFirstResponder];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addGestureRecogniser:(UIBarButtonItem*)item
{
    UITapGestureRecognizer *tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeNumberValuePicker:)];
    tapGestureRecogniser.numberOfTapsRequired = 1;
    [[item valueForKey:@"view"] addGestureRecognizer:tapGestureRecogniser];
}

- (void)closeNumberValuePicker:(UITapGestureRecognizer *)sender
{
    if (self.callback && sender.view == [self.doneButton valueForKey:@"view"]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.valueField.text];
        double number;
        if ([scanner scanDouble:&number])
        {
            self.condition.value = [NSNumber numberWithDouble:number];
            self.callback(self.condition);
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid value"
                                                            message:@"The input value is not a number!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.callback = nil;
}

#pragma mark - table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PVVISConditionPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    [cell setCellValue:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.condition.op = indexPath.row;
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.valueField becomeFirstResponder];
}

@end
