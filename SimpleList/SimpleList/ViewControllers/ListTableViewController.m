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

    _request = [[AsyncRequest alloc]init];
    [self.request setDelegate:self];
    [self.request startRequestWithURL:[NSURL URLWithString:DRBOX_URL]];
    
    [self.tableView setDataSource:self];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    // Adding refresh controll in the table view controller
    UIRefreshControl  *locRefreshControl = [[UIRefreshControl alloc] init];
    locRefreshControl.tintColor = [UIColor blueColor];
    locRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [locRefreshControl addTarget:self action:@selector(reloadData:) forControlEvents:UIControlEventValueChanged];
    _refreshControl = locRefreshControl;
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl beginRefreshing];
   // [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [locRefreshControl release];
    locRefreshControl= nil;
}

// -------------------------------------------------------------------------------
//	dealloc
// -------------------------------------------------------------------------------
- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
    [_refreshControl release];
    _imageDownloadsInProgress = nil;
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
        myCellView = [(ListCell *) [[ListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    NSArray *itemArray = [self.dataDict objectForKey:ITEM_KEY];
    
    
    // Leave cells empty if there's no data yet
    if (itemArray > 0)
    {
        // Set up the cell representing the app
        Item *itemObj = [itemArray objectAtIndex:indexPath.row];
        
        myCellView.titleLabel.text = itemObj.titleString;
        CGFloat height = [self heightForText:itemObj.titleString withFontSize:kTitleFontSize width:tableView.frame.size.width];
        [myCellView.titleLabel setFrame:CGRectMake(kCellPaddingLeft, myCellView.titleLabel.frame.origin.y, tableView.frame.size.width, height)];
        
        myCellView.descLabel.text = itemObj.descString;
        CGFloat descHeight = 0.0;
        descHeight = [self heightForText:itemObj.descString withFontSize:kDescFontSize width:tableView.frame.size.width-kCellPaddingRight-kCellImageWidth-kCellPaddingLeft];
        
        [myCellView.thumbImageView setFrame:CGRectMake(tableView.frame.size.width - kCellPaddingRight-kCellImageWidth, myCellView.titleLabel.frame.origin.y+height, kCellImageWidth, kCellImageHeight)];
        if (itemObj.imageURLString == nil)
        {
            [myCellView.thumbImageView setHidden:YES];
            descHeight = [self heightForText:itemObj.descString withFontSize:kDescFontSize width:tableView.frame.size.width-kCellPaddingRight-kCellPaddingLeft];
            if (descHeight != 0)
            {
                descHeight = descHeight+50;// Correction On height
            }
            [myCellView.descLabel setFrame: CGRectMake(kCellPaddingLeft, height, tableView.frame.size.width-kCellPaddingRight-kCellPaddingLeft, descHeight)];

        }
        else
        {
            descHeight = [self heightForText:itemObj.descString withFontSize:kDescFontSize width:tableView.frame.size.width-kCellPaddingRight-kCellPaddingLeft-kCellImageWidth];
            [myCellView.thumbImageView setHidden:NO];
            if (descHeight != 0)
            {
                descHeight = descHeight+50;// Correction On height
            }
            [myCellView.descLabel setFrame: CGRectMake(kCellPaddingLeft, height, tableView.frame.size.width-kCellPaddingRight-kCellImageWidth-kCellPaddingLeft, descHeight)];
            
        }
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

// -------------------------------------------------------------------------------
//	Returns the height of the each row
// -------------------------------------------------------------------------------
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalHeight = 0.0;;
    NSArray *itemArray = [self.dataDict objectForKey:ITEM_KEY];
    Item *itemObj = [itemArray objectAtIndex:indexPath.row];
    CGFloat titleHeight = [self heightForText:itemObj.titleString withFontSize:kTitleFontSize width:tableView.frame.size.width-kCellPaddingLeft-kCellPaddingRight];
    CGFloat descheight = [self heightForText:itemObj.descString withFontSize:kDescFontSize width:tableView.frame.size.width - kCellPaddingRight-kCellPaddingLeft - kCellImageWidth];
    
    totalHeight = totalHeight+titleHeight;
    if (itemObj.imageURLString == nil)
    {
        descheight = [self heightForText:itemObj.descString withFontSize:kDescFontSize width:tableView.frame.size.width - kCellPaddingRight - kCellPaddingLeft];
        return totalHeight + descheight + 10;
    }
    totalHeight = titleHeight+descheight;
    
    if (totalHeight< titleHeight+ 75)
    {
        return  titleHeight+75+30;
    }
    return totalHeight + 50;
}
#pragma mark UITableViewDelegate
// -------------------------------------------------------------------------------
//	Extends the margins to both ends
// -------------------------------------------------------------------------------
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark Assynchronous request delegators
- (void) didStartURLRequest
{
   // NSLog(@"Starting the the request");
}
- (void) didFinishURLRequestWithDataDict:(NSDictionary *) resultDict
{
    if (self.dataDict !=nil)
    {
        [_dataDict release]; _dataDict = nil;
    }
    _dataDict = [[NSDictionary alloc]initWithDictionary:resultDict];
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
// -------------------------------------------------------------------------------
//	Send the refresh request
// -------------------------------------------------------------------------------
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
// -------------------------------------------------------------------------------
//	Find the height of the label
// -------------------------------------------------------------------------------
- (CGFloat)heightForText:(NSString *)bodyText withFontSize:(int) fontSize width :(CGFloat) width
{
    UIFont *cellFont = [UIFont systemFontOfSize:fontSize];
    CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
    CGSize labelSize = [bodyText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat height = labelSize.height + 10;
    return height;
}
// -------------------------------------------------------------------------------
//	Capture the rotation and reload the table view
// -------------------------------------------------------------------------------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];
}

@end
