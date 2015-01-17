//
//  ListCell.h
//  ListView
//
//  Created by antonyouseph on 1/16/15.
//  Copyright (c) 2015 antonyouseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface ListCell : UITableViewCell


@property (nonatomic, retain) UILabel   *titleLabel;
@property (nonatomic, retain) UILabel   *descLabel;
@property (nonatomic, retain) UIImageView *thumbImageView;

- (void) setCellData:(Item *) item;

@end
