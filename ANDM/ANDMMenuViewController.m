//
//  ANDMMenuViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMMenuViewController.h"
#import <Parse/Parse.h>
#import "ANDMLoginViewController.h"
#import "ANDMCreateEventViewController.h"
#import "SWRevealViewController.h"

@interface ANDMMenuViewController () <UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate>

@property (nonatomic, strong) NSArray *menuArray;

@end

@implementation ANDMMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menuArray = @[@"Profile", @"Create Event", @"Favorites", @"Logout"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

#pragma mark - UITableviewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuArray objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.textLabel.text = self.menuArray[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        [self logOutAlert];
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers
- (void)logOutAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to logout?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [PFUser logOut];

        SWRevealViewController *revealViewController = self.revealViewController;
        if (revealViewController) {
            [revealViewController revealToggleAnimated:YES];
        }

        ANDMLoginViewController *loginVC = [[ANDMLoginViewController alloc] init];
        [loginVC setDelegate:self];
        [self presentViewController:loginVC animated:YES completion:nil];
    }];

    [alert addAction:yesButton];
    [alert addAction:noButton];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
