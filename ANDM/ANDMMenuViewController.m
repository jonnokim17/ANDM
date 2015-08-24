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

@interface ANDMMenuViewController () <UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate>

@property (nonatomic, strong) NSArray *menuArray;

@end

@implementation ANDMMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menuArray = @[@"profile", @"event", @"favorites", @"logout"];
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

    cell.textLabel.text = self.menuArray[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        [PFUser logOut];
        ANDMLoginViewController *loginVC = [[ANDMLoginViewController alloc] init];
        [loginVC setDelegate:self];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"event"]) {
//        UINavigationController *navVC = segue.destinationViewController;
//        ANDMCreateEventViewController *createEventVC
//    }
//}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//    // Set the title of navigation bar by using the menu items
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
//    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
//
//    // Set the photo if it navigates to the PhotoView
//    if ([segue.identifier isEqualToString:@"showPhoto"]) {
//        UINavigationController *navController = segue.destinationViewController;
//        PhotoViewController *photoController = [navController childViewControllers].firstObject;
//        NSString *photoFilename = [NSString stringWithFormat:@"%@_photo", [menuItems objectAtIndex:indexPath.row]];
//        photoController.photoFilename = photoFilename;
//    }
//}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
