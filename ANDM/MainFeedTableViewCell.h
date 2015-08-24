//
//  MainFeedTableViewCell.h
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "PFTableViewCell.h"

@interface MainFeedTableViewCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;

@end
