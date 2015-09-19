//
//  ANDMCreateEventViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMCreateEventViewController.h"
#import <MapKit/MapKit.h>
#import "Page.h"
#import "FeatureBaseViewController.h"
#import "SWRevealViewController.h"

@interface ANDMCreateEventViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventTextField;
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *hashtagTextField;

@property (weak, nonatomic) IBOutlet UIButton *imageAddButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UIImage *selectedEventImage;
@property (strong, nonatomic) PFFile *eventImageFile;
@property (strong, nonatomic) NSDate *startEventDate;
@property (strong, nonatomic) NSDate *endEventDate;

@property (strong, nonatomic) FeatureBaseViewController *mainFeedVC;

@end

@implementation ANDMCreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainFeedVC = [storyboard instantiateViewControllerWithIdentifier:@"mainfeed"];

    UIDatePicker *startDatePicker = [[UIDatePicker alloc]init];
    [startDatePicker setDate:[NSDate date]];
    [startDatePicker addTarget:self action:@selector(updateStartDateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.startTimeTextField setInputView:startDatePicker];

    UIDatePicker *endDatePicker = [[UIDatePicker alloc] init];
    [endDatePicker setDate:[NSDate date]];
    [endDatePicker addTarget:self action:@selector(updateEndDateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.endTimeTextField setInputView:endDatePicker];

//    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//    [geocoder geocodeAddressString:@"881 E. Buchanan Ct., Brea CA, 92821" completionHandler:^(NSArray* placemarks, NSError* error){
//        for (CLPlacemark* aPlacemark in placemarks)
//        {
//            // Process the placemark.
//            NSString *latDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.latitude];
//            NSString *lngDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.longitude];
//
//            NSLog(@"latitude: %@", latDest1);
//            NSLog(@"longitude: %@", lngDest1);
//        }
//    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [self deregisterFromKeyboardNotifications];
    [super viewDidDisappear:animated];
}

- (void)updateStartDateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.startTimeTextField.inputView;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy hh:mm a"];
    self.startTimeTextField.text = [dateFormat stringFromDate:picker.date];
    self.startEventDate = picker.date;
}

- (void)updateEndDateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.endTimeTextField.inputView;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy hh:mm a"];
    self.endTimeTextField.text = [dateFormat stringFromDate:picker.date];    self.endEventDate = picker.date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:TRUE];
}

- (IBAction)onCreateEvent:(UIButton *)sender
{
    Page *page = [Page objectWithClassName:@"Page"];
    page.pageName = self.eventTextField.text;
    page.hashtag = self.hashtagTextField.text;
    page.image = self.eventImageFile;
    page.date = self.startEventDate;
    page.endDate = self.endEventDate;
    page.address = self.locationTextField.text;

    // TODO: fix later..
    page.postsHr = 800;

    __block double latitude = 0;
    __block double longitude = 0;

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    if (self.eventTextField.text.length > 0 && self.startTimeTextField.text.length > 0 && self.endTimeTextField.text.length > 0 && self.locationTextField.text.length > 0 && self.hashtagTextField.text.length > 0 && self.eventImageView.image != nil) {

        [geocoder geocodeAddressString:self.locationTextField.text completionHandler:^(NSArray* placemarks, NSError* error){
            for (CLPlacemark* aPlacemark in placemarks)
            {
                latitude = aPlacemark.location.coordinate.latitude;
                longitude = aPlacemark.location.coordinate.longitude;

                if (latitude != 0 && longitude != 0) {
                    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
                    page.location = geoPoint;

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Event" message:@"Are you sure you want to create this event?" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [page saveInBackground];
                        [self.navigationController pushViewController:self.mainFeedVC animated:YES];
                    }];
                    UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:yesButton];
                    [alert addAction:noButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
    } else {
        [self errorAlertWithMessage:@"You need to fill out all fields"];
    }

}

- (IBAction)onAddImage:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *chooseFromLibrary = [UIAlertAction actionWithTitle:@"Choose from Library"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  // CHOOSE FROM PHOTO LIBRARY
                                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                  picker.delegate = self;
                                                                  picker.allowsEditing = YES;
                                                                  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

                                                                  [self presentViewController:picker animated:YES completion:NULL];

                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];

    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // CAMERA
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];

            [myAlertView show];

        }
        
        else
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];

    [alert addAction:chooseFromLibrary];

    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [alert addAction:takePhoto];
    }
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //TODO: change image dimension here... distorted
    self.selectedEventImage = info[UIImagePickerControllerOriginalImage];

    NSData *imageData = UIImageJPEGRepresentation(self.selectedEventImage, 0.5f);
    self.eventImageFile = [PFFile fileWithName:@"image.jpg" data:imageData];

    self.eventImageView.hidden = NO;
    self.imageAddButton.hidden = YES;
    self.eventImageView.image = self.selectedEventImage;

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if (textField == self.hashtagTextField) {
        NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
        if ([resultingString rangeOfCharacterFromSet:whitespaceSet].location == NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Helpers
- (void)errorAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

//TODO: need to implement this later

//- (void)registerForKeyboardNotifications {
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//
//}
//
//- (void)deregisterFromKeyboardNotifications {
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillShowNotification
//                                                  object:nil];
//}
//
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    CGRect newFrame = self.view.frame;
//    newFrame.origin.y -= [self getKeyboardHeight:notification]/2;
//
//    [UIView animateWithDuration:0.3f animations:^ {
//        self.view.frame = newFrame;
//    }];
//}
//
//- (void)keyboardWillHide:(NSNotification *)notification
//{
//    CGRect newFrame = self.view.frame;
//    newFrame.origin.y += [self getKeyboardHeight:notification]/2;
//
//    [UIView animateWithDuration:0.3f animations:^ {
//        self.view.frame = newFrame;
//    }];
//}
//
//- (CGFloat)getKeyboardHeight:(NSNotification *)notification
//{
//    NSDictionary *userInfo = notification.userInfo;
//    NSValue *keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey];
//
//    CGRect keyboardRect = [keyboardSize CGRectValue];
//    return keyboardRect.size.height;
//}

@end
