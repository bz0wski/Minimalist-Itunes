//
//  CustomMinimalistApplication.h
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 3/19/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>
#import "RoundedPlayPauseView.h"

@class RoundedPlayPauseWindow;

int CustomMinimalistApplicationMain(int argc, const char* argv[]);

@interface CustomMinimalistApplication : NSApplication 

@property (weak,nonatomic) RoundedPlayPauseWindow * roundedskipBtnsWindow;

@end
