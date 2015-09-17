//
//  TwitterData.m
//  ANDM
//
//  Created by Jonathan Kim on 9/14/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "TwitterData.h"
#import "TwitterClient.h"
#import "NSDate+TimeAgo.h"

@implementation TwitterData

- (instancetype)initWithDictionary:(NSDictionary *)twitterInfo
{
    self = [super init];

    if (self) {
        self.name = twitterInfo[@"user"][@"name"];
        self.text = twitterInfo[@"text"];

        NSString *imageURLString = twitterInfo[@"user"][@"profile_image_url"];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        self.userProfileImageData = [NSData dataWithContentsOfURL:imageURL];

        self.timeStamp = [self dateFromNumber:twitterInfo[@"created_at"]];
    }
    
    return self;
}

+ (void)getSearchResultsWithHashtag:(NSString *)hashtag withCompletion:(void(^)(NSArray *data, NSError *error))complete
{
    [[TwitterClient sharedInstance] GET:[NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&result_type=recent", hashtag]
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSLog(@"search successful");

                                    NSArray *statusesArray = responseObject[@"statuses"];
                                    NSMutableArray *searchTweetsArray = [@[] mutableCopy];

                                    int i = 0;
                                    for (NSDictionary *dict in statusesArray) {
                                        if (i < 4) {
                                            TwitterData *twitterData = [[TwitterData alloc] initWithDictionary:dict];
                                            [searchTweetsArray addObject:twitterData];
                                            i++;
                                        }
                                    }
                                    complete(searchTweetsArray, nil);

                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"search error");
                                    complete(nil, error);
                                }];
}

+ (void)getTwitterRecentPostsCount:(NSString *)hashtag withCompletion:(void(^)(int postsPerHour, NSError *error))complete
{
    [[TwitterClient sharedInstance] GET:[NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&count=100", hashtag]
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSLog(@"search successful");

                                    NSArray *statusesArray = responseObject[@"statuses"];

                                    NSDateFormatter * df = [[NSDateFormatter alloc] init];
                                    [df setDateFormat:@"EEE MMM d HH:mm:ss Z y"];

                                    int recentPostCount = 0;

                                    for (NSDictionary *dict in statusesArray) {
                                        NSString *postDate = dict[@"created_at"];

                                        NSDate *newDate = [df dateFromString:postDate];
                                        NSTimeInterval postTimeInterval = [[NSDate date] timeIntervalSinceDate:newDate];

                                        if (postTimeInterval <= 600.0) {
                                            recentPostCount++;
                                        }
                                    }

                                    int postsPerHour = recentPostCount * 6;

                                    complete(postsPerHour, nil);

                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"search error");
                                    complete(0, error);
                                }];
}

- (NSString *)dateFromNumber:(NSString *)dateString
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE MMM d HH:mm:ss Z y"];
    NSDate * newDate = [df dateFromString:dateString];
    NSTimeInterval secondsElapsed = [[NSDate date] timeIntervalSinceDate:newDate];

    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:secondsElapsed];
    NSString *timeAgo = [date timeAgo];

    return timeAgo;
}

@end
