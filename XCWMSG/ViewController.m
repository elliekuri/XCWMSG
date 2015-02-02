//
//  ViewController.m
//  XCWMSG
//
//  Created by xcw on 15/1/14.
//  Copyright (c) 2015年 xcw. All rights reserved.
//

#import "ViewController.h"
#import "DetailView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "XGPush.h"
#import "KVNProgress.h"
#import "ASIFormDataRequest.h"
#import "Reachability.h"
#import "JSONKit.h"
#import "AndroidData.h"
#import "CustomCell.h"
#import "AppDelegate.h"
#import "RemarkID.h"
@interface ViewController ()
{
    NSManagedObjectContext *context;
    EGORefreshTableHeaderView *egoview;
    NSArray* coachArr;
    BOOL isEGO;
    UIImageView* circle;
}
@end

@implementation ViewController
@synthesize MyTableView,data,sortedArray,searchBar,SearchController;
-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    [self setupBaseKVNProgressUI];
    
    [MyTableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isEGO = NO;
    
    AppDelegate * appdelegate = [[UIApplication sharedApplication]delegate];
    context = [appdelegate managedObjectContext];
    
    _list = [[NSMutableArray alloc] initWithCapacity:1];
    // Do any additional setup after loading the view, typically from a nib.
    self.title =@"检测报告消息";

    searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchBar.placeholder = @"Search";
    searchBar.delegate = self;
    [self.searchBar sizeToFit];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    MyTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    MyTableView.dataSource = self;
    MyTableView.delegate = self;
    MyTableView.separatorStyle = YES;
    MyTableView.backgroundColor = [[UIColor alloc]initWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    MyTableView.tableHeaderView = searchBar;
    [self.view addSubview:MyTableView];
    
    SearchController = [[UISearchController alloc]initWithSearchResultsController:self];
    [SearchController setDelegate:self];
    
    if (_refreshHeaderView == nil) {
        egoview = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f- MyTableView.bounds.size.height, self.view.frame.size.width, MyTableView.bounds.size.height)];
        egoview.delegate = self;
        [MyTableView addSubview:egoview];
        _refreshHeaderView = egoview;
    }

    if ([self isConnectionAvailable]) {
        [KVNProgress showWithStatus:@"Loading..."];
        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(QueryData)object:nil];
        [thread start];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%@",sortedArray);
    return [sortedArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. cell标示符，使cell能够重用
    static NSString *PushCell = @"PushmessageCell";
    // 2. 从TableView中获取标示符为paperCell的Cell
    CustomCell *cell = (CustomCell*)[tableView dequeueReusableCellWithIdentifier:PushCell];
    // 如果 cell = nil , 则表示 tableView 中没有可用的闲置cell
    if(cell == nil){
        // 3. 把 WPaperCell.xib 放入数组中
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil] ;
        // 获取nib中的第一个对象
        for (id oneObject in nib){
            // 判断获取的对象是否为自定义cell
            if ([oneObject isKindOfClass:[CustomCell class]]){
                // 4. 修改 cell 对象属性
                cell = [(CustomCell*)oneObject initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PushCell];
            }
        }
    }

    AndroidData* celldata = [[AndroidData alloc]init];
    celldata = sortedArray[indexPath.row];
    NSEntityDescription *entitydesc = [NSEntityDescription entityForName:@"RemarkID" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entitydesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rid like %@",celldata.DataID];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *matchingData = [context executeFetchRequest:request error:&error];
    NSLog( @"%@",matchingData);
    if (matchingData.count > 0) {
        [cell.circle setHidden:YES];
    }else{
        [cell.circle setHidden:NO];
    }
    cell.FirstTitle.text = celldata.username;
    cell.SubTitle.text = celldata.mobile;
    NSString* check_report_str =[[NSString alloc]initWithFormat:@"订单号: %@",celldata.DataID];
    cell.DetailTitle.text =check_report_str;
    cell.CarBan.text = celldata.car_number;
    cell.CarNum.text = celldata.car_series;
    celldata = nil;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    AndroidData* celldata = [[AndroidData alloc]init];
    celldata = sortedArray[indexPath.row];
    
    NSEntityDescription *entitydesc = [NSEntityDescription entityForName:@"RemarkID" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entitydesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rid like %@",celldata.DataID];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *matchingData = [context executeFetchRequest:request error:&error];

    if (matchingData.count <= 0) {
        NSLog( @"no id");
        NSManagedObject *newFlightNum = [[NSManagedObject alloc]initWithEntity:entitydesc insertIntoManagedObjectContext:context];
        
        [newFlightNum setValue:celldata.DataID forKey:@"rid"];
        NSError *Error;
        [context save:&Error];
        NSLog(@"person added");
    }
    
    DetailView* view = [[DetailView alloc]init];
    view.title =celldata.car_number;
    view.Adata = (AndroidData*)celldata;
    [self.navigationController pushViewController:view animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma 
#pragma Qdata
-(BOOL) isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    
    if (!isExistenceNetwork) {

        
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"" message:@"网络不可用，请检查网络连接" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [error show];

        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:@"SArray"];
        sortedArray = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];

        if (sortedArray.count!=0) {
            [MyTableView reloadData];
        }

        return NO;
    }
    
    return isExistenceNetwork;
}

-(void)QueryData{
    NSString *query = [[NSString alloc]initWithFormat:@"http://www.xieche.com.cn/appandroid/remark_achieve?id=all"];
    NSString* webStringURL = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *newURL = [NSURL URLWithString:webStringURL];
    NSLog(@"%@",newURL);
    ASIFormDataRequest* from = [ASIFormDataRequest requestWithURL:newURL];
    from.delegate = self;
    [from startAsynchronous];
    
    
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *Requestdata = [request responseData];
    
    NSDictionary* RdataDict =(NSDictionary*)[Requestdata objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    
    NSMutableArray* SArray = [[NSMutableArray alloc]init];
    
    int DictKey = (int)[[RdataDict allKeys]count];
    for(int Index=DictKey;Index>=1;Index--)
    {
        NSDictionary* CellDict = [[NSDictionary alloc]init];
        NSString* IndexStr = [[NSString alloc]initWithFormat:@"%d",Index];
        CellDict =[RdataDict objectForKey:IndexStr];
        AndroidData* AData =[[AndroidData alloc]init];
        
        AData.address = [CellDict objectForKey:@"address"];
        AData.check_report_id = [CellDict objectForKey:@"check_report_id"];
        AData.create_time = [CellDict objectForKey:@"create_time"];
        AData.DataID = [CellDict objectForKey:@"id"];
        AData.image_url =[CellDict objectForKey:@"image_url"];
        AData.sound_url = [CellDict objectForKey:@"sound_url"];
        AData.remarks = [CellDict objectForKey:@"remarks"];
        AData.car_brand = [CellDict objectForKey:@"car_brand"];
        AData.car_series = [CellDict objectForKey:@"car_series"];
        AData.mobile = [CellDict objectForKey:@"mobile"];
        AData.car_number = [CellDict objectForKey:@"car_number"];
        AData.username = [CellDict objectForKey:@"username"];
        
        [SArray addObject:AData];
        AData= nil;
    }
 //   NSLog(@"%@",SArray);

    
    if(SArray.count ==0)
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"" message:@"没有找到符合条件的结果" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [error show];
    }
    else
    {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:SArray];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodedObject forKey:@"SArray"];
        [defaults synchronize];
        sortedArray = [[NSArray alloc]init];
        coachArr = [[NSArray alloc]init];
        sortedArray = SArray;
        coachArr = SArray;
        if (isEGO ==YES) {
        }else{
        [self showSuccess];
        }
        [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:YES];
    }
    
}


-(void) updateTableView{
        [MyTableView reloadData];
}

// 请求失败
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"startcode:%d",[request responseStatusCode]);
    NSLog(@"%@",error);
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    _reloading = YES;
    
}

- (void)doneLoadingTableViewData{
    _reloading = NO;

    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:MyTableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
      NSLog(@"下拉更新");

    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
        isEGO = YES;
      [self QueryData];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark EGORefreshTableHeaderDelegate Methods
//下拉到一定距离，手指放开时调用
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
  
    [self reloadTableViewDataSource];

    //停止加载，弹回下拉
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
    
    if (_barView == nil) {
        UIImage *img = [[UIImage imageNamed:@"timeline_new_status_background.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        _barView = [[UIImageView alloc] initWithImage:img];
        _barView.frame = CGRectMake(5, -40, 320-10, 40);
        [self.view addSubview:_barView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = 100;
        label.font = [UIFont systemFontOfSize:16.0f];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [_barView addSubview:label];

    }
 // NSLog(@"下拉更新");
    [self performSelector:@selector(updateUI) withObject:nil afterDelay:2.0];
    
}

- (void)updateUI {

        [UIView animateWithDuration:0.6 animations:^{
        CGRect frame = _barView.frame;
        frame.origin.y = 5;
        _barView.frame = frame;
    } completion:^(BOOL finished){
        if (finished) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:1.0];
            [UIView setAnimationDuration:0.6];
            CGRect frame = _barView.frame;
            frame.origin.y = -40;
            _barView.frame = frame;
            [UIView commitAnimations];
        }
    }];
    
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"msgcome" ofType:@"wav"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    SystemSoundID soundId;
//    AudioServicesCreateSystemSoundID((CFURLRef)url, &soundId);
//    AudioServicesPlaySystemSound(soundId);
//    
//    
//    [_tableView reloadData];
    
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{

    return _reloading; // should return if data source model is reloading
    
}

//取得下拉刷新的时间
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{

    return [NSDate date]; // should return date data source was last changed
    
}

#pragma 
#pragma KVNProgress
- (void)setupBaseKVNProgressUI
{
    // See the documentation of all appearance propoerties
    [KVNProgress appearance].statusColor = [UIColor darkGrayColor];
    [KVNProgress appearance].statusFont = [UIFont systemFontOfSize:17.0f];
    [KVNProgress appearance].circleStrokeForegroundColor = [UIColor darkGrayColor];
    [KVNProgress appearance].circleStrokeBackgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
    [KVNProgress appearance].circleFillBackgroundColor = [UIColor clearColor];
    [KVNProgress appearance].backgroundFillColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
    [KVNProgress appearance].backgroundTintColor = [UIColor whiteColor];
    [KVNProgress appearance].successColor = [UIColor darkGrayColor];
    [KVNProgress appearance].errorColor = [UIColor darkGrayColor];
    [KVNProgress appearance].circleSize = 75.0f;
    [KVNProgress appearance].lineWidth = 2.0f;
}

- (void)showSuccess
{
        [KVNProgress showSuccessWithStatus:@"Success"];
}

//searchbar
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)sBar {
     sBar.showsCancelButton = YES;
    for (UIView *searchbuttons in sBar.subviews)
    {
        if ([searchbuttons isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            cancelButton.enabled = YES;
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
    return YES;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)SearchBar{
    sortedArray = coachArr;
    [MyTableView reloadData];
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)sBar{
    sortedArray = coachArr;
    NSLog(@"didBegin Editing");
    
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    return YES;
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    NSLog(@"did end editing");
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"textdidchange:%@",searchText);
    sortedArray = coachArr;
    
    NSMutableArray* filteredArray = [[NSMutableArray alloc]init];
    NSPredicate *predicateV = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"DataID", searchText];
    NSArray* myarrayV = [sortedArray filteredArrayUsingPredicate:predicateV];
    for (NSString* str in myarrayV) {
        [filteredArray addObject:str];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"mobile", searchText];
    NSArray* myarray = [sortedArray filteredArrayUsingPredicate:predicate];
    for (NSString* str in myarray) {
        [filteredArray addObject:str];
    }
    NSPredicate *predicateI = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"car_number", searchText];
    NSArray* myarrayII = [sortedArray filteredArrayUsingPredicate:predicateI];
    for (NSString* str in myarrayII) {
        [filteredArray addObject:str];
    }
    NSPredicate *predicateII = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"car_brand", searchText];
    NSArray* myarrayIII = [sortedArray filteredArrayUsingPredicate:predicateII];
    for (NSString* str in myarrayIII) {
        [filteredArray addObject:str];
    }
    NSPredicate *predicateIII = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"username", searchText];
    NSArray* myarrayIV = [sortedArray filteredArrayUsingPredicate:predicateIII];
    for (NSString* str in myarrayIV) {
        [filteredArray addObject:str];
    }

    sortedArray = filteredArray;

    [MyTableView reloadData];

}
- (void)searchBarSearchButtonClicked:(UISearchBar *)sBar{
    [self performSelector:@selector(hideKeyboardWithSearchBar:)withObject:searchBar afterDelay:0];
}
- (void)hideKeyboardWithSearchBar:(UISearchBar *)sBar
{
    [sBar resignFirstResponder];
}

@end
