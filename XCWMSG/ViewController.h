//
//  ViewController.h
//  XCWMSG
//
//  Created by xcw on 15/1/14.
//  Copyright (c) 2015年 xcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,EGORefreshTableHeaderDelegate,ASIHTTPRequestDelegate, UISearchBarDelegate, UISearchDisplayDelegate,UISearchControllerDelegate,UISearchResultsUpdating>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading;
    
}

@property(nonatomic,retain)UIImageView *barView;
@property(nonatomic,retain)NSMutableArray *list;
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchController *SearchController;

@property (strong, nonatomic) NSArray* sortedArray;
@property (strong, nonatomic) UITableView* MyTableView;
@property (strong, nonatomic) NSArray* data;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end

