//
//  HMDocument.h
//  DocumentTest
//
//  Created by Scott Horn on 17/05/2014.
//  Copyright (c) 2014 Scott Horn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MMTabBarView/MMTabBarItem.h>

@class HMViewController;

@interface HMDocument : NSDocument <MMTabBarItem>

@property (assign) BOOL hasCloseButton;

@property (nonatomic,strong) HMViewController *viewController;
@property (nonatomic,strong) NSMutableString *fileContents;

@end
