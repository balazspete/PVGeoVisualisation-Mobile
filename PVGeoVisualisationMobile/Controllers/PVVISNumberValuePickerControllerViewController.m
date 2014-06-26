//
//  PVVISNumberValuePickerControllerViewController.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 08/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISNumberValuePickerControllerViewController.h"

@interface PVVISNumberValuePickerControllerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property NSMutableArray *numbers;

- (void)addGestureRecogniser:(UIBarButtonItem*)item;
- (void)closeNumberValuePicker:(UITapGestureRecognizer *)sender;


@end

@implementation PVVISNumberValuePickerControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.numbers = [NSMutableArray arrayWithArray:@[@0, @0, @0, @0]];
        [self setValue:@0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.chooser.delegate = self;
    self.chooser.dataSource = self;
    
    [self addGestureRecogniser:self.cancelButton];
    [self addGestureRecogniser:self.doneButton];
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
        self.callback(self.value);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.callback = nil;
}

- (NSNumber *)value
{
    double num = 0;
    for (int i = 0; i < 4; i++)
    {
        
        double k = pow(10, i);
        double n = [[self.numbers objectAtIndex:i] floatValue] * k;
        num += n;
    }
    
    return [NSNumber numberWithDouble:num];
}


- (void)setValue:(NSNumber *)value
{
    long _value = [value integerValue];
    for (int i = 0; i < 4; i++)
    {
        long p = pow(10, i + 1);
        float v = _value % p;
        _value -= v;
        
        long _v = v/(p/10);
        NSNumber *num = [NSNumber numberWithLong:_v];
        [self.numbers replaceObjectAtIndex:i withObject:num];
        [self.chooser selectRow:[num integerValue] inComponent:(3-i) animated:YES];
    }
}

#pragma mark - picker view data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

#pragma mark - picker view delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.numbers replaceObjectAtIndex:(3-component) withObject:[NSNumber numberWithInteger:row]];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%lu", row];
}

@end
