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

@interface ANDMDetailViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *hashtagLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property MKPointAnnotation *eventAnnotation;

@property (strong, nonatomic) NSArray *instagramData;

@end

@implementation ANDMDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"ANDM";

    [InstagramData retrieveVideoInformation:self.selectedPage.hashtag andWithCompletion:^(NSArray *data, NSError *error) {
        if (!error) {
            self.instagramData = data;
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

    self.eventTitleLabel.text = self.selectedPage.pageName;
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
    return self.instagramData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    InstagramData *instagramData = self.instagramData[indexPath.row];

    cell.usernameLabel.text = instagramData.username;
    cell.tagLabel.text = [instagramData.tags componentsJoinedByString:@", "];

    UIImage *profileImage = [UIImage imageWithData:instagramData.userProfileImageData];
    cell.userprofileImageView.image = profileImage;

    UIImage *contentImage = [UIImage imageWithData:instagramData.contentImageData];
    cell.contentImageView.image = contentImage;

//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterShortStyle];
//    cell.timeStampLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:instagramData.createdTime]];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramData *selectedInstagram = self.instagramData[indexPath.row];

    [[UIApplication sharedApplication] openURL:selectedInstagram.instagramURL];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.stackoverflow.com"]];
}

@end
