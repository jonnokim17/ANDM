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
//@property (strong, nonatomic) NSString *hashtags;
//@property (nonatomic, strong) NSURL *twitterURL;

+ (void)getSearchResultsWithHashtag:(NSString *)hashtag withCompletion:(void(^)(NSArray *))complete;

@end
