//
//  RoundedPlayPauseWindow.h
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/20/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RoundedPlayPauseView;

@interface RoundedPlayPauseWindow : NSWindow

- (void)fadeInAndMakeKeyAndOrderFront:(BOOL)orderFront;
- (void)fadeOutAndOrderOut:(BOOL)orderOut;
- (void)changeAppearance;
- (void)showButtons;

@property (weak) IBOutlet RoundedPlayPauseView *roundedPlayPauseView;

@end
