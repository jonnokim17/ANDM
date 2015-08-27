//
//  FeatureBaseViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "FeatureBaseViewController.h"
#import "ANDMLoginViewController.h"
#import "ANDMSignUpViewController.h"
#import "UIAlertController+Window.h"
#import "SWRevealViewController.h"
#import "Page.h"
#import "MainFeedTableViewCell.h"
#import "ANDMDetailViewController.h"
#import "NSDate+TimeAgo.h"

@interface FeatureBaseViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ANDMLoginViewController *ANDMLoginViewController;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation FeatureBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"cell";

    MainFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[MainFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // Configure the cell
    NSString *eventName = [object objectForKey:@"pageName"];
    cell.eventTitleLabel.text = eventName;

    PFFile *eventImageFile = [object objectForKey:@"image"];
    if (eventImageFile) {
        cell.eventImage.file = eventImageFile;
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.eventImage loadInBackground];
        });
    } else {
        NSLog(@"ERROR");
    }

    NSString *hashtag = [object objectForKey:@"hashtag"];
    NSMutableString *hashtagString = [NSMutableString stringWithString:hashtag];

    [hashtagString insertString:@"#" atIndex:0];

    cell.hashtagLabel.text = hashtagString;

    NSDate *eventDate = [object objectForKey:@"date"];
    cell.dateUntilNowLabel.text = [eventDate dateTimeUntilNow];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = self.objects[indexPath.row];

        ANDMDetailViewController *detailVC = segue.destinationViewController;
        detailVC.selectedPage = (Page *)object;
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
        [logInViewController setFields:PFLogInFieldsDefault];


        //Create the sign up view controller
        ANDMSignUpViewController *signUpViewController = [[ANDMSignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        [signUpViewController setFields:PFSignUpFieldsDefault];

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

@end
