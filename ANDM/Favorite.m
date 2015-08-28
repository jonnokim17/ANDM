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

@end
