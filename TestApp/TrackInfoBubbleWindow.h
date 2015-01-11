//
//  TrackInfoBubbleWindow.h
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/23/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>


@interface TrackInfoBubbleWindow : NSWindow

- (void)changeAppearance;
- (void)fadeIn;
- (void)fadeOut;
-(void)orderWindowOut;
-(void)slide:(NSPoint) toThisPoint;
- (void)positionBubble:(NSPoint)point;
-(void)killWindow;
@end
