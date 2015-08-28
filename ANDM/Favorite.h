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

typedef void(^checkSelectedPageBlock)(PFObject *object, NSError *error);
typedef void(^allPagesBlock)(NSArray *objects, NSError *error);

@interface Favorite : PFObject <PFSubclassing>

@property (nonatomic, strong) Page *favoritedPage;
@property (nonatomic, strong) PFUser *user;

+ (void)checkIfSelectedPageisFavorited:(Page *)selectedPage withCompletion:(checkSelectedPageBlock)completion;
+ (void)fetchAllPagesForCurrentUserWithCompletion:(allPagesBlock)completion;

@end
