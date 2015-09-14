//
//  InstagramTableViewCell.h
//  ANDM
//
//  Created by Jonathan Kim on 8/25/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userprofileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UITextView *twitterTextView;

@end
