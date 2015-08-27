//
//  NSMutableString+AppendPrefix.m
//  ANDM
//
//  Created by Jonathan Kim on 8/27/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "NSMutableString+AppendPrefix.h"

@implementation NSMutableString (AppendPrefix)

- (void)appendPrefix:(NSString *)prefix
{
    [self insertString:prefix atIndex:0];
}

@end
