//
//  PVVISQueryViewController.m
//  PVGeoVisualisationMobile
//
//  Created by Balázs Pete on 05/06/2014.
//  Copyright (c) 2014 Balázs Pete. All rights reserved.
//

#import "PVVISQueryViewController.h"
#import "PVVISAppDelegate.h"
#import "PVVISMapViewController.h"

#import "PVVISQueryUITableViewCell.h"
#import "PVVISQueryUICollectionViewCell.h"
#import "PVVISQueryUICollectionReusableView.h"
#import "PVVISNumberValuePickerControllerViewController.h"
#import "PVVISArea.h"

#import <QuartzCore/QuartzCore.h>

@interface PVVISQueryViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate>

@property BOOL initial;

@property PVVISDataStore *dataStore;

@property PVVISMapViewController *mapViewController;

@property NSArray *queryParameters;

@property NSDictionary *currentProperty;
@property PVVISNumberValuePickerControllerViewController *picker;

- (void)presentMap;
- (void)presentPropertySelectionForIndex:(NSInteger)index;

- (void)registerCollectionViewReusableCells;
- (void)registerTableViewReusableCells;

@end

@implementation PVVISQueryViewController

static UIColor *_labelColor;
static UIColor *_tableSelectionColor;
static PVVISQueryUICollectionViewCell *_sizingCell;

- (id)init
{
    return [self initWithNibName:@"PVVISQueryViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //46, 204, 113
    NSArray *colorArray = @[@0.10f, @0.8f, @0.44f];
    _labelColor = [UIColor colorWithRed:[colorArray[0] floatValue] green:[colorArray[1] floatValue] blue:[colorArray[2] floatValue] alpha:1.0f];
    _tableSelectionColor = [UIColor colorWithRed:[colorArray[0] floatValue] green:[colorArray[1] floatValue] blue:[colorArray[2] floatValue] alpha:0.25f];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.initial = YES;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        
        self.dataStore = ((PVVISAppDelegate*)[[UIApplication sharedApplication] delegate]).dataStore;
        self.queryParameters = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FilterUIConfiguration" ofType:@"plist"]] objectForKey:@"UI"];
        
        self.picker = [[PVVISNumberValuePickerControllerViewController alloc] initWithNibName:@"PVVISNumberValuePickerControllerViewController" bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsMultipleSelection = YES;
    
    UITapGestureRecognizer *search = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayMap:)];
    [[self.searchButton valueForKey:@"view"] addGestureRecognizer:search];
    
    UITapGestureRecognizer *reset = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetQuery:)];
    [[self.resetButton valueForKey:@"view"] addGestureRecognizer:reset];
    
    [self registerCollectionViewReusableCells];
    [self registerTableViewReusableCells];
}
                                       
- (void)displayMap:(UITapGestureRecognizer*)sender
{
    [self presentMap];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)registerCollectionViewReusableCells
{
    UINib *cellNib = [UINib nibWithNibName:@"PVVISQueryUICollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"CollectionViewLabel"];
    _sizingCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    
    cellNib = [UINib nibWithNibName:@"PVVISQueryUICollectionFooter" bundle:nil];
    [self.collectionView registerNib:cellNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionView"];
    
    cellNib = [UINib nibWithNibName:@"PVVISQueryUICollectionFooter" bundle:nil];
    [self.collectionView registerNib:cellNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Blank"];
    
    cellNib = [UINib nibWithNibName:@"PVVISQueryUICollectionHeader" bundle:nil];
    [self.collectionView registerNib:cellNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionView"];
}

- (void)registerTableViewReusableCells
{
    UINib *cellNib = [UINib nibWithNibName:@"PVVISQueryUITableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"TableViewLabelWithSubtext"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.initial)
    {
        self.mapViewController = [[PVVISMapViewController alloc] init];
        self.initial = NO;
        [self presentMap];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentMap
{
    [self presentViewController:self.mapViewController animated:YES completion:^{
        NSLog(@"MAP PRESENTED");
    }];
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self.dataStore reloadDataStore];
    }
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [self presentPropertySelectionForIndex:indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reloading data set"
                                                            message:@"Are you sure you wish to reload the data set? You must be connected to the Internet!"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
            [alert show];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.queryParameters.count;
    }
    else if (section == 1)
    {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PVVISQueryUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewLabelWithSubtext"];
    
    if (indexPath.section == 0)
    {
        NSDictionary *entry = [self.queryParameters objectAtIndex:indexPath.row];
        cell.label.text = [entry objectForKey:@"name"];
        
        NSString *hint = [entry objectForKey:@"hint"];
        cell.subLabel.text = hint? hint : @"";
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.label.text = @"Reload data set";
            cell.subLabel.text = @"Delete and load the latest version";
        }
    }
    
    UIView *selectionColor = [UIView new];
    selectionColor.backgroundColor = _tableSelectionColor;
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Properties";
    }
    else if (section == 1)
    {
        return @"Preferences";
    }
    
    return nil;
}

#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.currentProperty objectForKey:@"type"] isEqualToString:@"tabbed"])
    {
        PVVISQueryUICollectionViewCell *cell = (PVVISQueryUICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [self performSelector:@selector(showNumberPicker:) withObject:cell];
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
    
    NSArray *key = [[self.currentProperty objectForKey:@"id"] componentsSeparatedByString:@"."];
    NSString *selectorName = [NSString stringWithFormat:@"add%@:", [key[0] capitalizedString]];
    SEL selector = NSSelectorFromString(selectorName);

    if ([self.dataStore.query respondsToSelector:selector])
    {
        PVVISQueryUICollectionViewCell *cell = (PVVISQueryUICollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.dataStore.query performSelector:selector withObject:cell.data];
#pragma clang diagnostic pop
        [collectionView cellForItemAtIndexPath:indexPath].backgroundColor = _labelColor;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.currentProperty objectForKey:@"type"] isEqualToString:@"tabbed"])
    {
        PVVISQueryUICollectionViewCell *cell = (PVVISQueryUICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [self performSelector:@selector(showNumberPicker:) withObject:cell];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionTop];
        return;
    }
    
    NSArray *key = [[self.currentProperty objectForKey:@"id"] componentsSeparatedByString:@"."];
    NSString *selectorName = [NSString stringWithFormat:@"remove%@:", [key[0] capitalizedString]];
    SEL selector = NSSelectorFromString(selectorName);
    
    if ([self.dataStore.query respondsToSelector:selector])
    {
        PVVISQueryUICollectionViewCell *cell = (PVVISQueryUICollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.dataStore.query performSelector:selector withObject:cell.data];
#pragma clang diagnostic pop
        [collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([[self.currentProperty objectForKey:@"type"] isEqualToString:@"tabbed"])
    {
        NSDictionary *dictionary = [[self.currentProperty objectForKey:@"tabs"] objectAtIndex:section];
        id value = [self.dataStore.query getDataForKey:[dictionary objectForKey:@"id"]];
        if ([value isKindOfClass:[NSArray class]])
        {
            return ((NSArray *)value).count +1;
        }
        
        return 1;
    }
    
    NSArray *options = [self.currentProperty objectForKey:@"options"];
    if ([self.currentProperty objectForKey:@"restricted"])
    {
        return options ? options.count : 0;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PVVISQueryUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewLabel" forIndexPath:indexPath];
    
    NSDictionary *property = self.currentProperty;
    if ([[property objectForKey:@"type"] isEqualToString:@"tabbed"])
    {
        property = [[property objectForKey:@"tabs"] objectAtIndex:indexPath.section];
    }
    
    [self setCellValuesForCell:cell atIndexPath:indexPath withProperty:property];
    return cell;
}

- (void)createAddButton:(PVVISQueryUICollectionViewCell*)cell
{
    cell.label.text = @"➕";
    cell.layer.borderColor = [UIColor grayColor].CGColor;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *type = [self.currentProperty objectForKey:@"type"];
    if ([type isEqualToString:@"selector"])
    {
        [self setCellValuesForCell:_sizingCell atIndexPath:indexPath withProperty:self.currentProperty];
    }
    else
    {
        _sizingCell.label.text = @"value";
    }
    
    return [_sizingCell intrinsicContentSize];
}

- (void)setCellValuesForCell:(PVVISQueryUICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withProperty:(NSDictionary*)property
{
    BOOL selected = NO;
    
    cell.layer.borderWidth = 1.7f;
    cell.layer.cornerRadius = 15.0f;
    cell.layer.borderColor = _labelColor.CGColor;
    
    NSString *key = [property objectForKey:@"id"];
    cell.key = key;
    
    NSArray *options = [property valueForKey:@"options"];
    if (options)
    {
        NSDictionary *dictionary = [options objectAtIndex:indexPath.row];
        cell.label.text = [dictionary objectForKey:@"label"];
        
        NSArray *data = [self.dataStore.query getDataForKey:key];
        
        if ([key isEqualToString:PVVISQueryKeyLocation])
        {
            PVVISArea *area = [[PVVISArea alloc] initWithDictionary:dictionary];
            cell.data = area;
            selected = [data containsObject:area];
        }
        else
        {
            PVVISTag *tag = [PVVISTag tagWithURIString:[dictionary objectForKey:@"value"]];
            cell.data = tag;
            selected = [data containsObject:tag];
        }
    }
    else
    {
        if (((BOOL)[property objectForKey:@"multiple"]) == YES)
        {
            NSArray *data = [self.dataStore.query getDataForKey:key];
            if (indexPath.row < data.count)
            {
                NSNumber *value = [data objectAtIndex:indexPath.row];
                cell.label.text = [value description];
                cell.data = value;
                
                selected = YES;
            }
            else
            {
                [self createAddButton:cell];
            }
        }
        else
        {
            NSNumber *value = [self.dataStore.query getDataForKey:key];
            if (value)
            {
                cell.label.text = [value description];
                cell.data = value;
                
                selected = YES;
            }
            else
            {
                [self createAddButton:cell];
            }
        }
    }
    
    cell.backgroundColor = selected ? _labelColor : [UIColor whiteColor];
    
    if (selected)
    {
        cell.highlighted = YES;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PVVISQueryUICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CollectionView" forIndexPath:indexPath];
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        if ([[self.currentProperty objectForKey:@"type"] isEqualToString:@"tabbed"])
        {
            return view;
        }
        else
        {
            view.textField.text = [self.currentProperty objectForKey:@"instruction"];
        }
    }
    else if (kind == UICollectionElementKindSectionHeader)
    {
        if ([[self.currentProperty objectForKey:@"type"] isEqualToString:@"tabbed"])
        {
            NSDictionary *property = [[self.currentProperty objectForKey:@"tabs"] objectAtIndex:indexPath.section];
            NSString *text = [property objectForKey:@"name"];
            view.textField.text = [text uppercaseString];
            view.key = [property objectForKey:@"id"];
        }
        else
        {
            view.textField.text = [[self.currentProperty objectForKey:@"name"] uppercaseString];
            view.key = [self.currentProperty objectForKey:@"id"];
        }
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearSection:)];
        [view.clearButton addGestureRecognizer:recognizer];
    }
    
    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (!self.currentProperty)
    {
        return 0;
    }
    
    if ([[self.currentProperty objectForKey:@"type"]  isEqualToString:@"tabbed"])
    {
        return ((NSArray*)[self.currentProperty objectForKey:@"tabs"]).count;
    }
    
    return 1;
}

#pragma mark - collection view control

- (void)presentPropertySelectionForIndex:(NSInteger)index;
{
    self.currentProperty = [self.queryParameters objectAtIndex:index];
    [self.collectionView reloadData];
}

#pragma mark - value chooser

- (void)removeValue:(UITapGestureRecognizer*)sender
{
    PVVISQueryUICollectionViewCell *cell = (PVVISQueryUICollectionViewCell*)sender.view;
    
    NSArray *key = [[self.currentProperty objectForKey:@"id"] componentsSeparatedByString:@"."];
    NSString *selectorName = [NSString stringWithFormat:@"remove%@:", [key[0] capitalizedString]];
    SEL selector = NSSelectorFromString(selectorName);
    
    if ([self.dataStore.query respondsToSelector:selector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.dataStore.query performSelector:selector withObject:cell.data];
#pragma clang diagnostic pop
        [self.collectionView reloadData];
    }
}
                                                      
- (void)showNumberPicker:(PVVISQueryUICollectionViewCell *)cell
{
    self.picker.label.text = cell.name;
    
    NSScanner *scanner = [NSScanner scannerWithString:cell.label.text];
    
    self.picker.callback = ^(NSNumber* number)
    {
        NSArray *chunks = [cell.key componentsSeparatedByString:@"."];
        NSString *selectorName;
        if (chunks.count == 2)
        {
            selectorName = [NSString stringWithFormat:@"add%@:", [chunks[0] capitalizedString]];
        }
        else if (chunks.count == 3)
        {
            selectorName = [NSString stringWithFormat:@"set%@%@:", [chunks[2] capitalizedString], [chunks[0] capitalizedString]];
        }
        
        SEL selector = NSSelectorFromString(selectorName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        if ([self.dataStore.query respondsToSelector:selector])
        {
#pragma clang diagnostic pop
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.dataStore.query performSelector:selector withObject:number];
#pragma clang diagnostic pop
            [self.collectionView reloadData];
        }
    };
    
    NSInteger number;
    if ([scanner scanInteger:&number])
    {
        [self.picker setValue:[NSNumber numberWithInteger:number]];
    }
    else
    {
        [self.picker setValue:@0];
    }
    
    [self presentViewController:self.picker animated:YES completion:^{
        NSLog(@"Back here 11");
    }];
}

#pragma mark - clear section
- (void)clearSection:(UITapGestureRecognizer*)sender
{
    PVVISQueryUICollectionReusableView *view = (PVVISQueryUICollectionReusableView *)sender.view.superview;
    [self.dataStore.query reset:view.key];
    [self.collectionView reloadData];
}

- (void)resetQuery:(UITapGestureRecognizer*)sender
{
    self.dataStore.query = [PVVISQuery new];
    [self.collectionView reloadData];
}

@end
