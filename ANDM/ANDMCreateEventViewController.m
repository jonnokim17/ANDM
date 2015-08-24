//
//  ANDMCreateEventViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMCreateEventViewController.h"
#import "Page.h"

@interface ANDMCreateEventViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *eventTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *hashtagTextField;

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

    [page saveInBackground];
}

@end
