//
//  DetailView.m
//  XCWMSG
//
//  Created by xcw on 15/1/14.
//  Copyright (c) 2015年 xcw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailView.h"
#import <QuartzCore/QuartzCore.h>
#import "ImgScrollView.h"
#import "TapImageView.h"
#import "UIImageView+WebCache.h"
@interface DetailView ()
{
    UIButton* voiceBtn;
    CGFloat lastLocation;
    UIImageView* volume;
    int imageCount;
    
    UIScrollView *myScrollView;
    NSInteger currentIndex;
    
    UIView *markView;
    UIView *scrollPanel;
    ImgScrollView *lastImgScrollView;
    UITableViewCell *tapCell;
    
    TapImageView *tapView;
    NSMutableArray* imgArr;
}
@end

@implementation DetailView;
@synthesize TopView,RelatedInfo,player,ClearView;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor= [UIColor whiteColor];
    
    [self initImgArr];

    lastLocation = 140;
    
    [self initTopView];
    
}


-(void)initImgArr{
    NSDictionary* MyDic = [[NSDictionary alloc]init];
    imgArr = [[NSMutableArray alloc]init];
    MyDic = (NSDictionary*)self.Adata.image_url;
    NSArray* arr = [MyDic allKeys];
    
    if ([[MyDic objectForKey:@"0"] isEqualToString:@""]) {
        NSLog(@"succeed");
        imageCount = 0;
    }else{
        NSLog(@"%@",arr);
        imageCount = (int)arr.count;
    }
    
        if (imageCount!=0) {
            for(NSString* str in arr){
                NSMutableString* imgurl = [[NSMutableString alloc]initWithFormat:@"http://www.xieche.com.cn/UPLOADS/Checkremarks/img/"];
                [imgurl appendFormat:@"%@",[MyDic objectForKey:str]];
                [imgArr addObject:imgurl];
                imgurl = nil;
            }
        }
}

-(void)initTopView{

    NSString* Ustr = [[NSString alloc]initWithFormat:@"http://www.xieche.com.cn/UPLOADS/Checkremarks/wav/%@",self.Adata.sound_url];
    NSData* data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:Ustr]];
    player = [[AVAudioPlayer alloc]initWithData:data error:nil ];//使用NSData创建
    player.volume =0.8;


    //top
    TopView= [[UIScrollView alloc]init];
    //self.ScrollViewbg.contentInset = UIEdgeInsetsMake(0, -320, 0, 0);
    TopView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width-20,[UIScreen mainScreen].bounds.size.height);
    TopView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x+10, [UIScreen mainScreen].bounds.origin.y+10, [UIScreen mainScreen].bounds.size.width-20,[UIScreen mainScreen].bounds.size.height);
    TopView.pagingEnabled =NO;
    //self.ScrollViewbg.bounces = NO;
    TopView.showsHorizontalScrollIndicator= NO;
    TopView.showsVerticalScrollIndicator= NO;
    TopView.delegate = self;
    TopView.backgroundColor = [UIColor whiteColor];
    TopView.layer.borderWidth = 0.5;
    TopView.layer.cornerRadius = 8;
    TopView.layer.masksToBounds = YES;
    TopView.layer.borderColor =(__bridge CGColorRef)([UIColor colorWithRed:0 green:0 blue:0 alpha:30]);
    [self.view addSubview:TopView];
    
    NSDictionary* remarkdic = [[NSDictionary alloc]init];
    remarkdic = self.Adata.remarks;
    NSArray* arr = [remarkdic allKeys];
    
    if (imageCount!=0) {

    for (int index = 0; index < imageCount-1; index++)
    {
        CGFloat Length = TopView.frame.size.height/2-90;
        TopView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width-20,[UIScreen mainScreen].bounds.size.height+Length*index+15*[arr count]);

        tapView = [[TapImageView alloc] initWithFrame:CGRectMake(2,150+Length*index, TopView.frame.size.width-4, TopView.frame.size.height/2-100)];
        tapView.t_delegate = self;
        [tapView sd_setImageWithURL:[NSURL URLWithString:[imgArr objectAtIndex:index]] placeholderImage:[UIImage imageNamed:@"placeholder"] options:0];
        tapView.tag = index;
        tapView.identifier= self.view;
        tapView.layer.cornerRadius = 8;
        tapView.layer.masksToBounds = YES;
        [TopView addSubview:tapView];
    
       // lastLocation = Length*imageCount-120;
        lastLocation = 60+Length*index+TopView.frame.size.height/2;
    }
    }else{
        UILabel* npic = [[UILabel alloc]initWithFrame:CGRectMake(TopView.frame.origin.x+2, 155,TopView.frame.size.width-4, 20)];
        npic.text = @"<---------------无图片--------------->";
        npic.font =[UIFont fontWithName:@"Helvetica" size:14];
        npic.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
        [TopView addSubview:npic];
    }
    [self initFullScreenScrollView];
    

    int LocIndex = 0;
    for (NSString* str in arr) {
        
        UILabel* address= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+2,TopView.frame.origin.y+60+25*LocIndex+lastLocation, [UIScreen mainScreen].bounds.size.width-22,20)];
        address.font = [UIFont fontWithName:@"Helvetica" size:16];
        address.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
        NSString* addresstext = [[NSString alloc]initWithFormat:@"%@ : %@",str,[remarkdic objectForKey:str]];
        NSLog(@"%@",addresstext);
        address.text = addresstext;
        address.textAlignment = NSTextAlignmentLeft;
        address.numberOfLines = 0;
        [TopView addSubview:address];
        ++LocIndex;
    }
    
    
    UILabel* check_report= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+2,TopView.frame.origin.y, [UIScreen mainScreen].bounds.size.width-22,20)];
    check_report.font = [UIFont fontWithName:@"Helvetica" size:16];
    check_report.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
    NSString* checktext = [[NSString alloc]initWithFormat:@"检查报告ID:%@",self.Adata.check_report_id];
    check_report.text =checktext;
    check_report.textAlignment = NSTextAlignmentLeft;
    check_report.numberOfLines = 0;
    [TopView addSubview:check_report];
    
    UILabel* address= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+2,TopView.frame.origin.y+25, [UIScreen mainScreen].bounds.size.width-22,20)];
    address.font = [UIFont fontWithName:@"Helvetica" size:16];
    address.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
    NSString* addresstext = [[NSString alloc]initWithFormat:@"地址:%@",self.Adata.address];
    address.text = addresstext;
    address.textAlignment = NSTextAlignmentLeft;
    address.numberOfLines = 0;
    [TopView addSubview:address];
    
    UILabel* create_time= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+170,TopView.frame.origin.y, [UIScreen mainScreen].bounds.size.width-22,20)];
    create_time.font = [UIFont fontWithName:@"Helvetica" size:16];
    create_time.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
    NSString* createtext = [[NSString alloc]initWithFormat:@"订单号:%@",self.Adata.DataID];
    create_time.text =createtext;
    create_time.textAlignment = NSTextAlignmentLeft;
    create_time.numberOfLines = 0;
    [TopView addSubview:create_time];
    
    UILabel* car_brand= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+2,TopView.frame.origin.y+75, [UIScreen mainScreen].bounds.size.width-22,20)];
    car_brand.font = [UIFont fontWithName:@"Helvetica" size:16];
    car_brand.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
    NSString* carbrand = [[NSString alloc]initWithFormat:@"车系:%@ - %@",self.Adata.car_brand,self.Adata.car_series];
    car_brand.text =carbrand;
    car_brand.textAlignment = NSTextAlignmentLeft;
    car_brand.numberOfLines = 0;
    [TopView addSubview:car_brand];
    
//    UILabel* car_series= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+160,TopView.frame.origin.y+50, [UIScreen mainScreen].bounds.size.width-22,20)];
//    car_series.font = [UIFont fontWithName:@"Helvetica" size:16];
//    car_series.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
//    NSString* carseries = [[NSString alloc]initWithFormat:@"车系:%@",self.Adata.car_series];
//    car_series.text =carseries;
//    car_series.textAlignment = NSTextAlignmentLeft;
//    car_series.numberOfLines = 0;
//    [TopView addSubview:car_series];
    
    UILabel* Mastermobile= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+2,TopView.frame.origin.y+100, [UIScreen mainScreen].bounds.size.width-22,20)];
    Mastermobile.font = [UIFont fontWithName:@"Helvetica" size:16];
    Mastermobile.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
    Mastermobile.text = @"车主手机:";
    Mastermobile.textAlignment = NSTextAlignmentLeft;
    Mastermobile.numberOfLines = 0;
    [TopView addSubview:Mastermobile];
    
    UIButton *mobile= [UIButton buttonWithType:UIButtonTypeCustom];
    [mobile setFrame:CGRectMake(TopView.frame.origin.x+73,TopView.frame.origin.y+100,100,20)];
    mobile.adjustsImageWhenHighlighted = NO;
    [mobile setTitle:self.Adata.mobile forState:UIControlStateNormal];
    [mobile setTitleColor:[UIColor colorWithRed:51.0/255.0 green:133.0/255.0 blue:255.0/255.0 alpha:100] forState:UIControlStateNormal];
    [mobile.titleLabel setFont:[UIFont fontWithName:@"Arial" size:16]];
    [mobile addTarget:self action:@selector(TakeACall) forControlEvents:UIControlEventTouchUpInside];
    [TopView addSubview:mobile];
    
    UITapGestureRecognizer *tapGestureTel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TakeACall)];
    [mobile addGestureRecognizer:tapGestureTel];
    
    UILabel* car_number= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+170,TopView.frame.origin.y+50, [UIScreen mainScreen].bounds.size.width-22,20)];
    car_number.font = [UIFont fontWithName:@"Helvetica" size:16];
    car_number.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
    NSString* carnumber = [[NSString alloc]initWithFormat:@"车牌:%@",self.Adata.car_number];
    car_number.text =carnumber;
    car_number.textAlignment = NSTextAlignmentLeft;
    car_number.numberOfLines = 0;
    [TopView addSubview:car_number];
    
    UILabel* username= [[UILabel alloc] initWithFrame:CGRectMake(TopView.frame.origin.x+2,TopView.frame.origin.y+50, [UIScreen mainScreen].bounds.size.width-22,20)];
    username.font = [UIFont fontWithName:@"Helvetica" size:16];
    username.textColor = [UIColor colorWithRed:25.0/255.0 green:41.0/255.0 blue:61.0/255.0 alpha:100];
    NSString* usernamestr = [[NSString alloc]initWithFormat:@"车主:%@",self.Adata.username];
    username.text =usernamestr;
    username.textAlignment = NSTextAlignmentLeft;
    username.numberOfLines = 0;
    [TopView addSubview:username];

    if (![self.Adata.sound_url isEqualToString:@""]) {
        [self addsound];
    }
    
}
-(void)addsound
{
    
    //voice
    volume = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_animation_white3.png"]];
    volume.frame = CGRectMake(2, 5, 18, 20);
    volume.animationImages = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"chat_animation_white1"],
                              [UIImage imageNamed:@"chat_animation_white2"],
                              [UIImage imageNamed:@"chat_animation_white3"],nil];
    volume.animationDuration = 1;
    volume.animationRepeatCount = 0;
    
    voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [voiceBtn setFrame:CGRectMake(TopView.frame.origin.x, lastLocation
                                  , 130, 30)];
    
    [voiceBtn addTarget:self action:@selector(PlayAv) forControlEvents:UIControlEventTouchUpInside];
    voiceBtn.backgroundColor =[[UIColor alloc]initWithRed:3.0f/255.0f green:41.0f/255.0f blue:81.0f/255.0f alpha:1.0f];
    voiceBtn.alpha = 1;
    
    voiceBtn.layer.borderWidth = 0.5;
    voiceBtn.layer.cornerRadius = 3;
    voiceBtn.layer.masksToBounds = YES;
    voiceBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    voiceBtn.adjustsImageWhenHighlighted = NO;
    voiceBtn.selected = NO;
    [voiceBtn addSubview:volume];
    [TopView addSubview:voiceBtn];
    
    NSTimeInterval duration = player.duration;//获取持续时间
    UILabel* TimeDur = [[UILabel alloc]initWithFrame:CGRectMake(TopView.frame.origin.x+135,lastLocation,80, 30)];
    TimeDur.textColor = [[UIColor alloc]initWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    NSString *Dur= [[[NSString alloc]initWithFormat:@"%f",duration] substringToIndex:4];
    NSMutableString* dur =  [[NSMutableString alloc]initWithFormat:@"%@ ",Dur];
    [dur appendString:@"s"];
    NSLog(@"%@",dur);
    TimeDur.text = dur;
    [TimeDur setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    [TimeDur setBackgroundColor:[UIColor clearColor]];
    [TopView addSubview:TimeDur];
}

-(void)initFullScreenScrollView{
    scrollPanel = [[UIView alloc] initWithFrame:self.view.bounds];
    scrollPanel.backgroundColor = [UIColor clearColor];
    scrollPanel.alpha = 0;
    [self.view addSubview:scrollPanel];
    
    markView = [[UIView alloc] initWithFrame:scrollPanel.bounds];
    markView.backgroundColor = [UIColor blackColor];
    markView.alpha = 0.0;
    [scrollPanel addSubview:markView];
    
    myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollPanel addSubview:myScrollView];
    myScrollView.pagingEnabled = YES;
    myScrollView.delegate = self;
    CGSize contentSize = myScrollView.contentSize;
    contentSize.height = self.view.bounds.size.height;
    contentSize.width = 320;
    myScrollView.contentSize = contentSize;
}
-(void)PlayAv{
    if (voiceBtn.selected == NO) {
        voiceBtn.selected = YES;
        [player prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
        [player play];//播放
        [volume startAnimating];
    }else{
        [player stop];//停止
        voiceBtn.selected = NO;
        [volume stopAnimating];
    }
}

-(void)avPlayAction{
    NSLog(@"timer");
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)avplayer successfully:(BOOL)flag
{
    //播放结束时执行的动作
  //  [audioButton setTitle:@"Play Audio File" forState:UIControlStateNormal];
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)avplayer error:(NSError *)error;
{
    //解码错误执行的动作
    NSLog(@"%@",error);
}


- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)avplayer;
{
    //处理中断的代码
    [player stop];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)avplayer
{
    [player play];
}


#pragma 
#pragma FullScreen
#pragma mark -
#pragma mark - custom method
- (void) addSubImgView
{
    [self.navigationController setNavigationBarHidden:YES animated:TRUE];
    for (UIView *tmpView in myScrollView.subviews)
    {
        [tmpView removeFromSuperview];
    }
    
    for (int i = 0; i < 1; i ++)
    {
        if (i == currentIndex)
        {
            continue;
        }
        
        TapImageView *tmpView = (TapImageView *)[tapCell viewWithTag:10 + i];
        
        //转换后的rect
        CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
        
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){i*myScrollView.bounds.size.width,0,myScrollView.bounds.size}];
        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:tmpView.image];
        [myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = self;
        
        [tmpImgScrollView setAnimationRect];
    }
}

- (void) setOriginFrame:(ImgScrollView *) sender
{
    [UIView animateWithDuration:0.4 animations:^{
        [sender setAnimationRect];
        markView.alpha = 1.0;
    }];
}

#pragma mark -
#pragma mark - custom delegate
- (void) tappedWithObject:(id)sender
{
    
    [self.view bringSubviewToFront:scrollPanel];
    scrollPanel.alpha = 1.0;
    
    TapImageView *tmpView = sender;
    currentIndex = tmpView.tag - 10;
    
    tapCell = tmpView.identifier;
    
    //转换后的rect
    CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
    
    CGPoint contentOffset = myScrollView.contentOffset;
    contentOffset.x = currentIndex*320;
    myScrollView.contentOffset = contentOffset;
    
    //添加
    [self addSubImgView];
    
    ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:(CGRect){contentOffset,myScrollView.bounds.size}];
    [tmpImgScrollView setContentWithFrame:convertRect];
    [tmpImgScrollView setImage:tmpView.image];
    [myScrollView addSubview:tmpImgScrollView];
    tmpImgScrollView.i_delegate = self;
    
    [self performSelector:@selector(setOriginFrame:) withObject:tmpImgScrollView afterDelay:0.1];
}

- (void) tapImageViewTappedWithObject:(id)sender
{
    
    ImgScrollView *tmpImgView = sender;
    
    [UIView animateWithDuration:0.5 animations:^{
        markView.alpha = 0;
        [tmpImgView rechangeInitRdct];
    } completion:^(BOOL finished) {
        scrollPanel.alpha = 0;
    }];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
}

-(void)TakeACall{
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"" message:self.Adata.mobile delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
    [error show];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1){
        NSString* phonenumber = [[NSString alloc]initWithFormat:@"tel://%@",self.Adata.mobile];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenumber]];
    }
}

#pragma mark -
#pragma mark - scroll delegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}


@end

