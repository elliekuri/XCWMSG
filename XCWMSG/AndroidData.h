//
//  AirportData.h
//  json
//
//  Created by boarding on 14-4-11.
//  Copyright (c) 2014年 boarding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AndroidData : NSObject

@property(nonatomic,strong)NSString* DataID;
@property(nonatomic,strong)NSString* check_report_id;
@property(nonatomic,strong)NSString* address;

@property(nonatomic,strong)NSString* car_brand;
@property(nonatomic,strong)NSString* car_series;
@property(nonatomic,strong)NSString* mobile;
@property(nonatomic,strong)NSString* car_number;

@property(nonatomic,strong)NSDictionary* image_url;
@property(nonatomic,strong)NSString* sound_url;
@property(nonatomic,strong)NSDictionary* remarks;

@property(nonatomic,strong)NSString* create_time;
@property(nonatomic,strong)NSString* username;

@end
