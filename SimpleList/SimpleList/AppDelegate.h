//
//  AppDelegate.h
//  SimpleList
//
//  Created by antonyouseph on 1/16/15.
//  Copyright (c) 2015 antonyouseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTableViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) ListTableViewController *listView;

@end
