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

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
