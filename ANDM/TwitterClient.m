//
//  TwitterClient.m
//  ANDM
//
//  Created by Jonathan Kim on 9/14/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "TwitterClient.h"

NSString * const kTwitterConsumerKey = @"uWjaHWCv7QqlcyqGtDAn1vjM2";
NSString * const kTwitterConsumerSecret = @"Xv2WTysvsndb7y5iAufQnKQPIQdUi0b4deZv4hDUERf2YbQ7NH";
NSString * const kTwitterBaseURL = @"https://api.twitter.com";

@implementation TwitterClient

+ (TwitterClient *)sharedInstance
{
    static TwitterClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseURL]
                                                  consumerKey:kTwitterConsumerKey
                                               consumerSecret:kTwitterConsumerSecret];
        }
    });

    return instance;
}

@end
