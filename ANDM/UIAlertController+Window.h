//
//  UIAlertController+Window.h
//  ANDM
//
//  Created by Jonathan Kim on 8/23/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIAlertController (Window)

@property (nonatomic, strong) UIWindow *alertWindow;

- (void)show;
- (void)show:(BOOL)animated;

@end
