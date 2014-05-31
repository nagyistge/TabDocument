//
//  HMDocumentController.h
//  DocumentTest
//
//  Created by Scott Horn on 24/05/2014.
//  Copyright (c) 2014 Scott Horn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* const HMDocumentNeedWindowNotification;
extern void* const HMDocumentCloseAllWindows;

typedef void (^HMCloseAllCompletedBlock)(id, BOOL);

@interface HMDocumentController : NSDocumentController {
    NSEnumerator *_enumerator;
    HMCloseAllCompletedBlock _closeAllCompletedBlock;
}

@property (nonatomic,strong,readonly) NSMutableArray* windowControllers;

@end
