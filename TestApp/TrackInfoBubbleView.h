//
//  TrackInfoBubbleView.h
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/23/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"

@class TrackInfoBubbleView;

@protocol TrackInfoBubbleView <NSObject>

-(NSMutableArray *)getTrackInfo:(TrackInfoBubbleView *)data;

@end

@interface TrackInfoBubbleView : NSView

@property (nonatomic,weak) id<TrackInfoBubbleView> delegate;

-(void)refresh;
@end
