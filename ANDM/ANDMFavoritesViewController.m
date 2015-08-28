//
//  ANDMFavoritesViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/27/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMFavoritesViewController.h"
#import "SWRevealViewController.h"
#import "FeatureBaseViewController.h"
#import "Favorite.h"
#import "Page.h"
#import "SVProgressHUD.h"
#import "ANDMDetailViewController.h"

@interface ANDMFavoritesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) NSArray *favoritesArray;

@property (strong, nonatomic) FeatureBaseViewController *mainFeedVC;


@end

@implementation ANDMFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showLoadingIndicator];

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainFeedVC = [storyboard instantiateViewControllerWithIdentifier:@"mainfeed"];

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

//    PFQuery *query = [Favorite query];
//    [query whereKey:@"user" equalTo:[PFUser currentUser]];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//
//        Favorite *favoritedPage = (Favorite *)object;
//        PFQuery *pageQuery = [Page query];
//        [pageQuery whereKey:@"objectId" equalTo:favoritedPage.favoritedPage.objectId];
//        [pageQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//            self.favoritesArray = [@[] mutableCopy];
//            [self.favoritesArray addObject:object];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//            });
//        }];
//    }];

    PFQuery *query = [Favorite query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSMutableArray *favoritePageIdsArray = [@[] mutableCopy];
        for (Favorite *favorite in objects) {
            [favoritePageIdsArray addObject:favorite.favoritedPage.objectId];
        }

        PFQuery *pageQuery = [Page query];
        [pageQuery whereKey:@"objectId" containedIn:favoritePageIdsArray];
        [pageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
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

    return cell;
}
- (IBAction)onHome:(UIBarButtonItem *)sender
{
    [self.navigationController pushViewController:self.mainFeedVC animated:YES];
}

#pragma mark - Helpers
- (void)showLoadingIndicator
{
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor blueColor]];
    [SVProgressHUD show];
}

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

@end
