//
//  HMWindowController.h
//  DocumentTest
//
//  Created by Scott Horn on 17/05/2014.
//  Copyright (c) 2014 Scott Horn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MMTabBarView/MMTabBarView.h>

@class HMDocument;

extern void* const HMWindowControllerCloseTab;
extern void* const HMWindowControllerCloseAllTabs;
typedef void (^HMFinishedClosingBlock)(BOOL);

@interface HMWindowController : NSWindowController <NSWindowDelegate, MMTabBarViewDelegate> {
    NSEnumerator *_enumerator;
    HMFinishedClosingBlock _finishedClosingBlock;
}

@property (nonatomic,strong,readonly) NSMutableSet* documents;
@property (weak) IBOutlet MMTabBarView *tabBar;
@property (weak) IBOutlet NSTabView *tabView;

- (void)addDocument:(HMDocument*)doc;
- (IBAction)closeDocument:(id)sender;
- (IBAction)closeWindow:(id)sender;
- (IBAction)showNextTab:(id)sender;
- (IBAction)showPrevTab:(id)sender;
- (void) closeAllTabsWithBlock:(HMFinishedClosingBlock)block;
- (void) closeTabWithDocument:(HMDocument *)document;
@end
