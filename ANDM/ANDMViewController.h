    //
//  ANDMViewController.h
//  ANDM
//
//  Created by Jonathan Kim on 9/2/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANDMSearchBar.h"

@protocol ANDMViewControllerDelegate <NSObject>

- (void)didStartSearching;
- (void)didTapOnSearchButton;
- (void)didTapOnCancelButton;
- (void)didChangeSearchText:(NSString *)searchText;

@end

@interface ANDMViewController : UISearchController <UISearchBarDelegate>

@property ANDMSearchBar *ANDMSearchBar;
@property (nonatomic, weak) id <ANDMViewControllerDelegate> customDelegate;

- (instancetype)initWithResultsController:(UIViewController *)searchResultsController searchBarFrame:(CGRect)searchBarFrame searchBarFont:(UIFont *)searchBarFont searchBarTextColor:(UIColor *)searchBarTextColor andSearchBarTintColor:(UIColor *)searchBarTintColor;

@end
