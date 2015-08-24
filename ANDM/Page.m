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

+ (void)getPagesWithCompletion:(void(^)(NSArray *pages, NSError *error))completion
{
    PFQuery *query = [Page query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSArray *pagesArray = objects;
            completion(pagesArray, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
