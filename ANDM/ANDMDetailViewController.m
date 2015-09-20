//
//  ANDMDetailViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/24/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMDetailViewController.h"
#import <MapKit/MapKit.h>
#import "InstagramData.h"
#import "InstagramTableViewCell.h"
#import "SVProgressHUD.h"
#import "Favorite.h"
#import "TwitterData.h"

@interface ANDMDetailViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventDescription;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *hashtagLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteStar;
@property (weak, nonatomic) IBOutlet UILabel *postsPerHourLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property MKPointAnnotation *eventAnnotation;
@property (strong, nonatomic) NSArray *instagramData;
@property (strong, nonatomic) NSArray *twitterData;

@property (nonatomic) int twitterPostsPerHour;
@property (nonatomic) int instagramPostsPerHour;

@end

@implementation ANDMDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.selectedPage.pageName;

    [TwitterData getTwitterRecentPostsCount:self.selectedPage.hashtag withCompletion:^(int postsPerHour, NSError *error) {

        if (!error) {
            self.twitterPostsPerHour = postsPerHour;

            [InstagramData getInstagramRecentPostsCount:self.selectedPage.hashtag withCompletion:^(int postsPerHour, NSError *error) {

                if (!error) {
                    self.instagramPostsPerHour = postsPerHour;
                    int postsHr = self.twitterPostsPerHour + self.instagramPostsPerHour;
                    self.selectedPage.postsHr = postsHr;
                    [self.selectedPage saveInBackground];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.postsPerHourLabel.text = [NSString stringWithFormat:@"%d Posts/Hr", postsHr];
                    });
                } else {
                    NSLog(@"%@", error.description);
                }
            }];

        } else {
            NSLog(@"%@", error.description);
        }
    }];

    [TwitterData getSearchResultsWithHashtag:self.selectedPage.hashtag withCompletion:^(NSArray *twitterData, NSError *error) {
        if (!error) {
            self.twitterData = twitterData;
        } else {
            NSLog(@"%@", error.description);
        }
    }];

    [InstagramData getInstagramInformation:self.selectedPage.hashtag andWithCompletion:^(NSArray *data, NSError *error) {
        if (!error) {
            self.instagramData = data;
        } else {
            NSLog(@"%@", error.description);
        }
    }];

    [self.selectedPage.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];

            dispatch_async(dispatch_get_main_queue(), ^{
                self.eventImageView.image = image;
                self.eventImageView.layer.cornerRadius = 25;
            });
        }
    }];

    self.eventDescription.text = self.selectedPage.about;

    NSString *hashtag = self.selectedPage.hashtag;
    NSMutableString *hashtagString = [NSMutableString stringWithString:hashtag];
    [hashtagString insertString:@"#" atIndex:0];
    self.hashtagLabel.text = hashtagString;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy | h:mm a"];
    NSString *dateString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.selectedPage.date]];
    self.dateLabel.text = dateString;

    self.addressLabel.text = self.selectedPage.address;

    self.mapView.scrollEnabled = NO;
    CLLocationCoordinate2D eventCoordinate = CLLocationCoordinate2DMake(self.selectedPage.location.latitude, self.selectedPage.location.longitude);
    self.eventAnnotation = [[MKPointAnnotation alloc] init];
    self.eventAnnotation.coordinate = eventCoordinate;
    self.eventAnnotation.title = self.selectedPage.pageName;
    [self.mapView addAnnotation:self.eventAnnotation];

    CLLocationCoordinate2D center = eventCoordinate;
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = 0.25;
    coordinateSpan.longitudeDelta = 0.25;
    MKCoordinateRegion coordiateRegion = MKCoordinateRegionMake(center, coordinateSpan);
    [self.mapView setRegion:coordiateRegion animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self showLoadingIndicator];

    [Favorite checkIfSelectedPageisFavorited:self.selectedPage withCompletion:^(PFObject *object, NSError *error) {
        if (object) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.favoriteStar setImage:[UIImage imageNamed:@"colorStar"]];
            });
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

-(void)setInstagramData:(NSArray *)instagramData
{
    _instagramData = instagramData;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.instagramData.count;
    } else {
        return self.twitterData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.section == 0) {
        InstagramData *instagramData = self.instagramData[indexPath.row];

        dispatch_async(dispatch_get_main_queue(), ^{
            cell.usernameLabel.text = instagramData.username;
            cell.tagLabel.text = [instagramData.tags componentsJoinedByString:@", "];
            cell.timeStampLabel.text = instagramData.timeStamp;
            cell.twitterTextView.hidden = YES;

            cell.userprofileImageView.image = [UIImage imageWithData:instagramData.userProfileImageData];
            cell.userprofileImageView.alpha = 0.0f;

            cell.contentImageView.image = [UIImage imageWithData:instagramData.contentImageData];
            cell.contentImageView.alpha = 0.0f;

            [UIView animateWithDuration:0.5f animations:^{
                cell.userprofileImageView.alpha = 1.0f;
                cell.contentImageView.alpha = 1.0f;
            }];
        });
    } else {
        TwitterData *twitterData = self.twitterData[indexPath.row];

        dispatch_async(dispatch_get_main_queue(), ^{
            cell.usernameLabel.text = twitterData.name;
            cell.userprofileImageView.image = [UIImage imageWithData:twitterData.userProfileImageData];
            cell.timeStampLabel.text = twitterData.timeStamp;
            cell.contentImageView.image = nil;
            cell.twitterTextView.hidden = NO;
            cell.twitterTextView.text = twitterData.text;
            cell.tagLabel.text = nil;
        });
    }

    [SVProgressHUD dismiss];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Instagram";
    else
        return @"Twitter";
}

#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    InstagramData *selectedInstagram = self.instagramData[indexPath.row];
//    [self urlRedirectAlertTo:selectedInstagram.instagramURL];
//}

- (IBAction)onFavoriteStar:(UITapGestureRecognizer *)sender
{
    if ([self.favoriteStar.image isEqual:[UIImage imageNamed:@"star"]]) {
        Favorite *favorite = [Favorite objectWithClassName:@"Favorite"];
        favorite.favoritedPage = self.selectedPage;
        favorite.user = [PFUser currentUser];
        [favorite saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.favoriteStar setImage:[UIImage imageNamed:@"colorStar"]];
                    [self favoriteEventAlertWithMessage:@"Event added to Favorites"];
                });
            }
        }];
        
    } else if ([self.favoriteStar.image isEqual:[UIImage imageNamed:@"colorStar"]]) {
        [Favorite checkIfSelectedPageisFavorited:self.selectedPage withCompletion:^(PFObject *object, NSError *error) {
            if (object) {
                [object delete];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.favoriteStar setImage:[UIImage imageNamed:@"star"]];
                    [self favoriteEventAlertWithMessage:@"Event removed from Favorites"];
                });
            }
        }];
    }
}

#pragma mark - Helpers
- (void)showLoadingIndicator
{
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor blueColor]];
    [SVProgressHUD show];
}

- (void)favoriteEventAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)urlRedirectAlertTo:(NSURL *)url
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Would you like to view this Instagram on the web?" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:url];
    }];

    UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];

    [alert addAction:noButton];
    [alert addAction:yesButton];

    [self presentViewController:alert animated:yesButton completion:nil];
}

@end
