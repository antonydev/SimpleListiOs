//
//  AsyncRequest.h
//  SimpleList
//
//  Created by antonyouseph on 1/16/15.
//  Copyright (c) 2015 antonyouseph. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AysincRequestDelegate<NSObject>
@optional
- (void) didStartURLRequest;
@required
- (void) didFinishURLRequestWithDataDict:(NSDictionary *) itemDict;
- (void) didFailURLRequestWithErrorMessage:(NSString *) errorMessage;
@end

@interface AsyncRequest : NSObject
{
 @private
    NSMutableData       *responseData;
    NSURLConnection     *urlConnection;
    NSURLRequest        *urlRequest;
}
@property (nonatomic,assign) id<AysincRequestDelegate> delegate;
@property (nonatomic,getter = isDataLoading) BOOL dataLoading;

- (void) startRequestWithURL : (NSURL *) requestURL;
@end
