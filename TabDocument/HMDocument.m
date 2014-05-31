//
//  HMDocument.m
//  DocumentTest
//
//  Created by Scott Horn on 17/05/2014.
//  Copyright (c) 2014 Scott Horn. All rights reserved.
//

#import "HMDocument.h"
#import "HMDocumentController.h"
#import "HMWindowController.h"

@implementation HMDocument

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.hasCloseButton = YES;
        self.fileContents = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)makeWindowControllers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HMDocumentNeedWindowNotification
                                                        object:self];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSLog(@"Saving %@", self.fileContents);
    return [self.fileContents dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    self.fileContents = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Loaded %@", self.fileContents);
    return YES;
}

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
    if (contextInfo == HMWindowControllerCloseTab || contextInfo == HMWindowControllerCloseAllTabs
        || contextInfo == HMDocumentCloseAllWindows) {
        
        [super canCloseDocumentWithDelegate:delegate
                        shouldCloseSelector:shouldCloseSelector
                                contextInfo:contextInfo];
        
    } else {
        HMFinishedClosingBlock block = ^(BOOL closedAll){
            [super canCloseDocumentWithDelegate:delegate
                            shouldCloseSelector:shouldCloseSelector
                                    contextInfo:contextInfo];
        };
        HMWindowController *windowController = (HMWindowController *)self.windowControllers[0];
        [windowController closeAllTabsWithBlock:[block copy]];
    }
}

- (void)close
{
    for (HMWindowController *controller in self.windowControllers) {
        [controller closeTabWithDocument:self];
        [self removeWindowController:controller];
    }
    [self setWindow:nil];
    [self setViewController:nil];
    
    [super close];
}

@end
