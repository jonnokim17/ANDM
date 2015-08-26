//
//  InstagramData.m
//  ANDM
//
//  Created by Jonathan Kim on 8/25/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "InstagramData.h"

NSString * const kInstagramClientID = @"9ec8da819f1b4cdaa02fb0273f6b6247";
NSString * const kInstagramClientSecret = @"ed606dd6328447bc984b73b10d514b75";
NSString * const kAccessToken = @"25679300.9ec8da8.1c1c1b4ec03544d88e1077080fb802f9";

@implementation InstagramData

//@property (nonatomic, strong) NSDate *createdTime;

- (instancetype)initWithDictionary:(NSDictionary *)instagramInfo
{
    self = [super init];

    if (self) {
        self.tags = instagramInfo[@"tags"];
        self.username = instagramInfo[@"user"][@"username"];

        NSString *imageURLString = instagramInfo[@"user"][@"profile_picture"];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        self.userProfileImageData = [NSData dataWithContentsOfURL:imageURL];

        NSString *contentURLString = instagramInfo[@"images"][@"standard_resolution"][@"url"];
        NSURL *contentURL = [NSURL URLWithString:contentURLString];
        self.contentImageData = [NSData dataWithContentsOfURL:contentURL];

        NSString *urlString = instagramInfo[@"link"];
        self.instagramURL = [NSURL URLWithString:urlString];

        //TODO: implemented created at timestamp
//        self.createdTime = [self dateFromNumber:instagramInfo[@"created_time"]];
    }

    return self;
}

+ (void)retrieveVideoInformation:(NSString *)hastag andWithCompletion:(void(^)(NSArray *data, NSError *error))complete
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@", hastag, kAccessToken]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

            if (!jsonError) {
                NSArray *resultsArray = resultsDictionary[@"data"];
                NSMutableArray *instagramArray = [@[] mutableCopy];

                int i = 0;
                for (NSDictionary *dict in resultsArray) {
                    if (i < 4) {
                        InstagramData *instagramData = [[InstagramData alloc] initWithDictionary:dict];
                        [instagramArray addObject:instagramData];
                        i++;
                    }
                }
                complete(instagramArray, nil);
            }

        } else {
            complete(nil, error);
        }
    }] resume];
}

//- (NSDate *)dateFromNumber:(NSNumber *)number
//{
//    NSNumber *time = [NSNumber numberWithDouble:([number doubleValue])];
//    NSTimeInterval interval = [time doubleValue];
//
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval/1000.];
//
//    return date;
//}

@end
