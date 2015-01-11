//
//  TAAppDelegate.m
//  TestApp
//
//  Created by Salim Ahmed on 2/1/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import "TAAppDelegate.h"
#import "RoundedPlayPauseWindow.h"
#import "RoundedPlayPauseView.h"
#import "ParsingForRapGenius.h"
#import "TrackInfoBubbleView.h"
#import "TrackInfoBubbleWindow.h"


#define SPEED @"scrollSpeed"
#define LAUNCHATSTARTUP @"automaticLaunch"
#define SHOWBUBBLE @"showmusicbubble"
#define CHECKSTEPINIT 0
#define CHECKSTEPLVL1 1
#define CHECKSTEPLVL2 2
#define PLAYERSTATEUPDATEFREQUENCY 0.5f
#define PLAY 2
#define PAUSE 1
#define SKIP 3
#define BACK 4

@implementation TAAppDelegate{
    NSString *str;
    NSString *trackName;
    NSString* name;
    NSString* artist;
    NSString* album;
    NSString* newTrackName;
    
    iTunesTrack * track;
    
    ParsingForRapGenius *to_rg;
    NSRect keepOriginalFrame;
    Boolean lecture;
    Boolean iTunesOpen;
    NSPoint bubbleLocation;
    
    NSUserNotification *_notification;
    long rating,newRating, iconshow;
}

+(void)initialize{
    NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys:@"0.035",SPEED, NSOffState,LAUNCHATSTARTUP,NSOffState,SHOWBUBBLE, nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
   
    
    
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification{
   
    [_testAppView setSpeed:[[NSUserDefaults standardUserDefaults] floatForKey:SPEED]];
    
    [_launchOnStartupProperty setState:[[NSUserDefaults standardUserDefaults] integerForKey:LAUNCHATSTARTUP]];
    
    [_showTrackInfoBubbleOnHover setState:[[NSUserDefaults standardUserDefaults] integerForKey:SHOWBUBBLE]];
    
    _statusItem.menu = [[NSMenu alloc]init];
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    trackName = @"Initialising";
    newTrackName = nil;
    
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if([[app bundleIdentifier] isEqualToString:@"com.apple.iTunes"])
          {  // NSLog(@"iTunes Open");
              iTunesOpen = YES;
              //initialization the Itunes application object
              _itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];

          }
        
    }
    if (!iTunesOpen || !_itunes) {
        NSLog(@"iTunes NOT OPEN");
      //  [NSApp terminate:Nil];
        _itunes = Nil;
    }
    
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   // NSLog(@"%@",[[[NSFontManager sharedFontManager] availableFontFamilies] description]);

    lecture = [_itunes playerState] == 'kPSP'? YES:NO;
    _image = [NSImage imageNamed:@"image"];
    
    
    
    // Install status item into the menu bar
   
    [_statusItem setTitle:@""];
    [_statusItem setView:_testAppView];
    keepOriginalFrame = [[_statusItem view] frame];
  
    //Initialising all the timers that control the app
    _getItunesPlayerStateTimer = [NSTimer scheduledTimerWithTimeInterval:PLAYERSTATEUPDATEFREQUENCY
                                                                  target:self
                                                                selector:@selector(getItunesPlayerState)
                                                                userInfo:nil
                                                                 repeats:YES];
   if (lecture) {
        [self allTimers];
    }
   else{
       [self allTimers];
       [self killTimers];
   }

    _testAppView.rightAction = @selector(showMenu:);
    _testAppView.leftAction = @selector(pauseplaySong:);
    _testAppView.doubleClick = @selector(skipSong);
    _testAppView.tripleClick = @selector(previousSong);
    _testAppView.hoverForTrackInfo = @selector(showTrackInfoInBubble);
    _testAppView.removeTrackInfo = @selector(removeTrackInfoInBubble);
    to_rg = [[ParsingForRapGenius alloc] init];
    
    //Setting myself as delegate to distribute information to the other components
    if (iTunesOpen) {
        [_roundedplayPauseView setDelegate:self];
        [_testAppView setDelegate:self];
        [_trackInfoInBubbleView setDelegate:self];
    }
    
  //Setting myself as delegate receiving for Notifications and logging them in the default notification center.
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    
    
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(updateTrackInfo:) name:@"com.apple.iTunes.playerInfo" object:nil];
   // [NSWorkspace  NSWorkspaceDidTerminateApplicationNotification];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(listenForiTunesLaunch:) name:NSWorkspaceWillLaunchApplicationNotification object:Nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(listenForiTunesQuit:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(listenForShutdown:) name:NSWorkspaceWillPowerOffNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSkipButton) name:@"Forward" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBackButton) name:@"Backwards" object:nil];
}


////////////NOTIFICATION CENTER////////////////////////////////////////////////////////////
-(void)listenForiTunesQuit:(NSNotification*) notification{
    
    //NSLog(@"%@",[[notification userInfo] objectForKey:@"NSRunningApplication"]);
    if ([self containsString:[[notification userInfo] description] substring:@"com.apple.iTunes"]) {
        NSLog(@"iTunes Quit");
         [NSApp terminate:nil];
         [self killTimers];
       
            }
}

-(void)listenForiTunesLaunch:(NSNotification *)notification{
    if ([self containsString:[[notification userInfo] description] substring:@"com.apple.iTunes"]) {
        NSLog(@"iTunes Launching");
        //initialization the Itunes application object
      _itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        iTunesOpen = YES;
         [_roundedplayPauseView setDelegate:self];
         [_testAppView setDelegate:self];
         [_trackInfoInBubbleView setDelegate:self];
    }
}
-(void)listenForShutdown:(NSNotification *)notification{
    [self killTimers];
    [NSApp terminate:nil];
}

- (void) updateTrackInfo:(NSNotification *)notification {
   // NSDictionary *information = [notification userInfo];
   // NSLog(@"PLAYERSTATE: %@",[information objectForKey:@"Player State" ]);
  //NSLog(@"track information: %@", information);
}


-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification{
  
   [[NSUserNotificationCenter defaultUserNotificationCenter]removeDeliveredNotification:notification];
}

/////////////////DELEGATE METHODS//////////////////////////////////////////

-(long)iconToShow:(RoundedPlayPauseView *)icontoshow{
    return iconshow;
}

-(double)progressBar:(TestAppView *)barlength{
    return ([[_itunes currentTrack]duration] / [_itunes playerPosition]);
}

-(iTunesArtwork *)getArtwork:(TrackInfoBubbleView *)pix{
    NSLog(@"PIX");
   return (iTunesArtwork *)[[[[_itunes currentTrack] artworks] get] lastObject];
}


-(NSMutableArray *)getTrackInfo:(TrackInfoBubbleView *)data{
    NSMutableArray *trackDataForBubble = [[NSMutableArray alloc] init];
  if (iTunesOpen) {
    [trackDataForBubble addObject:(iTunesArtwork *)[[[[_itunes currentTrack] artworks] get] lastObject]];

    [trackDataForBubble addObject: [[[_itunes currentTrack] albumArtist] isEqualToString:@""] ?     [[_itunes currentTrack] artist] : [[_itunes currentTrack] albumArtist]];
    
    [trackDataForBubble addObject:[[[_itunes currentTrack] name] isEqualToString:@""] ? @"Unknown Song" : [[_itunes currentTrack] name]];
    
      [trackDataForBubble addObject:[[[_itunes currentTrack] album] isEqualToString:@""] ? @"Unknown Song" : [[_itunes currentTrack] album]];
     
     [trackDataForBubble addObject:[[_itunes currentTrack] time]];
    
     [trackDataForBubble addObject:[NSNumber numberWithLong:[[_itunes currentTrack]rating]]];
  }
   
    else if (!iTunesOpen) {
         NSImage *img = [NSImage imageNamed:@"placeholder"];
         NSNumber *rt = [NSNumber numberWithInt:0];
         trackDataForBubble = [NSMutableArray arrayWithObjects:img,
                                                            @"iTunes is currently",
                                                            @"Not open",
                                                            @"Unknown Album",
                                                            @"00:00",
                                                            rt,
                                                            nil];
         
    }
   
    //NSLog(@"%@",trackDataForBubble);
    return trackDataForBubble;
}

/////////////////////////////////////////////////////////////////////////////////////////////
-(void)applicationWillTerminate:(NSNotification *)notification{
 
    [[NSUserDefaults standardUserDefaults] setFloat:[_testAppView speed] forKey:SPEED];
    [[NSUserDefaults standardUserDefaults] setInteger:[_launchOnStartupProperty state] forKey:LAUNCHATSTARTUP];
    [[NSUserDefaults standardUserDefaults] setInteger:[_showTrackInfoBubbleOnHover state] forKey:SHOWBUBBLE];
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
}
 

-(void)allTimers{

    if ([self everythingPresent]) {
        //initialize and restore scroll speed to the previous setting.
        [_testAppView setSpeed:[_testAppView speed]];
        //initialize the scrolling;
        [_testAppView setTheTextMoving];
    }
    //change from the play button to scrolling text.
    [_testAppView setMorph:NO];
    [_testAppView setFrameSize:keepOriginalFrame.size];
    [_statusItem setView:_testAppView];
 
}

-(void)killTimers{
    
    //change to play button
    [_testAppView doTheInvalidate];
    [_testAppView setMorph:YES];
    [_statusItem setView:_testAppView];
}

-(void)killMainTimer{
    [_getItunesPlayerStateTimer invalidate];
    _getItunesPlayerStateTimer= nil;
}


-(void) getItunesPlayerState{
    if ([_itunes isRunning]) {
        
    if ([_itunes playerState]!='kPSP' && !lecture) {
        //don't show the buttons when iTunes has focus
        if (![[[[NSWorkspace sharedWorkspace]menuBarOwningApplication]bundleIdentifier] isEqualToString:@"com.apple.iTunes"] && [_itunes playerState]=='kPSp') {
            //I want to detect iTunes play state and react accordingly with the transparent rounded buttons. I hooked into this fucntion is because it already runs on a timer, i didn't wanna have to define another. Secondly, the above instruction is so that the play/pause button doesn't show when i'm on iTunes.
            iconshow = PAUSE;
            [_roundedplayPauseWindow showButtons];
                 }
        
//When the track pauses I invalidate all timers  and set them to nil, when iTunes is playing, i reactivate all the timers.
       [self killTimers];
        lecture = YES;
    }
    
    else if (lecture && [_itunes playerState]=='kPSP' && [self everythingPresent]) {
        [self allTimers];
        
        //don't show the buttons when iTunes has focus
        if (![[[[NSWorkspace sharedWorkspace]menuBarOwningApplication]bundleIdentifier] isEqualToString:@"com.apple.iTunes"]) {
            //I want to detect iTunes play state and react accordingly with the transparent rounded buttons. I hooked into this fucntion is because it already runs on a timer, i didn't wanna have to define another.
            iconshow = PLAY;
            [_roundedplayPauseWindow showButtons];
            
        }
        
        lecture = NO;
        [_testAppView setFrameSize:keepOriginalFrame.size];
        [_statusItem setView:_testAppView];
     
    }
        if ([_itunes playerState]=='kPSP') {
              [self songPlaying];
        }
}
}

///////////////////////////IBACTIONS////////////////////////////////////////////////////
-(IBAction)showMenu:(id)sender{
//This function is what's responsible for popping up the menu on when there's a right click
    //i remove the bubble when the user right clicks for the menu.
    [self removeTrackInfoInBubble];
    [_statusItem popUpStatusItemMenu:self.menu ];
    
  
}

- (IBAction)preferences:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:nil];
}

- (IBAction)quit:(id)sender {
     [NSApp terminate:nil];
}

- (IBAction)adjustSpeed:(id)sender {
    [_testAppView setSpeed:[sender floatValue]];
    
}


- (IBAction)gotorapgenius:(id)sender {
    if ([_itunes playerState]!='kPSS') {
        [self performSelectorInBackground:@selector(functionThatActuallyGoesToRapGenius) withObject:nil];
    }
    else{
        NSArray *msg = [NSArray arrayWithObjects:@"I can't search for lyrics to this song.",@"There's no song playing in iTunes",Nil];
        [self didNotFindLyricsOnrg:msg ];
    }

}

-(void)functionThatActuallyGoesToRapGenius{
    
    NSString* lvl0parsing;
    NSString *lvl1parsing;
    NSString *lvl2parsing;
    NSString *artistName;
    NSString *songName =[[_itunes currentTrack]name];
    
    artistName = [[[_itunes currentTrack]albumArtist] isEqualToString:@""]? [[_itunes currentTrack]artist]:[[_itunes currentTrack]albumArtist];
    
    //NSLog(@"SONG NAME: %@ --- ARTIST NAME: %@",songName,artistName);
    if (songName!=nil && artistName!=nil) {
        
        
        
    lvl0parsing = [to_rg parseString:artistName songName:songName checkStep:CHECKSTEPINIT];
   // NSLog(@"LVL0 :%@",lvl0parsing);
    if (lvl0parsing != nil) {
        
        if ([NSURL URLWithString:lvl0parsing] != nil && ![[[NSString alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:lvl0parsing]] encoding:NSUTF8StringEncoding] isEqualToString:@""]) {
            [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:lvl0parsing]];
           // NSLog(@" STRING RETURNED LEVEL 0!!");
        }
        ///the multiple conditions  are for when the atrist name has & in it like kanye west & Jay z, if kanye west and jay z doesn't work, i call the parsestring method again but this time i return only kanye west, if that doesn't work i call it again a third time, this time i return only jay z.
        else if ([[[NSString alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:lvl0parsing]] encoding:NSUTF8StringEncoding] isEqualToString:@""] && [self containsString:artistName substring:@"&"]) {
            lvl1parsing = [to_rg parseString:artistName songName:songName checkStep:CHECKSTEPLVL1];
            
            if ([NSURL URLWithString:lvl1parsing] && ![[[NSString alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:lvl1parsing]] encoding:NSUTF8StringEncoding] isEqualToString:@""]) {
                [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:lvl1parsing]];
               // NSLog(@" STRING RETURNED, LEVEL 1 !!");
            }
            else if ([[[NSString alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:lvl1parsing]] encoding:NSUTF8StringEncoding] isEqualToString:@""]){
                lvl2parsing = [to_rg parseString:artistName songName:songName checkStep:CHECKSTEPLVL2];
                if ([NSURL URLWithString:lvl2parsing] && ![[[NSString alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:lvl2parsing]] encoding:NSUTF8StringEncoding] isEqualToString:@""]) {
                    [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:lvl2parsing]];
                    //NSLog(@" STRING RETURNED, LEVEL 2 !!");
                }
                else{
                    NSArray *msg = [NSArray arrayWithObjects:@"I didn't find the lyrics to the song on Rap Genius, sorry",@"Ok", nil];
                    [self didNotFindLyricsOnrg:msg];
                }
            }
            
        }
        
        else{
            if (![artistName isEqualToString:[[_itunes currentTrack] artist]]) {
                
                lvl0parsing = [to_rg parseString:[[_itunes currentTrack]artist] songName:songName checkStep:CHECKSTEPINIT];
               // NSLog(@"Last LVL verif :%@",lvl0parsing);
                
                
                if ([NSURL URLWithString:lvl0parsing] != nil && ![[[NSString alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:lvl0parsing]] encoding:NSUTF8StringEncoding] isEqualToString:@""]) {
                    [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:lvl0parsing]];
                 //   NSLog(@" STRING RETURNED LAST LEVEL VERIF!!");
                }
            }
            else{
                NSArray *msg = [NSArray arrayWithObjects:@"I didn't find the lyrics, sorry.",@"Please verify that song is on rg.",Nil];
                [self didNotFindLyricsOnrg:msg ];
                }
            
        }
        
    }
    else{
        NSArray *msg = [NSArray arrayWithObjects:@"Incomplete Track Information.",@"Verify Album Artist and/orsong name",Nil];
       [self didNotFindLyricsOnrg:msg ];
        }
    }
 
}

- (IBAction)launchOnStartup:(id)sender {
        [_launchOnStartupProperty setState:[sender state]];
         CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
     // Create a reference to the shared file list.
     LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
     
     if (loginItems) {
         if ([[_launchOnStartupProperty selectedCell] state] == NSOnState){
             [self enableLoginItemWithLoginItemsReference:loginItems ForPath:url];
         // NSLog(@"Auto Launch On");
                    }
     else if([[_launchOnStartupProperty selectedCell] state] == NSOffState){
     [self disableLoginItemWithLoginItemsReference:loginItems ForPath:url];
        // NSLog(@"Auto Launch Off");
                        }
     }
    CFRelease(loginItems);
    
}

- (IBAction)showTrackInfoBubbleOnHoverIBAction:(id)sender {
    [_showTrackInfoBubbleOnHover setState:[sender state]];
}

//////////////////////////////END OF IBACTIONS///////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) containsString:(NSString*)mainstring substring:(NSString*)subs
{
    NSRange range = [mainstring rangeOfString: subs options:NSCaseInsensitiveSearch];
    BOOL found = ( range.location != NSNotFound );
    return found;
    
}

/////////////////////////////////////ITUNES SECTION////////////////////////////////////////////////

-(void)songPlaying{
    
      if ([self everythingPresent]) {
          
          name = [[[_itunes currentTrack]name] isEqualToString:@""]? @"Unknown Song":[[_itunes currentTrack]name];
          
          artist = [[[_itunes currentTrack]albumArtist] isEqualToString:@""] ? [[_itunes currentTrack] artist]:[[_itunes currentTrack]albumArtist];
          
          album = [[_itunes currentTrack]album];
        
          trackName =[NSString stringWithFormat:@" %@ ♦︎ %@ ♦︎ %@ 🚦", name, artist, album];
          
          if (![newTrackName isEqualToString:trackName] && trackName!= Nil) {
              newTrackName = trackName;
              [_testAppView setText:newTrackName];
              [_trackInfoInBubbleView refresh];
     
          }
        
        
    }

         rating = [[_itunes currentTrack]rating];
        if (rating != newRating) {
        newRating  = rating;
        [_trackInfoInBubbleView refresh];
    }
    
}


//♦︎
  //I used a fucntion to extract the values returned by the enum.
-(NSString *) iTunesPlayerState:(iTunesEPlS)state{
    switch (state) {
        case 'kPSP':
            str = @"Playing";
            break;
        case 'kPSp':
            str = @"Paused";
            break;
        case 'kPSS':
            str = @"Stopped";
            break;
        default:
            break;
    }
    
    return str;
}
//////////////////////////////////////////@SELECTORS FOR MOUSE ACTIONS///////////////////////////////
-(IBAction)pauseplaySong:(id)sender{
    if ([_itunes isRunning]) {
        
        if ([_itunes playerState]=='kPSP') {
            long originalVolume = [_itunes soundVolume];
            long volume = originalVolume;
            for (int i = 0; volume>i; volume-=originalVolume/25) {
                usleep(10000);
                [_itunes setSoundVolume:volume];
                
            }
            [_itunes playpause];
            [_itunes setSoundVolume:originalVolume];
            [self removeTrackInfoInBubble];

            
        }
        else if ([_itunes playerState]=='kPSp' || [_itunes playerState]=='kPSS'){
            [_itunes playpause];
            
                  NSPoint bubblePoint;
             //Positioning the bubble right under the scrolling text
             //if itunes is playing, position the bubble in the middle of the scrolling text
            float bigdifference = ([_trackInfoInBubbleView frame].size.width/2 +
                                   keepOriginalFrame.size.width/2) -
                                  [[_statusItem view] frame].size.width;
        
            
             bubblePoint = NSMakePoint([[[_statusItem view]window] frame].origin.x-bigdifference,
             [[[_statusItem view]window] frame].origin.y
             - [_trackInfoInBubbleView bounds].size.height);
            
             [_testAppView convertPoint:bubblePoint fromView:[_statusItem view]];
         
         
              NSLog(@"Init x:%f ",[[[_statusItem view] window] frame].origin.x);
              NSLog(@"%f - %f bigdifference %f",bubblePoint.x,bubblePoint.y,bigdifference);
            
            [_trackInfoInBubbleWindow slide:bubblePoint];
            
        }
    }
    
}
-(void)showSkipButton{
    if ([_itunes isRunning] && ([_itunes playerState]=='kPSp' || [_itunes playerState]=='kPSP')) {
        //don't show the buttons when iTunes has focus
        if (![[[[NSWorkspace sharedWorkspace]menuBarOwningApplication]bundleIdentifier] isEqualToString:@"com.apple.iTunes"]) {
            
            iconshow = SKIP;
            [_roundedplayPauseWindow changeAppearance];
           // NSLog(@"showSkipButton");
        }
       
    }
}

-(void)showBackButton{
    if ([_itunes isRunning] && ([_itunes playerState]=='kPSp' || [_itunes playerState]=='kPSP')) {
        //don't show the buttons when iTunes has focus
        if (![[[[NSWorkspace sharedWorkspace]menuBarOwningApplication]bundleIdentifier] isEqualToString:@"com.apple.iTunes"]) {
            
            iconshow = BACK;
            [_roundedplayPauseWindow changeAppearance];
           // NSLog(@"showBackButton");
        }
    }
}

-(void)skipSong{
    if ([_itunes isRunning]) {
        [self showSkipButton];
        [_itunes nextTrack];
    }
  
}

-(void)previousSong{
    if ([_itunes isRunning]) {
        [self showBackButton];
        [_itunes previousTrack];
    }
}

-(void)showTrackInfoInBubble{
    if([_itunes playerState] !='kPSS' && [_showTrackInfoBubbleOnHover state]==NSOnState && iTunesOpen)
    {
        if (![[[[NSWorkspace sharedWorkspace]menuBarOwningApplication]bundleIdentifier] isEqualToString:@"com.apple.iTunes"]) {
            NSPoint bubblePoint;
        //Positioning the bubble right under the scrolling text
            if ([_itunes isRunning] && [_itunes playerState]=='kPSP') {
        //if itunes is playing, position the bubble in the middle of the scrolling text
                float bigdifference = [_trackInfoInBubbleView frame].size.width/2
              -  [_testAppView frame].size.width/2;
                
            bubblePoint = NSMakePoint([[[_statusItem view]window] frame].origin.x-bigdifference,
                                          [[[_statusItem view]window] frame].origin.y
                                          - [_trackInfoInBubbleView frame].size.height);
                
                [_testAppView convertPoint:bubblePoint fromView:[_statusItem view]];
              //  NSLog(@"Init x:%f ",[[[_statusItem view] window] frame].origin.x);
               // NSLog(@"%f - %f bigdifference %f",bubblePoint.x,bubblePoint.y,bigdifference);
               
            }
            else{
            float difference = [_trackInfoInBubbleView frame].size.width/2-11;
             bubblePoint = NSMakePoint([[[_statusItem view]window] frame].origin.x-difference,
                                      [[[_statusItem view]window] frame].origin.y
                                    -[_trackInfoInBubbleView bounds].size.height);
         
            [_testAppView convertPoint:bubblePoint fromView:[_statusItem view]];
                //  NSLog(@"Init x:%f ",[[[_statusItem view] window] frame].origin.x);
                // NSLog(@"%f - %f bigdifference %f",bubblePoint.x,bubblePoint.y,difference);

               
            }
            
            [_trackInfoInBubbleWindow positionBubble:bubblePoint];
            [_trackInfoInBubbleWindow fadeIn];
       
        }
    }
}
-(void)removeTrackInfoInBubble{
    [_trackInfoInBubbleWindow fadeOut];
    [_trackInfoInBubbleWindow orderWindowOut];
}

-(void)didNotFindLyricsOnrg:(NSArray*)msg {
    _notification = [[NSUserNotification alloc] init];
    [_notification setTitle: @"Alert"];
    [_notification setSubtitle: [msg objectAtIndex:0]];
    [_notification setInformativeText:[msg objectAtIndex:1]];

    
    [_notification setSoundName: NSUserNotificationDefaultSoundName];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter]deliverNotification:_notification];
}

//////////////////////////LAUNCH AT START-UP////////////////////////////////////////////////////////


 - (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(CFURLRef)thePath {
 // We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
 LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, thePath, NULL, NULL);
 if (item)
 CFRelease(item);
     
 }
 
 - (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(CFURLRef)thePath {
 UInt32 seedValue;
 
 // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
 // and pop it in an array so we can iterate through it to find our item.
     
 NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
 for (id item in loginItemsArray) {
 LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
 if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
 if ([[(__bridge NSURL *)thePath path] hasPrefix:[[NSBundle mainBundle] bundlePath]])
 LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
 }
 }
 
 }

-(BOOL)everythingPresent{
    return ([[_itunes currentTrack] name] !=nil &&  [[_itunes currentTrack] name] != nil && [[_itunes currentTrack] album] != nil);
}

@end
