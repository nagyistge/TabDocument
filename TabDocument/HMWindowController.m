//
//  HMWindowController.m
//  DocumentTest
//
//  Created by Scott Horn on 17/05/2014.
//  Copyright (c) 2014 Scott Horn. All rights reserved.
//

#import "HMWindowController.h"
#import "HMDocument.h"
#import "HMViewController.h"

void* const HMWindowControllerCloseTab = (void* const)&HMWindowControllerCloseTab;
void* const HMWindowControllerCloseAllTabs = (void* const) &HMWindowControllerCloseAllTabs;

@implementation HMWindowController

-(id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        _documents = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setDelegate:self];
    for (HMDocument *doc in self.documents) {
        [self addViewWithDocument:doc];
    }
    [self.tabBar setDelegate:self];
}

- (void)closeWindow:(id)sender
{
    [self.window close];
}

- (void)addDocument:(HMDocument*)doc
{
    if ([self.documents containsObject:doc]) {
        return;
    }
    
    [self.documents addObject:doc];
    
    if (self.isWindowLoaded) {
        [self addViewWithDocument:doc];
    }
}

- (void) addViewWithDocument:(HMDocument*)document
{
    HMViewController *viewController = [[HMViewController alloc] initWithDocument:document];
    document.viewController = viewController;
    
    NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:document];
    [item bind:@"label" toObject:document withKeyPath:@"displayName" options:nil];
    
    [item setView:viewController.view];
    [item setInitialFirstResponder:viewController.textView];
    
    [self.tabView addTabViewItem:item];
    [self.tabView selectTabViewItem:item];
    
    [document addWindowController:self];
}

- (BOOL)validateUserInterfaceItem:(id)anItem
{
    SEL theAction = [anItem action];
    if (theAction == @selector(closeDocument:)) {
        return [self.tabBar selectedTabViewItem] != nil;
    } else if (theAction == @selector(showNextTab:) || theAction == @selector(showPrevTab:)) {
        return [self.tabView numberOfTabViewItems] > 1;
    }
    return YES;
}

- (void)closeDocument:(id)sender
{
    NSTabViewItem *item = [self.tabBar selectedTabViewItem];
    if (item) {
        [self tabView:self.tabView shouldCloseTabViewItem:item];
    }
}

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    HMDocument *doc = [tabViewItem identifier];
    [doc canCloseDocumentWithDelegate:self
                  shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                          contextInfo:HMWindowControllerCloseTab];
    return NO;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    HMDocument *document = [tabViewItem identifier];
    
    [self setDocument:nil];
    [document addWindowController:self];
    
    [self.window makeFirstResponder:document.viewController.textView];
}

- (void)addNewTabToTabView:(NSTabView *)aTabView
{
    [NSApp sendAction:@selector(newDocument:) to:nil from:self];
}

- (void) closeAllTabsWithBlock:(HMFinishedClosingBlock)finishedClosingBlock
{
    if ([self.documents count] < 1) {
        finishedClosingBlock(YES);
    } else {
        _finishedClosingBlock = finishedClosingBlock;
        _enumerator = [self.documents objectEnumerator];
        [[_enumerator nextObject] canCloseDocumentWithDelegate:self
                                           shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                                                   contextInfo:HMWindowControllerCloseAllTabs];
    }
    
}

- (void) closeTabWithDocument:(HMDocument *)document
{
    NSTabViewItem *thisItem;
    for( NSTabViewItem *item in [self.tabView tabViewItems]) {
        if ([item identifier] == document) {
            thisItem = item;
            break;
        }
    }
    if (thisItem) {
        [self.tabView removeTabViewItem:thisItem];
    }
}

- (void)document:(NSDocument *)document shouldClose:(BOOL)shouldClose contextInfo:(void *)contextInfo
{
    if(shouldClose) {
        [self closeTabWithDocument:(HMDocument *)document];
        
        HMDocument *doc = (HMDocument *) document;
        [self.documents removeObject:doc];
        [doc removeWindowController:self];
        [doc close];
        
        if (contextInfo == HMWindowControllerCloseAllTabs) {
            id item = [_enumerator nextObject];
            if (item) {
                [item canCloseDocumentWithDelegate:self
                               shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                                       contextInfo:HMWindowControllerCloseAllTabs];
            } else {
                _finishedClosingBlock(YES);
                _enumerator = nil;
                _finishedClosingBlock = NULL;
            }
        }
    } else {
        if (contextInfo == HMWindowControllerCloseAllTabs) {
            _finishedClosingBlock(NO);
            _enumerator = nil;
            _finishedClosingBlock = NULL;
        }
    }
}

- (void)setDocumentEdited:(BOOL)dirtyFlag
{
    for (NSDocument *doc in self.documents) {
        if (doc.isDocumentEdited) {
            [super setDocumentEdited:YES];
            return;
        }
    }
    [super setDocumentEdited:NO];
}


- (IBAction)showNextTab:(id)sender
{
    NSTabView *tabView = self.tabView;
    if ([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] < [tabView numberOfTabViewItems] - 1) {
        [tabView selectNextTabViewItem:self];
    } else {
        [tabView selectFirstTabViewItem:self];
    }
}

- (IBAction)showPrevTab:(id)sender
{
    NSTabView *tabView = self.tabView;
    if ([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] > 0) {
        [tabView selectPreviousTabViewItem:self];
    } else {
        [tabView selectLastTabViewItem:self];
    }
}

@end
