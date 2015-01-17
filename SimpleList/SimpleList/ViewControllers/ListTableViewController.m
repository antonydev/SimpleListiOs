//
//  ListTableViewController.m
//  SimpleList
//
//  Created by antonyouseph on 1/16/15.
//  Copyright (c) 2015 antonyouseph. All rights reserved.
//

#import "ListTableViewController.h"
#import "ListCell.h"
#import "PTConstants.h"
#import "Item.h"
#import "LazyImageLoader.h"

@interface ListTableViewController ()<UIScrollViewDelegate>
@property (nonatomic, retain) AsyncRequest *request;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@end

@implementation ListTableViewController
@synthesize request=_request;
@synthesize refreshControl=_refreshControl;
@synthesize imageDownloadsInProgress=_imageDownloadsInProgress;
@synthesize dataDict=_dataDict;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Title"];

    self.request = [[AsyncRequest alloc]init];
    [self.request setDelegate:self];
    [self.request startRequestWithURL:[NSURL URLWithString:DRBOX_URL]];
    
    [self.tableView setDataSource:self];
    if ([self.tableView  respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    // Adding refresh controll in the table view controller
    UIRefreshControl  *locRefreshControl = [[UIRefreshControl alloc] init];
    locRefreshControl.tintColor = [UIColor blueColor];
    locRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [locRefreshControl addTarget:self action:@selector(reloadData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = locRefreshControl;
    [self.tableView addSubview:self.refreshControl];
}

// -------------------------------------------------------------------------------
//	dealloc
// -------------------------------------------------------------------------------
- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
    [_refreshControl release];
    [_imageDownloadsInProgress release];
    [_dataDict release];
    _request.delegate=nil;
    [_request release];
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	didReceiveMemoryWarning
// -------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    [self terminateAllDownloads];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
   // return [self.dataSourceArray count];
    return 1;
}
/*-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleString = nil;
    NSDictionary *dict = [self.dataSourceArray objectAtIndex:section];
    titleString = [dict objectForKey:LIST_TITLE];
    return titleString;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *itemArray = [self.dataDict objectForKey:ITEM_KEY];
    NSInteger intCount = [itemArray count];
    itemArray=nil;
    return intCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListCell *myCellView = nil;
    static NSString *cellIdentifier = @"ListCell";
    myCellView = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (myCellView == nil)
    {
        myCellView = (ListCell *) [[ListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSArray *itemArray = [self.dataDict objectForKey:ITEM_KEY];
    
    
    // Leave cells empty if there's no data yet
    if (itemArray > 0)
    {
        // Set up the cell representing the app
        Item *itemObj = [itemArray objectAtIndex:indexPath.row];
        
        myCellView.titleLabel.text = itemObj.titleString;
        CGFloat height = [self heightForText:itemObj.titleString withFontSize:17 width:320 ];
        [myCellView.titleLabel setFrame:CGRectMake(myCellView.titleLabel.frame.origin.x, myCellView.titleLabel.frame.origin.y, myCellView.titleLabel.frame.size.width, height)];
        [myCellView.thumbImageView setFrame:CGRectMake(200, myCellView.titleLabel.frame.origin.y+height+5, 100, 75)];
        myCellView.descLabel.text = itemObj.descString;
        CGFloat descHeight = [self heightForText:itemObj.descString withFontSize:15 width:190];
        if (descHeight != 0)
        {
            descHeight = descHeight+50;// Correction On height
        }
        [myCellView.descLabel setFrame: CGRectMake(3.0, height, 190, descHeight)];
        
        [myCellView.descLabel sizeToFit];
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!itemObj.thumbImage)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:itemObj forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            myCellView.thumbImageView.image = [UIImage imageNamed:@"News_Dummy_Image"];
        }
        else
        {
            myCellView.thumbImageView.image = itemObj.thumbImage;
        }
    }
    return myCellView;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalHeight = 0.0;;
    NSArray *itemArray = [self.dataDict objectForKey:ITEM_KEY];
    Item *itemObj = [itemArray objectAtIndex:indexPath.row];
    CGFloat titleHeight = [self heightForText:itemObj.titleString withFontSize:17 width:320 ];
    CGFloat descheight = [self heightForText:itemObj.descString withFontSize:15 width:190];
    totalHeight = titleHeight+descheight;
    if (totalHeight<50)
    {
        totalHeight = 70;
    }
    return totalHeight + 50;
}
#pragma mark Assynchronous request delegators
- (void) didStartURLRequest
{
    NSLog(@"Starting the the request");
}
- (void) didFinishURLRequestWithDataDict:(NSDictionary *) resultDict
{
    if (self.dataDict !=nil)
    {
        [self.dataDict release]; self.dataDict = nil;
    }
    self.dataDict = [[NSDictionary alloc]initWithDictionary:resultDict];
    NSString *titleString = [self.dataDict objectForKey:LIST_TITLE];
    if (titleString!=nil)
    {
         [self.navigationItem setTitle:titleString];
    }
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}
- (void) didFailURLRequestWithErrorMessage:(NSString *) errorMessage
{
    NSLog(@"Starting the the request:%@",errorMessage);
    [self.refreshControl endRefreshing];
}
#pragma mark Image loading for UITableViewCell
// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(Item *)itemObj forIndexPath:(NSIndexPath *)indexPath
{
    LazyImageLoader *imageLoader = (self.imageDownloadsInProgress)[indexPath];
    if (imageLoader == nil)
    {
        imageLoader = [[LazyImageLoader alloc] init];
        imageLoader.itemObj = itemObj;
        [imageLoader setCompletionHandler:^{
            ListCell *cell = (ListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            // Display the newly loaded image
            cell.thumbImageView.image = itemObj.thumbImage;
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
        }];
        (self.imageDownloadsInProgress)[indexPath] = imageLoader;
        [imageLoader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRowsforIndexPath:(NSIndexPath *) path
{
    NSArray *itemArray = [self.dataDict objectForKey:ITEM_KEY];
    
    if (itemArray.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            
            // NSArray *itemArray = [dict objectForKey:ITEM_KEY];
            Item *itemObj = (itemArray)[indexPath.row];
            
            if (!itemObj.thumbImage)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:itemObj forIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSArray *array = [self.tableView visibleCells];
    ListCell *cell = [array lastObject];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!decelerate)
    {
        [self loadImagesForOnscreenRowsforIndexPath:indexPath];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *array = [self.tableView visibleCells];
    ListCell *cell = [array lastObject];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self loadImagesForOnscreenRowsforIndexPath:indexPath];
    
}

#pragma mark Selectors
- (void)reloadData:(UIRefreshControl *)refreshControl
{
    if (!self.request.isDataLoading)
    {
        [self.request startRequestWithURL:[NSURL URLWithString:DRBOX_URL]];
    }
}
// -------------------------------------------------------------------------------
//	terminateAllDownloads
// -------------------------------------------------------------------------------
- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (CGFloat)heightForText:(NSString *)bodyText withFontSize:(int) fontSize width :(CGFloat) width
{
    UIFont *cellFont = [UIFont systemFontOfSize:fontSize];
    CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
    CGSize labelSize = [bodyText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat height = labelSize.height + 10;
    return height;
}
@end
