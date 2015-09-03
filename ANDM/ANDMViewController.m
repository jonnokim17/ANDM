//
//  ANDMViewController.m
//  ANDM
//
//  Created by Jonathan Kim on 9/2/15.
//  Copyright © 2015 Jonathan Kim. All rights reserved.
//

#import "ANDMViewController.h"

@interface ANDMViewController ()

@end

@implementation ANDMViewController 

- (instancetype)initWithResultsController:(UIViewController *)searchResultsController searchBarFrame:(CGRect)searchBarFrame searchBarFont:(UIFont *)searchBarFont searchBarTextColor:(UIColor *)searchBarTextColor andSearchBarTintColor:(UIColor *)searchBarTintColor
{
    self = [super initWithSearchResultsController:searchResultsController];

    if (self) {
        [self configureSearchBar:searchBarFrame font:searchBarFont textColor:searchBarTextColor andbgColor:searchBarTintColor];
    }

    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    return self;
}

- (void)configureSearchBar:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor andbgColor:(UIColor *)bgColor
{
    self.ANDMSearchBar = [[ANDMSearchBar alloc] initWithFrame:frame font:font andTextColor:textColor andBarTintColor:bgColor];

    self.ANDMSearchBar.barTintColor = bgColor;
    self.ANDMSearchBar.tintColor = textColor;
    self.ANDMSearchBar.showsBookmarkButton = NO;
    self.ANDMSearchBar.showsCancelButton = YES;
    self.ANDMSearchBar.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.customDelegate didStartSearching];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.ANDMSearchBar resignFirstResponder];
    [self.customDelegate didTapOnSearchButton];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.ANDMSearchBar resignFirstResponder];
    [self.customDelegate didTapOnCancelButton];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.customDelegate didChangeSearchText:searchText];
}

@end
