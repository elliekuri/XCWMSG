//
//  DetailView.h
//  XCWMSG
//
//  Created by xcw on 15/1/14.
//  Copyright (c) 2015年 xcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ImgScrollView.h"
#import "TapImageView.h"
#import "AndroidData.h"
@interface DetailView : UIViewController<UIScrollViewDelegate,TapImageViewDelegate,ImgScrollViewDelegate>

@property (strong, nonatomic)UILabel* RelatedInfo;

@property (strong, nonatomic) UIScrollView* TopView;

@property (strong, nonatomic) AVAudioPlayer *player;

@property (strong, nonatomic) AndroidData* Adata;

@property(strong,nonatomic)UIView* ClearView;

@end