//
//  HMViewController.h
//  DocumentTest
//
//  Created by Scott Horn on 24/05/2014.
//  Copyright (c) 2014 Scott Horn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HMDocument;

@interface HMViewController : NSViewController

- (id) initWithDocument:(HMDocument *)document;

@property (weak) HMDocument *document;
@property (assign) IBOutlet NSTextView *textView;

@end
