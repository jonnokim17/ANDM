//
//  Favorite.h
//  ANDM
//
//  Created by Jonathan Kim on 8/27/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "PFObject.h"
#import <Parse/Parse.h>
#import "Page.h"

@interface Favorite : PFObject <PFSubclassing>

@property (nonatomic, strong) Page *favoritedPage;
@property (nonatomic, strong) PFUser *user;

@end
