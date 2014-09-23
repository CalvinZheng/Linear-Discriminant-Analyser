//
//  LDAAppDelegate.h
//  Linear Discriminant Analyser
//
//  Created by Calvin Zheng on 2014-09-13.
//  Copyright (c) 2014 Zheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LDAAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet NSTextField *textView;
@property (weak) IBOutlet NSTextField *degree;
- (IBAction)stepped:(NSStepper *)sender;

@end
