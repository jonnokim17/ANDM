//
//  MainViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ANDMLoginViewController.h"
#import "ANDMSignUpViewController.h"
#import "UIAlertController+Window.h"
#import "SWRevealViewController.h"
#import "Page.h"

@interface MainViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ANDMLoginViewController *ANDMLoginViewController;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *pagesArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pagesArray = [@[] mutableCopy];

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    [Page getPagesWithCompletion:^(NSArray *pages, NSError *error) {
        [self.pagesArray addObjectsFromArray:pages];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self manageLogin];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setPagesArray:(NSArray *)pagesArray
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
        [logInViewController setFields:PFLogInFieldsDefault |PFLogInFieldsDismissButton];


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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    Page *page = self.pagesArray[indexPath.row];

    cell.textLabel.text = page.pageName;

    return cell;
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
