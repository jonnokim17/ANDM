//
//  FeatureBaseViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "FeatureBaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ANDMLoginViewController.h"
#import "ANDMSignUpViewController.h"
#import "UIAlertController+Window.h"
#import "SWRevealViewController.h"
#import "Page.h"
#import "MainFeedTableViewCell.h"
#import "ANDMDetailViewController.h"
#import "NSDate+TimeAgo.h"
#import "ANDMViewController.h"

@interface FeatureBaseViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, ANDMViewControllerDelegate>
{
    CLLocation *currentLocation;
}

@property (nonatomic, strong) ANDMLoginViewController *ANDMLoginViewController;
@property CLLocationManager *locationManager;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *sidebarButton;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *filteredArray;
@property (nonatomic) BOOL shouldShowSearchResults;

@property (nonatomic) CLLocationCoordinate2D currentLocationCoordinate;
@property (nonatomic, strong) PFGeoPoint *currentGeoPoint;

@property (nonatomic, strong) ANDMViewController *ANDMSearchController;

@end

@implementation FeatureBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldShowSearchResults = NO;

    [self configureSearchController];

//    self.locationManager = [[CLLocationManager alloc] init];
//    [self.locationManager requestWhenInUseAuthorization];
//    self.locationManager.delegate = self;
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//
//    [self.locationManager startUpdatingLocation];
//
//    CLLocation *location = [self.locationManager location];
//
//    self.currentLocationCoordinate = [location coordinate];
//    self.currentGeoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocationCoordinate.latitude longitude:self.currentLocationCoordinate.longitude];

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self manageLogin];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [self.locationManager startUpdatingLocation];

    CLLocation *location = [self.locationManager location];

    self.currentLocationCoordinate = [location coordinate];
    self.currentGeoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocationCoordinate.latitude longitude:self.currentLocationCoordinate.longitude];

    self.shouldShowSearchResults = NO;
    [self.tableView reloadData];
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Page";

        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"pageName";

        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        self.imageKey = @"image";

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;

        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query orderByDescending:@"postsHr"];

    return query;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"cell";

    MainFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[MainFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (self.shouldShowSearchResults) {

        if (self.filteredArray.count > 0) {
            Page *page = self.filteredArray[indexPath.row];
            [self loadTableViewCells:cell withPage:page];
        }

    } else {
        Page *page = self.objects[indexPath.row];
        [self loadTableViewCells:cell withPage:page];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.shouldShowSearchResults) {
        return self.filteredArray.count;
    } else {
        return [self.objects count];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        if (!self.shouldShowSearchResults) {
            PFObject *object = self.objects[indexPath.row];
            ANDMDetailViewController *detailVC = segue.destinationViewController;
            detailVC.selectedPage = (Page *)object;
        } else {
            PFObject *object = self.filteredArray[indexPath.row];
            ANDMDetailViewController *detailVC = segue.destinationViewController;
            detailVC.selectedPage = (Page *)object;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)manageLogin
{
    if (![PFUser currentUser]) {

        //Create the log in view controller
        ANDMLoginViewController *logInViewController = [[ANDMLoginViewController alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ANDM_login"]]];

        //Create the sign up view controller
        ANDMSignUpViewController *signUpViewController = [[ANDMSignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        [signUpViewController setFields:PFSignUpFieldsDefault];
        [signUpViewController.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ANDM_login"]]];

        //Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];

        //Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:nil];
    }
}

#pragma mark - PFLogInViewControllerDelegate
-(BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length != 0 && password.length != 0) {
        //Begin login process
        return YES;
    }

    [self invalidLoginSignupAlertWithTitle:@"Missing Information" andWithMessage:@"Please enter all required fields"];

    return NO;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PFSignUpViewControllerDelegate
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;

    //Loop through all submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0)
        {
            informationComplete = NO;
        }
    }

    if (!informationComplete) {
        [self invalidLoginSignupAlertWithTitle:@"Incorrect Information" andWithMessage:@"Make sure information is entered correctly"];
    }

    return informationComplete;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers
- (void)invalidLoginSignupAlertWithTitle:(NSString *)title andWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    
    [alert show];
}

- (void)loadTableViewCells:(MainFeedTableViewCell *)cell withPage:(Page *)page
{
    cell.eventTitleLabel.text = page.pageName;

    PFFile *eventImageFile = page.image;
    if (eventImageFile) {
        cell.eventImage.file = eventImageFile;
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.eventImage loadInBackground];
        });
    } else {
        NSLog(@"ERROR");
    }

    NSString *hashtag = page.hashtag;
    NSMutableString *hashtagString = [NSMutableString stringWithString:hashtag];

    [hashtagString insertString:@"#" atIndex:0];

    cell.hashtagLabel.text = hashtagString;

    NSDate *eventDate = page.date;
    cell.dateUntilNowLabel.text = [eventDate dateTimeUntilNow];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy hh:mm a"];
    NSString *startDate = [dateFormat stringFromDate:page.date];
    NSString *endDate = [dateFormat stringFromDate:page.endDate];

    cell.eventDurationLabel.text = [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
}

#pragma mark - ANDMViewControllerDelegate
- (void)didStartSearching
{
    self.shouldShowSearchResults = YES;
    [self.tableView reloadData];
}

- (void)didTapOnSearchButton
{
    if (!self.shouldShowSearchResults) {
        self.shouldShowSearchResults = YES;
        [self.tableView reloadData];
    }

    [self.searchController.searchBar resignFirstResponder];
    [self.searchController setActive:NO];

}

- (void)didTapOnCancelButton
{
    self.shouldShowSearchResults = NO;
    [self.tableView reloadData];

}

- (void)didChangeSearchText:(NSString *)searchText
{
    NSMutableArray *temporaryFilteredArray = [@[] mutableCopy];

    if (searchText > 0) {
        PFQuery *query = [Page query];
        [query whereKey:@"pageName" containsString:searchText];
        [query whereKey:@"location" nearGeoPoint:self.currentGeoPoint withinMiles:20];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [temporaryFilteredArray addObjectsFromArray:objects];
            [self.tableView reloadData];
        }];

        self.filteredArray = temporaryFilteredArray;
        [self.tableView reloadData];
    }
}

- (void)configureSearchController
{
    self.ANDMSearchController = [[ANDMViewController alloc] initWithResultsController:self searchBarFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 50.0) searchBarFont:[UIFont fontWithName:@"Futura" size:16.0] searchBarTextColor:[UIColor orangeColor] andSearchBarTintColor:[UIColor blackColor]];

    self.ANDMSearchController.ANDMSearchBar.placeholder = @"Search here";
    self.ANDMSearchController.customDelegate = self;
    self.tableView.tableHeaderView = self.ANDMSearchController.ANDMSearchBar;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    currentLocation = [locations objectAtIndex:0];
    [self.locationManager stopUpdatingLocation];
}

@end
