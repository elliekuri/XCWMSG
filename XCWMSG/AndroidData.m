//
//  AirportData.m
//  json
//
//  Created by boarding on 14-4-11.
//  Copyright (c) 2014年 boarding. All rights reserved.
//

#import "AndroidData.h"

@implementation AndroidData

-(void)encodeWithCoder:(NSCoder *)aCoder{
    //encode properties/values
    [aCoder encodeObject:self.DataID forKey:@"DataID"];
    [aCoder encodeObject:self.check_report_id forKey:@"check_report_id"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.car_brand forKey:@"car_brand"];
    [aCoder encodeObject:self.car_series forKey:@"car_series"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.car_number forKey:@"car_number"];
    
    [aCoder encodeObject:self.image_url forKey:@"image_url"];
    [aCoder encodeObject:self.sound_url forKey:@"sound_url"];
    [aCoder encodeObject:self.remarks forKey:@"remarks"];
    [aCoder encodeObject:self.create_time forKey:@"create_time"];
    [aCoder encodeObject:self.username forKey:@"username"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if((self = [super init])) {
        //decode properties/values
        self.DataID = [aDecoder decodeObjectForKey:@"DataID"];
        self.check_report_id = [aDecoder decodeObjectForKey:@"check_report_id"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.car_brand = [aDecoder decodeObjectForKey:@"car_brand"];
        self.car_series = [aDecoder decodeObjectForKey:@"car_series"];
        self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
        self.car_number = [aDecoder decodeObjectForKey:@"car_number"];
        self.image_url = [aDecoder decodeObjectForKey:@"image_url"];
        
        self.sound_url = [aDecoder decodeObjectForKey:@"sound_url"];
        self.remarks = [aDecoder decodeObjectForKey:@"remarks"];
        self.create_time = [aDecoder decodeObjectForKey:@"create_time"];
        self.username = [aDecoder decodeObjectForKey:@"username"];

    }
    
    return self;
}
@end
