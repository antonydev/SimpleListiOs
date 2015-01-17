//
//  LazyImageLoader.h
//  ListView
//
//  Created by antonyouseph on 1/16/15.
//  Copyright (c) 2015 antonyouseph. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface LazyImageLoader : NSObject

@property (nonatomic, strong) Item  *itemObj;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@end
