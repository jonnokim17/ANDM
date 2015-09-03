//
//  ANDMSearchBar.h
//  ANDM
//
//  Created by Jonathan Kim on 9/2/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANDMSearchBar : UISearchBar

@property UIFont *preferredFont;
@property UIColor *preferredTextColor;

- (instancetype)initWithFrame:(CGRect)frame font:(UIFont *)font andTextColor:(UIColor *)textColor andBarTintColor:(UIColor *)barTintColor;

@end
