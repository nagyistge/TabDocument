//
//  HMDocumentController.m
//  DocumentTest
//
//  Created by Scott Horn on 24/05/2014.
//  Copyright (c) 2014 Scott Horn. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <objc/message.h>
#import "HMDocumentController.h"
#import "HMDocument.h"
#import "HMWindowController.h"

NSString* const HMDocumentNeedWindowNotification = @"HMDocumentNeedWindowNotification";
void* const HMDocumentCloseAllWindows = (void* const) &HMDocumentCloseAllWindows;

@implementation HMDocumentController

- (id)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleDocumentNeedWindowNotification:)
                   name:HMDocumentNeedWindowNotification
                 object:nil];
        
        _windowControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)handleDocumentNeedWindowNotification:(NSNotification *)notification
{
    HMDocument* doc = notification.object;
    HMWindowController *mainWindow = self.mainWindowController;
    [mainWindow addDocument:doc];
}

- (void)dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (HMWindowController*) mainWindowController
{
    HMWindowController* mainWindowController = [[[NSApplication sharedApplication] mainWindow] windowController];
    if (!mainWindowController) {
        mainWindowController = [self newWindowController];
    }
    return mainWindowController;
}

- (IBAction)newWindow:(id)sender
{
    HMWindowController* mainWindowController = [[[NSApplication sharedApplication] mainWindow] windowController];
    if (mainWindowController) {
        NSWindow* window = mainWindowController.window;
        if (![window makeFirstResponder:window]) {
            return; // only continue if we can end editing
        }
    }
    mainWindowController = [self newWindowController];
    [mainWindowController.window makeKeyAndOrderFront:nil];
    
    [NSApp sendAction:@selector(newDocument:) to:nil from:self];
}

- (HMWindowController *)newWindowController
{
    static NSPoint cascadeTopLeftSavedPoint = {0.0, 0.0};
    HMWindowController* newWindowController = [[HMWindowController alloc] initWithWindowNibName:@"Window"];
    cascadeTopLeftSavedPoint = [newWindowController.window cascadeTopLeftFromPoint:cascadeTopLeftSavedPoint];
    [self.windowControllers addObject:newWindowController];
    return newWindowController;
}

#pragma mark NSDocument Delegate

- (void)document:(NSDocument *)doc shouldClose:(BOOL)shouldClose contextInfo:(void  *)contextInfo
{
    if (contextInfo == HMDocumentCloseAllWindows) {
        if (shouldClose) {
            [doc close];
            HMDocument *nextDoc = [_enumerator nextObject];
            if (nextDoc) {
                [nextDoc canCloseDocumentWithDelegate:self
                                  shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                                          contextInfo:HMDocumentCloseAllWindows];
            } else {
                _closeAllCompletedBlock(self, YES);
                _closeAllCompletedBlock = NULL;
                _enumerator = nil;
            }
            
        } else {
            _closeAllCompletedBlock(self, NO);
            _closeAllCompletedBlock = NULL;
            _enumerator = nil;
        }
    }
}


#pragma mark NSDocumentController

- (void)closeAllDocumentsWithDelegate:(id)delegate didCloseAllSelector:(SEL)didCloseAllSelector contextInfo:(void *)contextInfo
{
    _closeAllCompletedBlock = ^(id me, BOOL didCloseAll){
        objc_msgSend(delegate, didCloseAllSelector, me, didCloseAll, contextInfo);
    };
    
    _enumerator = [[self.documents copy] objectEnumerator];
    [[_enumerator nextObject] canCloseDocumentWithDelegate:self
                                       shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                                               contextInfo:HMDocumentCloseAllWindows];
}


@end
