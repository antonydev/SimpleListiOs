//
//  AsyncRequest.m
//  SimpleList
//
//  Created by antonyouseph on 1/16/15.
//  Copyright (c) 2015 antonyouseph. All rights reserved.
//

#import "AsyncRequest.h"
#import "PTConstants.h"
#import "Item.h"


@implementation AsyncRequest
@synthesize delegate;
@synthesize dataLoading;

#pragma mark NSURLConnection Delegate Methods

- (void) startRequestWithURL : (NSURL *) requestURL
{
    // Starts the url requeest using the given URL
    self.dataLoading = NO;
    urlRequest = [NSURLRequest requestWithURL:requestURL];
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    responseData = [[NSMutableData alloc] init];
    if ([self.delegate respondsToSelector:@selector(didStartURLRequest)])
    {
        [self.delegate didStartURLRequest];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Completes the connection request with successfull data
    self.dataLoading = YES;
    NSString *mystring = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding ];
    NSData *data = [mystring dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
    // ----------------------- Creates An Array Of Objects Starts ------------------->
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *sectionList = [[NSMutableDictionary alloc]init];
    NSString *title = [json objectForKey:LIST_TITLE];
    NSArray *itemArray = [json objectForKey:ITEM_KEY];
    NSMutableArray *itemMutArray = [[NSMutableArray alloc]init];
    for (NSDictionary *valDict in itemArray)
    {
        NSString *titleString = [valDict objectForKey:LIST_TITLE];
        if ([titleString isKindOfClass:[NSNull class]])
        {
            titleString = nil;
        }
        NSString *descString = [valDict objectForKey:ITEM_DESC];
        if ([descString isKindOfClass:[NSNull class]])
        {
            descString = nil;
        }
        NSString *imageURLString = [valDict objectForKey:ITEM_IMAGE_URL];
        if ([imageURLString isKindOfClass:[NSNull class]])
        {
            imageURLString = nil;
        }
        
        Item   *objItem = [[Item alloc] init];
        [objItem setTitleString:titleString];
        [objItem setDescString:descString];
        [objItem setImageURLString:imageURLString];
        
        [itemMutArray addObject:objItem];
        
        [objItem release]; objItem = nil;
        titleString = nil; descString = nil;imageURLString = nil;
    }
    
    [sectionList setObject:title forKey:LIST_TITLE];
    [sectionList setObject:itemMutArray forKey:ITEM_KEY];
    [resultArray addObject:sectionList];
    
    [sectionList release]; sectionList = nil;
    title = nil; itemArray = nil;
    [itemMutArray release]; itemMutArray = nil;
    
    
    
    NSArray *finalArray = [[[NSArray alloc]initWithArray:resultArray copyItems:YES]autorelease];
    [resultArray release]; resultArray = nil;
    //------------------------ Creates An Array Of Objects Ends <--------------------
    self.dataLoading = NO;
    if (error != nil )
    {
        if ([self.delegate respondsToSelector:@selector(didFailURLRequestWithErrorMessage:)])
        {
            [self.delegate didFailURLRequestWithErrorMessage:[error description]];
        }
    }
    else if ([self.delegate respondsToSelector:@selector(didFinishURLRequestWithDataDict:)])
    {
        [self.delegate didFinishURLRequestWithDataDict:finalArray];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.dataLoading = NO;
    if ([self.delegate respondsToSelector:@selector(didFailURLRequestWithErrorMessage:)])
    {
        [self.delegate didFailURLRequestWithErrorMessage:[error description]];
    }
    
}
-(void) dealloc
{
    [responseData release]; responseData = nil;
    self.delegate  = nil;
    urlRequest = nil;
    [urlConnection release]; urlConnection = nil;
    [super dealloc];
}

@end
