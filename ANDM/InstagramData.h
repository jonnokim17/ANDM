//
//  InstagramData.h
//  ANDM
//
//  Created by Jonathan Kim on 8/25/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramData : NSObject

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSData *userProfileImageData;
@property (nonatomic, strong) NSString *timeStamp;
@property (nonatomic, strong) NSURL *instagramURL;
@property (nonatomic, strong) NSData *contentImageData;

- (instancetype)initWithDictionary:(NSDictionary *)instagramInfo;
+ (void)retrieveVideoInformation:(NSString *)hastag andWithCompletion:(void(^)(NSArray *data, NSError *error))complete;

@end
