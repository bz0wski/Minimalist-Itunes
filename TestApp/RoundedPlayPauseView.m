//
//  RoundedPlayPauseView.m
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/20/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import "RoundedPlayPauseView.h"

@implementation RoundedPlayPauseView{
    NSImage *play;
    NSImage *pause;
    NSImage *nextbtn;
    NSImage *bckbtn;
    
    Boolean betrue;
   
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _iconshow = 0;
       play = [NSImage imageNamed:@"playbtn"];
        
        pause = [NSImage imageNamed:@"pause"];
        bckbtn = [NSImage imageNamed:@"backward"];
        nextbtn = [NSImage imageNamed:@"forward"];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	NSPoint pointToPlay;
    
    
    NSColor *bgColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.15];
    NSRect tRect = dirtyRect;
 
    float radius = 25.0; // correct value to duplicate Panther's App Switcher
    //NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    NSBezierPath *roundedSq = [NSBezierPath bezierPathWithRoundedRect:tRect xRadius:radius yRadius:radius];
   
    [bgColor set];
   
    [roundedSq fill];
    pointToPlay = NSMakePoint(45,45);
    
    switch (_iconshow = [_delegate iconToShow:self]) {
        case 1:
        {
            [pause drawAtPoint:NSMakePoint(40,45) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        }
        case 2:
        {
            [play drawAtPoint:pointToPlay fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        }
        case 3:
        {
            [nextbtn drawAtPoint:pointToPlay fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        }
        case 4:
        {
            [bckbtn drawAtPoint:pointToPlay fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            break;
        }
        default:
            break;
    }
  
}


@end
