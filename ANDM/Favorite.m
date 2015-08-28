//
//  Favorite.m
//  ANDM
//
//  Created by Jonathan Kim on 8/27/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

@dynamic favoritedPage;
@dynamic user;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Favorite";
}

+ (void)checkIfSelectedPageisFavorited:(Page *)selectedPage withCompletion:(checkSelectedPageBlock)completion
{
    PFQuery *query = [self query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"favoritedPage" equalTo:selectedPage];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) {
            completion(object, nil);
        } else {
            completion(nil, error);
        }
    }];
}

+ (void)fetchAllPagesForCurrentUserWithCompletion:(allPagesBlock)completion
{
    PFQuery *query = [self query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            completion(objects, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
