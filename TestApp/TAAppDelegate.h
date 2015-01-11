//
//  TAAppDelegate.h
//  TestApp
//
//  Created by Salim Ahmed on 2/1/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "RoundedPlayPauseView.h"
#import "TestAppView.h"
#import "TrackInfoBubbleView.h"

@class RoundedPlayPauseWindow;
@class TrackInfoBubbleWindow;

@interface TAAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, RoundedButtonsDelegate,TestAppViewDelegate,TrackInfoBubbleView>

@property (assign) IBOutlet NSWindow *window;
@property NSStatusItem *statusItem;
@property (weak,nonatomic) IBOutlet TestAppView *testAppView;
@property (nonatomic,weak) NSImage *image;
@property (weak) IBOutlet NSMenu *menu;
@property (nonatomic)float speed;


@property (weak) IBOutlet NSMenuItem *gotorapgeniusOUTLET;

@property iTunesApplication *itunes;
@property (nonatomic) NSTimer* getItunesPlayerStateTimer;

-(void)songPlaying;
-(void)allTimers;

- (IBAction)preferences:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)adjustSpeed:(id)sender;
- (IBAction)gotorapgenius:(id)sender;


@property (weak,nonatomic) IBOutlet NSButton *launchOnStartupProperty;
- (IBAction)launchOnStartup:(id)sender;
@property (weak) IBOutlet NSButton *showTrackInfoBubbleOnHover;
- (IBAction)showTrackInfoBubbleOnHoverIBAction:(id)sender;




- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(CFURLRef)thePath;
- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(CFURLRef)thePath;

@property (weak,nonatomic) IBOutlet RoundedPlayPauseView *roundedplayPauseView;
@property (unsafe_unretained,nonatomic) IBOutlet RoundedPlayPauseWindow *roundedplayPauseWindow;

@property (weak,nonatomic) IBOutlet TrackInfoBubbleView *trackInfoInBubbleView;
@property (unsafe_unretained,nonatomic) IBOutlet TrackInfoBubbleWindow *trackInfoInBubbleWindow;


@end
