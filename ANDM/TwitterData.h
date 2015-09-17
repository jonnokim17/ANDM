//
//  TwitterData.h
//  ANDM
//
//  Created by Jonathan Kim on 9/14/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterData : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSData *userProfileImageData;
@property (strong, nonatomic) NSString *timeStamp;
@property (strong, nonatomic) NSString *text;

+ (void)getSearchResultsWithHashtag:(NSString *)hashtag withCompletion:(void(^)(NSArray *data, NSError *error))complete;
+ (void)getTwitterRecentPostsCount:(NSString *)hashtag withCompletion:(void(^)(int postsPerHour, NSError *error))complete;

@end
