//
//  CustomCell.m
//  XCWMSG
//
//  Created by Elliekuri on 15/1/22.
//  Copyright (c) 2015年 xcw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomCell.h"

@implementation CustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end