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
#import "PVVISConditionEditorViewController.h"
#import "PVVISArea.h"
#import "PVVISPolygon.h"

#import "UIImage+StackBlur.h"
#import "UIColor+PVVISColorSet.h"

#import <QuartzCore/QuartzCore.h>

@interface PVVISQueryViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate, GMSMapViewDelegate>

@property BOOL initial;

@property PVVISDataStore *dataStore;

@property PVVISMapViewController *mapViewController;

@property NSArray *queryParameters;

@property NSDictionary *currentProperty;
@property PVVISConditionEditorViewController *picker;
@property NSMutableArray *areas;

- (void)presentMap:(BOOL)runQuery;
- (void)presentPropertySelectionForIndex:(NSInteger)index;

- (void)registerCollectionViewReusableCells;
- (void)registerTableViewReusableCells;

- (void)setPolygonsInMap:(PVVISArea *)area isCellSelected:(BOOL)selected;

@end

@implementation PVVISQueryViewController

static PVVISQueryUICollectionViewCell *_sizingCell;
static NSString *_dataSetReloadWarningAlertTitle, *_queryResetWarningAlertTitle;
static NSIndexPath *_currentIndexPath;

- (id)init
{
    return [self initWithNibName:@"PVVISQueryViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    _dataSetReloadWarningAlertTitle = @"Reloading data set";
    _queryResetWarningAlertTitle = @"New query";
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.initial = YES;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        
        self.dataStore = ((PVVISAppDelegate*)[[UIApplication sharedApplication] delegate]).dataStore;
        self.queryParameters = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FilterUIConfiguration" ofType:@"plist"]] objectForKey:@"UI"];
        
        self.picker = [[PVVISConditionEditorViewController alloc] initWithNibName:@"PVVISConditionEditorViewController" bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.mapView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsMultipleSelection = YES;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *search = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayMap:)];
    [self.searchButton addGestureRecognizer:search];
    
    UITapGestureRecognizer *back = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayMap:)];
    [self.backButton addGestureRecognizer:back];
    
    UITapGestureRecognizer *reset = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetQuery:)];
    [self.resetButton addGestureRecognizer:reset];
    
    UITapGestureRecognizer *reload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDataSetReloadWarning:)];
    [self.reloadButton addGestureRecognizer:reload];
    
    self.loadingView.hidden = YES;
    
    self.dataSetLoadingView = [[[NSBundle mainBundle] loadNibNamed:@"PVVISDataSetLoadingView" owner:self options:nil] objectAtIndex:0];
    [self.view addSubview:self.dataSetLoadingView];
    self.dataSetLoadingView.hidden = YES;
    
    self.toolbar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.toolbar.layer.borderWidth = 0.7f;
    self.toolbar.layer.cornerRadius = 5;
    
    self.mapViewShown = [NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mapView attribute:NSLayoutAttributeWidth multiplier:0 constant:455];
    self.mapViewHidden = [NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mapView attribute:NSLayoutAttributeWidth multiplier:0 constant:0];
    self.mapViewContainer.hidden = YES;
    
    self.mapView.myLocationEnabled = NO;
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.rotateGestures = NO;
    
    self.mapView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.mapView.layer.borderWidth = 0.7f;
    
    self.dataStore.query = [PVVISQuery new];
    
    [self registerCollectionViewReusableCells];
    [self registerTableViewReusableCells];
}

- (void)displayMap:(UITapGestureRecognizer*)sender
{
    [self presentMap:(sender.view == self.searchButton)];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
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
        self.mapView.delegate = self;
        
        self.mapViewController = [[PVVISMapViewController alloc] init];
        self.mapViewController.mapImage = self.backgroundImageView;
        self.initial = NO;
        [self presentMap:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentMap:(BOOL)runQuery
{
    self.mapViewController.runQuery = runQuery;
    [self presentViewController:self.mapViewController animated:NO completion:^{
        NSLog(@"Map presented");
    }];
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:_dataSetReloadWarningAlertTitle])
    {
        if (buttonIndex == 1)
        {
            self.dataSetLoadingView.hidden = NO;
            [self.dataStore reloadDataStore:^(bool success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success)
                    {
                        self.dataSetLoadingView.hidden = YES;
                        [self runQuickQuery];
                    }
                });
            }];
        }
    }
    else if ([alertView.title isEqualToString:_queryResetWarningAlertTitle])
    {
        if (buttonIndex == 1)
        {
            self.dataStore.query = [PVVISQuery new];
            [self.collectionView reloadData];
            [self.tableView reloadData];
            [self.tableView selectRowAtIndexPath:_currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
            [self runQuickQuery];
        }
    }
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self presentPropertySelectionForIndex:indexPath.row];
    _currentIndexPath = indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.queryParameters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PVVISQueryUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewLabelWithSubtext"];
    cell.indexPath = indexPath;
    
    NSDictionary *entry = [self.queryParameters objectAtIndex:indexPath.row];
    cell.key = [entry objectForKey:@"id"];
    
    cell.label.text = [entry objectForKey:@"name"];
    
    NSString *hint = [entry objectForKey:@"hint"];
    cell.selectedTextLabel.text = hint;
    
    id data = [self.dataStore.query getDataForKey:[entry objectForKey:@"id"]];
    if ([data isKindOfClass:[NSMutableArray class]])
    {
        NSUInteger count = ((NSArray*)data).count;
        cell.counterLabel.text = count == 0 ? @"none" : [NSString stringWithFormat:@"%lu", count];
    }
    else
    {
        cell.counterLabel.text = @"?";
    }
    
    cell.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *clear = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearSection:)];
    [cell.clearButton addGestureRecognizer:clear];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.currentProperty objectForKey:@"restricted"])
    {
        PVVISQueryUICollectionViewCell *cell = (PVVISQueryUICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [self performSelector:@selector(showConditionEditor:) withObject:cell];
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
        BOOL result = [self.dataStore.query performSelector:selector withObject:cell.data];
#pragma clang diagnostic pop
        if (result)
        {
            [collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor labelColor];
            [self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.tableView selectRowAtIndexPath:_currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
            
            if ([cell.data isKindOfClass:[PVVISArea class]])
            {
                [self setPolygonsInMap:[self.areas objectAtIndex:indexPath.row] isCellSelected:YES];
            }
        }
        else
        {
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
            [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
        }
        
        [self runQuickQuery];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.currentProperty objectForKey:@"type"] isEqualToString:@"tabbed"])
    {
        PVVISQueryUICollectionViewCell *cell = (PVVISQueryUICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [self performSelector:@selector(showConditionEditor:) withObject:cell];
        if (cell)
        {
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionTop];
        }
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
        [self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView selectRowAtIndexPath:_currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        if ([cell.data isKindOfClass:[PVVISArea class]])
        {
            [self setPolygonsInMap:[self.areas objectAtIndex:indexPath.row] isCellSelected:NO];
        }
        
        [self runQuickQuery];
    }
}

- (void)runQuickQuery
{
    self.loadingView.hidden = NO;
    [self.dataStore runQuery:YES withCallback:^(NSString *action, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultsCountLabel.text = [NSString stringWithFormat:@"%@", data];
            self.loadingView.hidden = YES;
        });
    }];
}

#pragma mark - collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *options = [self.currentProperty objectForKey:@"options"];
    if (options)
    {
        return options.count;
    }
    else
    {
        NSArray *data = [self.dataStore.query getDataForKey:[self.currentProperty objectForKey:@"id"]];
        return data.count+1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PVVISQueryUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewLabel" forIndexPath:indexPath];
    [self setCellValuesForCell:cell atIndexPath:indexPath withProperty:self.currentProperty];
    return cell;
}

- (void)createAddButton:(PVVISQueryUICollectionViewCell*)cell
{
    cell.label.text = @"➕";
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    cell.data = nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame)-20, 62);
}

- (void)setCellValuesForCell:(PVVISQueryUICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withProperty:(NSDictionary*)property
{
    BOOL selected = NO;
    
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
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
            
            [self setPolygonsInMap:[self.areas objectAtIndex:indexPath.row] isCellSelected:selected];
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
        NSArray *data = [self.dataStore.query getDataForKey:key];
        if (indexPath.row < data.count)
        {
            id value = [data objectAtIndex:indexPath.row];
            if ([value isKindOfClass:[PVVISCondition class]])
            {
                cell.label.text = [value humanDescription];
            }
            else
            {
                cell.label.text = [value description];
            }
            
            cell.data = value;
            
            selected = YES;
        }
        else
        {
            [self createAddButton:cell];
        }
    }
    
    cell.backgroundColor = selected ? [UIColor labelColor] : [UIColor whiteColor];
    cell.alpha = 0.8f;
    
    if (selected)
    {
        cell.highlighted = YES;
    }
}

- (void)setPolygonsInMap:(PVVISArea *)area isCellSelected:(BOOL)selected
{
    for (PVVISPolygon *polygon in area.polygons)
    {
        UIColor *selectedColor = selected ? [UIColor labelColor] : [UIColor lightGrayColor];
        polygon.fillColor = [selectedColor colorWithAlphaComponent:0.5f];
        polygon.strokeColor = selectedColor;
        polygon.strokeWidth = 2;
    }
    
    area.selected = selected;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (!self.currentProperty)
    {
        return 0;
    }
    
    return 1;
}

#pragma mark - collection view control

- (void)presentPropertySelectionForIndex:(NSInteger)index;
{
    self.currentProperty = [self.queryParameters objectAtIndex:index];
    
    if ([[self.currentProperty objectForKey:@"id"] isEqualToString:@"location"])
    {
        [self.mapView removeConstraint:self.mapViewHidden];
        [self.mapView addConstraint:self.mapViewShown];
        self.mapViewContainer.hidden = NO;
        
        [self resetMap];
    }
    else
    {
        [self.mapView removeConstraint:self.mapViewShown];
        [self.mapView addConstraint:self.mapViewHidden];
        self.mapViewContainer.hidden = YES;
    }
    
    [self.collectionView reloadData];
}

- (void)resetMap
{
    [self.mapView clear];
    self.areas = [NSMutableArray new];
    
    NSArray *data = [[self.queryParameters objectAtIndex:2] objectForKey:@"options"];
    for (NSDictionary *dict in data)
    {
        PVVISArea *area = [[PVVISArea alloc] initWithDictionary:dict];
        for (PVVISPolygon *polygon in area.polygons)
        {
            UIColor *selectedColor = NO ? [UIColor labelColor] : [UIColor lightGrayColor];
            polygon.fillColor = [selectedColor colorWithAlphaComponent:0.5f];
            polygon.strokeColor = selectedColor;
            polygon.strokeWidth = 2;
            
            polygon.tappable = YES;
            
            polygon.map = nil;
            polygon.map = self.mapView;
        }
        [self.areas addObject:area];
    }
    
    self.mapView.camera = [GMSCameraPosition cameraWithLatitude:40.487361 longitude:-93.129276 zoom:3];
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
                                                      
- (void)showConditionEditor:(PVVISQueryUICollectionViewCell *)cell
{
    NSArray *chunks = [cell.key componentsSeparatedByString:@"."];
    NSString *selectorName = [NSString stringWithFormat:@"remove%@:", [chunks[0] capitalizedString]];
    SEL selector = NSSelectorFromString(selectorName);
    
    
    PVVISCondition *condition = cell.data;
    if (!condition)
    {
        condition = [PVVISCondition conditionWithProperty:[_currentProperty objectForKey:@"id"] opeartion:0 value:nil];
    }
    
    self.picker.condition = condition;
    
    self.picker.callback = ^(PVVISCondition *condition)
    {
        NSString *selectorName = [NSString stringWithFormat:@"add%@:", [chunks[0] capitalizedString]];
        SEL selector = NSSelectorFromString(selectorName);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self runQuerySelector:selector withObject:condition];
#pragma clang diagnostic pop
        
        [self.collectionView reloadData];
        [self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView selectRowAtIndexPath:_currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        [self runQuickQuery];
        
    };
    
    [self presentViewController:self.picker animated:YES completion:^{
        if (condition)
        {
            [self runQuerySelector:selector withObject:condition];
            [self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        NSLog(@"Picker displayed");
    }];
}

- (void)runQuerySelector:(SEL)selector withObject:(id)object
{
    if ([self.dataStore.query respondsToSelector:selector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.dataStore.query performSelector:selector withObject:object];
#pragma clang diagnostic pop
        [self.collectionView reloadData];
    }
}

#pragma mark - clear section
- (void)clearSection:(UITapGestureRecognizer*)sender
{
    PVVISQueryUITableViewCell *cell = (PVVISQueryUITableViewCell *)sender.view.superview.superview.superview.superview;
    [self.dataStore.query reset:cell.key];
    [self.collectionView reloadData];
    [self.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    [self resetMap];
    [self runQuickQuery];
}

- (void)resetQuery:(UITapGestureRecognizer*)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_queryResetWarningAlertTitle
                                                    message:@"Are you sure you wish to reset the current query?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)showDataSetReloadWarning:(UITapGestureRecognizer*)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_dataSetReloadWarningAlertTitle
                                                    message:@"Are you sure you wish to reload the data set? You must be connected to the Internet!"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark - map view delegate

- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay
{
    PVVISArea *area = ((PVVISPolygon *)overlay).area;
    NSInteger index = [self.areas indexOfObject:area];
    
    NSArray *options = [self.currentProperty valueForKey:@"options"];
    NSDictionary *dictionary = [options objectAtIndex:index];
    PVVISArea *_area = [[PVVISArea alloc] initWithDictionary:dictionary];
    
    if (area.selected)
    {
        [self.dataStore.query removeLocation:_area];
    }
    else
    {
        [self.dataStore.query addLocation:_area];
    }
    
    [self.collectionView reloadData];
    [self.tableView reloadRowsAtIndexPaths:@[_currentIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView selectRowAtIndexPath:_currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self setPolygonsInMap:area isCellSelected:!area.selected];
    [self runQuickQuery];
}

@end
