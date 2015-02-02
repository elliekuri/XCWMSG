//
//  CustomCell.h
//  XCWMSG
//
//  Created by Elliekuri on 15/1/22.
//  Copyright (c) 2015年 xcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UIImageView* circle;
@property (strong, nonatomic) IBOutlet UILabel *FirstTitle;
@property (strong, nonatomic) IBOutlet UILabel *SubTitle;
@property (strong, nonatomic) IBOutlet UILabel *DetailTitle;
@property (strong, nonatomic) IBOutlet UILabel *CarBan;

@property (strong, nonatomic) IBOutlet UILabel *CarNum;
@end