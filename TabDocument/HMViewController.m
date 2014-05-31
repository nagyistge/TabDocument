//
//  HMViewController.m
//  DocumentTest
//
//  Created by Scott Horn on 24/05/2014.
//  Copyright (c) 2014 Scott Horn. All rights reserved.
//

#import "HMViewController.h"
#import "HMDocument.h"

@implementation HMViewController

- (id) initWithDocument:(HMDocument *)document
{
    self = [super initWithNibName:@"View" bundle:nil];
    if (self) {
        _document = document;
    }
    return self;
}

@end
