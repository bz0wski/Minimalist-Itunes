//
//  RoundedPlayPauseWindow.m
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/20/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import "RoundedPlayPauseWindow.h"

@implementation RoundedPlayPauseWindow{
    NSTimeInterval delay;
    NSTimer *patience;
}



- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag {
    
    
    if (self = [super initWithContentRect:contentRect
                                styleMask:NSBorderlessWindowMask
                                  backing:NSBackingStoreBuffered
                                    defer:NO]) {
        [self setLevel: NSStatusWindowLevel];
        [self setBackgroundColor: [NSColor clearColor]];
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        [self setHasShadow:NO];
        [self setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];

        super.ignoresMouseEvents=YES;
        
        return self;
    }
    
    return nil;
}



- (BOOL) canBecomeKeyWindow
{
    return NO;
}
-(void)showButtons{
    [self changeAppearance];
}

- (void)fadeInAndMakeKeyAndOrderFront:(BOOL)orderFront {
     [[self contentView]setNeedsDisplay:YES];
    [patience invalidate];
    //remove the previous pane before showing the new one
    [self orderOut:nil];
    [ NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setAlphaValue:0.0];
    if (orderFront) {
        [self makeKeyAndOrderFront:nil];
    }
    [[self animator] setAlphaValue:1.0];
}

- (void)fadeOutAndOrderOut:(BOOL)orderOut {
    if (orderOut) {
        [NSAnimationContext beginGrouping];
        delay = ([[NSAnimationContext currentContext] duration])+.2;
        [[NSAnimationContext currentContext] setDuration:delay];
        [[self animator] setAlphaValue:0.0];
        [NSAnimationContext endGrouping];
    }
}

-(void)changeAppearance{
    [self fadeInAndMakeKeyAndOrderFront:YES];
    patience = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
}

-(void)fadeOut{
    [self fadeOutAndOrderOut:YES];
     [self performSelector:@selector(orderOut:) withObject:nil afterDelay:delay];
}


@end
