//
//  ANDMCreateEventViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMCreateEventViewController.h"
#import "Page.h"
#import "FeatureBaseViewController.h"

@interface ANDMCreateEventViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *hashtagTextField;

@property (weak, nonatomic) IBOutlet UIButton *imageAddButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) UIImage *selectedEventImage;
@property (strong, nonatomic) PFFile *eventImageFile;

@end

@implementation ANDMCreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

    [page saveInBackground];
}
- (IBAction)onCancel:(UIBarButtonItem *)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeatureBaseViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"mainfeed"];

    [self.navigationController pushViewController:controller animated:YES];
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

@end
