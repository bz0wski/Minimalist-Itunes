//
//  CustomMinimalistApplication.m
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 3/19/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import "CustomMinimalistApplication.h"
#import "RoundedPlayPauseWindow.h"


#import "iTunes.h"


int CustomMinimalistApplicationMain(int argc, const char* argv[]){
    @autoreleasepool {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        Class principalClass = NSClassFromString([infoDictionary objectForKey:@"NSPrincipalClass"]);
        NSApplication *applicationObject = [principalClass sharedApplication];
        
        NSString* mainNibName = [infoDictionary objectForKey:@"NSMainNibFile"];
        NSNib *mainNib = [[NSNib alloc] initWithNibNamed:mainNibName bundle:[NSBundle mainBundle]];
        [mainNib instantiateWithOwner:applicationObject topLevelObjects:nil];
        
        if ([applicationObject respondsToSelector:@selector(run)])
        {
            [applicationObject
             performSelectorOnMainThread:@selector(run)
             withObject:nil
             waitUntilDone:YES];
        }
        
    }
    
    return 0;
}

@implementation CustomMinimalistApplication


- (void)mediaKeyEvent: (int)key state: (BOOL)state repeat: (BOOL)repeat
{
	switch( key )
	{
		case NX_KEYTYPE_PLAY:
			if( state == 0 )
                ;// NSLog(@"Play pressed and released");
            break;
            
		case NX_KEYTYPE_FAST:
			if( state == 0 )
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Forward" object:Nil];
            break;
            
		case NX_KEYTYPE_REWIND:
			if( state == 0 )
                [ [NSNotificationCenter defaultCenter] postNotificationName:@"Backwards" object:nil];
            break;
	}
}

- (void)sendEvent: (NSEvent*)event
{
	if( [event type] == NSSystemDefined && [event subtype] == 8 )
	{
		int keyCode = (([event data1] & 0xFFFF0000) >> 16);
		int keyFlags = ([event data1] & 0x0000FFFF);
		int keyState = (((keyFlags & 0xFF00) >> 8)) ==0xA;
		int keyRepeat = (keyFlags & 0x1);
		
		[self mediaKeyEvent: keyCode state: keyState repeat: keyRepeat];
	}
    
	[super sendEvent: event];
}


@end
