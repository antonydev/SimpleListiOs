//
//  ListCell.m
//  ListView
//
//  Created by antonyouseph on 1/16/15.
//  Copyright (c) 2015 antonyouseph. All rights reserved.
//

#import "ListCell.h"
#import "PTConstants.h"


@implementation ListCell

@synthesize titleLabel=_titleLabel;
@synthesize descLabel=_descLabel;
@synthesize thumbImageView=_thumbImageView;

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setTextColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:.75]];
        //[self.titleLabel setBackgroundColor:[UIColor grayColor]];
        [self.titleLabel setFont:[UIFont fontWithName:@"ArialUnicodeMS" size:20.0f]];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleLabel setFrame:CGRectMake(3.0, 3.0, 320, 0)];
        [self.titleLabel setNumberOfLines:100];
        [self.contentView addSubview:self.titleLabel];
        
        _descLabel = [[UILabel alloc] init];
        [self.descLabel setTextColor:[UIColor blackColor]];
        //[self.descLabel setBackgroundColor:[UIColor grayColor]];
        [self.descLabel setFont:[UIFont fontWithName:@"ArialUnicodeMS" size:15.0f]];
        [self.descLabel setFrame:CGRectMake(3.0, 3.0, 0.0, 40)];
        [self.descLabel setNumberOfLines:100];
        [self.contentView addSubview:self.descLabel];
        
        _thumbImageView = [[UIImageView alloc] init];
        [self.thumbImageView setFrame:CGRectMake(3, 3, 220, 0.0)];
        [self.thumbImageView setImage:[UIImage imageNamed:@"News_Dummy_Image"]];
        [self.contentView addSubview:self.thumbImageView];
    }
    return self;
}
- (void) setCellData:(Item *) item
{
   // NSString *titleString = item.titleString;
   // NSString *descString = item.descString;
   // NSString *imageURL = item.imageURLString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) dealloc
{
    [super dealloc];
    [_titleLabel release]; _titleLabel= nil;
    [_descLabel release]; _descLabel =nil;
    [_thumbImageView release]; _thumbImageView=nil;
}

@end
