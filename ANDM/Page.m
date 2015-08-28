//
//  Page.m
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "Page.h"

@implementation Page

@dynamic address;
@dynamic date;
@dynamic endDate;
@dynamic hashtag;
@dynamic location;
@dynamic pageName;
@dynamic image;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Page";
}

+ (void)getPagesWithObjectIds:(NSArray *)objectIds andCompletion:(getPagesBlock)completion
{
    PFQuery *query = [self query];
    [query whereKey:@"objectId" containedIn:objectIds];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            completion(objects, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
