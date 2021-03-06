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
#import "NSDate+TimeAgo.h"

@interface ANDMFavoritesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

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
