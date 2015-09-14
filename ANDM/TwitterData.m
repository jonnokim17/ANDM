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

//        self.hashtags = twitterInfo[@"entities"][@"hashtags"][@"text"];

        NSString *imageURLString = twitterInfo[@"user"][@"profile_image_url"];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        self.userProfileImageData = [NSData dataWithContentsOfURL:imageURL];

//        NSString *urlString = twitterInfo[@"entities"][@"urls"][@"display_url"];
//        self.twitterURL = [NSURL URLWithString:urlString];

        self.timeStamp = [self dateFromNumber:twitterInfo[@"created_at"]];
    }
    
    return self;
}

+ (void)getSearchResultsWithHashtag:(NSString *)hashtag withCompletion:(void(^)(NSArray *))complete
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
                                    complete(searchTweetsArray);

                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"search error");
                                    complete(nil);
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
