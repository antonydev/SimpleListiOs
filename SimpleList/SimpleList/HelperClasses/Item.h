//
//  Item.h
//  SimpleList
//
//  Created by antonyouseph on 1/16/15.
//  Copyright (c) 2015 antonyouseph. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) NSString *descString;
@property (nonatomic, strong) NSString *imageURLString;

@end
