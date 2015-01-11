//
//  RoundedPlayPauseView.h
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/20/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RoundedPlayPauseView;


@protocol RoundedButtonsDelegate <NSObject>

-(long)iconToShow:(RoundedPlayPauseView *)icontoshow;

@end

@interface RoundedPlayPauseView : NSView

@property long iconshow;
@property (weak,nonatomic)id<RoundedButtonsDelegate> delegate;



@end
