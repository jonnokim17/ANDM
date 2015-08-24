//
//  Page.h
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "PFObject.h"
#import <Parse/Parse.h>

@interface Page : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *hashtag;
@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic, strong) NSString *pageName;
@property (nonatomic, strong) PFFile *image;

+ (void)getPagesWithCompletion:(void(^)(NSArray *pages, NSError *error))completion;

@end
