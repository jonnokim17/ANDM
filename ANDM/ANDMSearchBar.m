//
//  ANDMSearchBar.m
//  ANDM
//
//  Created by Jonathan Kim on 9/2/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMSearchBar.h"

@implementation ANDMSearchBar

- (instancetype)initWithFrame:(CGRect)frame font:(UIFont *)font andTextColor:(UIColor *)textColor andBarTintColor:(UIColor *)barTintColor
{
    self = [super initWithFrame:frame];

    if (self) {
        self.frame = frame;
        self.preferredFont = font;
        self.preferredTextColor = textColor;
        self.barTintColor = barTintColor;

        self.searchBarStyle = UISearchBarStyleProminent;
        self.translucent = NO;
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    return self;
}

- (void)drawRect:(CGRect)rect
{
    int index = [self indexOfSearchFieldInSubviews];

    // Access the search field
    UITextField *searchField = (UITextField *)self.subviews[0].subviews[index];

    // Set the frame
    searchField.frame = CGRectMake(5.0, 5.0, self.frame.size.width - 10.0, self.frame.size.height - 10.0);

    // Set the font and text color of the search field.
    searchField.font = self.preferredFont;
    searchField.textColor = self.preferredTextColor;

    // Set the background color of the search field.
    searchField.backgroundColor = self.barTintColor;

    CGPoint startPoint = CGPointMake(0.0, self.frame.size.height);
    CGPoint endPoint = CGPointMake(self.frame.size.width, self.frame.size.height);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];

    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = self.preferredTextColor.CGColor;
    shapeLayer.lineWidth = 2.5;

    [self.layer addSublayer:shapeLayer];

    [super drawRect:rect];
}

- (int)indexOfSearchFieldInSubviews
{
    int index;
    UIView *searchBarView = self.subviews[0];

    for (int i = 0; i < searchBarView.subviews.count; ++i) {
        if ([searchBarView.subviews[i] isKindOfClass:[UITextField class]]) {
            index = i;
            break;
        }
    }

    return index;
}

@end
