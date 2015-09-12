//
//  ANDMFavoritesViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/27/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMFavoritesViewController.h"
#import <MapKit/MapKit.h>
#import "SWRevealViewController.h"
#import "FeatureBaseViewController.h"
#import "Favorite.h"
#import "Page.h"
#import "SVProgressHUD.h"
#import "ANDMDetailViewController.h"
#import "NSDate+TimeAgo.h"

@interface ANDMFavoritesViewController () <UITableViewDataSource, UITableViewDelegate, UIToolbarDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSArray *favoritesArray;

@property (strong, nonatomic) FeatureBaseViewController *mainFeedVC;


@end

@implementation ANDMFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainFeedVC = [storyboard instantiateViewControllerWithIdentifier:@"mainfeed"];

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    self.tableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self showLoadingIndicator];

    [Favorite fetchAllPagesForCurrentUserWithCompletion:^(NSArray *objects, NSError *error) {
        NSMutableArray *favoritePageIdsArray = [@[] mutableCopy];
        for (Favorite *favorite in objects) {
            [favoritePageIdsArray addObject:favorite.favoritedPage.objectId];
        }

        [Page getPagesWithObjectIds:favoritePageIdsArray andCompletion:^(NSArray *objects, NSError *error) {
            self.favoritesArray = objects;

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            });
        }];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.favoritesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Page *favoritedPage = self.favoritesArray[indexPath.row];

    cell.textLabel.text = favoritedPage.pageName;
    cell.detailTextLabel.text = [favoritedPage.date dateTimeUntilNow];

    //    [favoritedPage.image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
    //        cell.imageView.image = [UIImage imageWithData:data];
    //    }];

    return cell;
}

#pragma mark - Helpers
- (void)showLoadingIndicator
{
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor blueColor]];
    [SVProgressHUD show];
}

//- (void)configureSegmentedControl
//{
//    NSArray *itemArray = [NSArray arrayWithObjects: @"LIST", @"MAP", nil];
//    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:itemArray];
//    [control setFrame:CGRectMake(60.0, 0, 100.0, 40.0)];
//    [control addTarget:self action:@selector(segmentedControlHasChangedValue:) forControlEvents:UIControlEventValueChanged];
//    [control setSelectedSegmentIndex:0];
//    [control setEnabled:YES];
//    self.tableView.tableHeaderView = control;
//}

//- (void)segmentedControlHasChangedValue:(id)sender
//{
//    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
//
//    if (segmentedControl.selectedSegmentIndex == 0) {
//        //
//    } else if (segmentedControl.selectedSegmentIndex == 1) {
//        //
//    }
//}

#pragma Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"favoriteSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Page *selectedFavoritedPage = self.favoritesArray[indexPath.row];

        ANDMDetailViewController *detailVC = segue.destinationViewController;
        detailVC.selectedPage = selectedFavoritedPage;
    }
}

#pragma mark - UIToolbarDelegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - MKMapViewDelegate
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D center = [view.annotation coordinate];
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = 0.01;
    coordinateSpan.longitudeDelta = 0.01;
    MKCoordinateRegion coordiateRegion = MKCoordinateRegionMake(center, coordinateSpan);
    [self.mapView setRegion:coordiateRegion animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}

#pragma mark - IBActions
- (IBAction)onSegmentedControl:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            NSLog(@"first index");
            self.tableView.hidden = NO;
            self.secondView.hidden = YES;
            break;

        case 1:
            NSLog(@"second index");
            self.tableView.hidden = YES;
            self.secondView.hidden = NO;

            for (Page *page in self.favoritesArray) {
                CLLocationCoordinate2D eventCoordinate = CLLocationCoordinate2DMake(page.location.latitude, page.location.longitude);
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = eventCoordinate;
                annotation.title = page.pageName;
                [self.mapView addAnnotation:annotation];
            }

            break;

        default:
            break;
    }
}

@end
