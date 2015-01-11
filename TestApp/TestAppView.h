//
//  TestAppView.h
//  TestApp
//
//  Created by Salim Ahmed on 2/1/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TestAppView;

@protocol TestAppViewDelegate <NSObject>
 
-(double)progressBar:(TestAppView *)barlength;
 
@end

@interface TestAppView : NSView{
    //I'm going to implement a scrolling text view of the song title in the menu bar
    NSTimer * scroller;
    NSPoint point;
    NSTrackingArea *trackingArea;
    CGFloat stringWidth;
}

@property (weak,nonatomic) id <TestAppViewDelegate> delegate;

@property (nonatomic) NSImage *image;

@property (nonatomic) IBOutlet NSMenu *menu;
@property (nonatomic) IBOutlet NSTextField *mytext;

@property (nonatomic,copy) NSString *text;
@property (nonatomic) NSTimeInterval speed;

@property (nonatomic) SEL rightAction;
@property (nonatomic) SEL leftAction;
@property (nonatomic) SEL doubleClick;
@property (nonatomic) SEL tripleClick;
@property SEL hoverForTrackInfo;
@property SEL removeTrackInfo;

@property id hoverTrigger;
@property id unhoverTrigger;
@property (nonatomic, unsafe_unretained) id rightTarget;
@property (nonatomic) id leftTarget;
@property (nonatomic) id doubleTarget;
@property (nonatomic) id tripleTarget;
@property Boolean morph;

-(void)doTheInvalidate;
-(void)setTheTextMoving;

@end
