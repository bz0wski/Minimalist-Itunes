//
//  TrackInfoBubbleWindow.m
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/23/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import "TrackInfoBubbleWindow.h"

@implementation TrackInfoBubbleWindow{
    NSTimeInterval delay;
    NSTimer *patience;
    NSPoint dest;
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

-(CABasicAnimation *)moveFrame:(NSRect) frame To:(NSPoint)thisPoint{
    
    CABasicAnimation *originAnimation = [CABasicAnimation animation];
    CAMediaTimingFunction* timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [originAnimation setTimingFunction:timing];
    [originAnimation setDuration:1.0f];
   
    [originAnimation setFromValue:[NSValue valueWithPoint:[self frame].origin]];
    
    /*When you add an animation to a layer, the animation does not change the layer's properties. Instead, the system creates a copy of the layer. The original layer is called the model layer, and the duplicate is called the presentation layer. The presentation layer's properties change as the animation progresses, but the model layer's properties stay unchanged.
     
     When you remove the animation, the system destroys the presentation layer, leaving only the model layer, and the model layer's properties then control how the layer is drawn. So if the model layer's properties don't match the final animated values of the presentation layer's properties, the layer will instantly reset to its appearance before the animation.
     
     To fix this, you need to set the model layer's properties to the final values of the animation, and then add the animation to the layer. You want to do it in this order because changing a layer property can add an implicit animation for the property, which would conflict with the animation you want to explicitly add. You want to make sure your explicit animation overrides the implicit animation.*/
    
    [originAnimation setToValue:[NSValue valueWithPoint:thisPoint]];
    
    [originAnimation setFillMode:kCAFillModeForwards];
    [originAnimation setRemovedOnCompletion:NO];
    
    return originAnimation;
    
}


- (BOOL) canBecomeKeyWindow
{
    return NO;
}

- (void)fadeIn {
    
    [[self contentView]setNeedsDisplay:YES];
    
    [self orderOut:nil];

    [self setAlphaValue:0.0];

    [NSAnimationContext beginGrouping];
    
    [[NSAnimationContext currentContext] setDuration:[[NSAnimationContext currentContext] duration]];
    
    [self makeKeyAndOrderFront:nil];
    
    [[self animator] setAlphaValue:1.0];
    
    [NSAnimationContext endGrouping];
    
    
   
}

- (void)fadeOut {
    
     [NSAnimationContext beginGrouping];
     delay = ([[NSAnimationContext currentContext] duration])+.2;
   
     [[NSAnimationContext currentContext] setDuration:delay];
    
     [[self animator] setAlphaValue:0.0];
    
     [NSAnimationContext endGrouping];
   
    
    
}

-(void)changeAppearance{
    [self fadeIn];
    patience = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
}

-(void)positionBubble:(NSPoint) point{
    [self setFrameOrigin:(point)];
}


-(void)slide:(NSPoint) toThisPoint{
     [self setAnimations:[NSDictionary dictionaryWithObject:
                          [self moveFrame:[self frame] To:toThisPoint] forKey:@"frameOrigin"]];
    
     [[self animator] setFrameOrigin:toThisPoint];
}


-(void)orderWindowOut{
    [NSTimer scheduledTimerWithTimeInterval:.46000
                                     target:self
                                    selector:@selector(orderOut:)
                                    userInfo:nil
                                    repeats:NO];
}

-(void)killWindow{
    [self orderOut:nil];
}
@end
