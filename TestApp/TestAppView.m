//
//  TestAppView.m
//  TestApp
//
//  Created by Salim Ahmed on 2/1/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import "TestAppView.h"
#import "iTunes.h"
#import "TrackInfoBubbleWindow.h"

#define MOVEINDEX 1.0f
#define SCROLLINGTEXTHEIGHTADJUSTEMENT 1.5F
#define TEXTADJUSTMENT 18.0
#define SCROLLINGTEXTWIDTH 115.0f

@implementation TestAppView{
    NSDictionary *attrsDictionary;
    NSFont *font;
    TrackInfoBubbleWindow * tibw;
    
}

@synthesize text;
@synthesize speed;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
       _image =  [NSImage imageNamed:@"main32"];
        
        text = [NSString string];
         font = [NSFont fontWithName:@"Helvetica Neue Medium" size:13.0];
        attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        
         trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways  owner:self userInfo:nil];
        
        [self addTrackingArea:trackingArea];
        [self setFrameSize:NSMakeSize(SCROLLINGTEXTWIDTH, [[NSStatusBar systemStatusBar] thickness])];
        tibw = [[TrackInfoBubbleWindow alloc] init];
    }
    return self;
}

-(void)singleClickAction{
    
        [NSApp sendAction:self.leftAction to:self.leftTarget from:self];
    
}

-(void)doubleMouseAction{

     [NSApp sendAction:self.doubleClick to:self.doubleTarget from:self ];
    
}

- (void)rightMouseDown:(NSEvent *)theEventP{
   
    [NSApp sendAction:self.rightAction to:self.rightTarget from:self];
   
}

- (void)mouseDown:(NSEvent *)theEventP{
    if ([theEventP clickCount]==1) {
    [self performSelector:@selector(singleClickAction) withObject:nil afterDelay:[NSEvent doubleClickInterval]];
        
        
      
    }
   else if ([theEventP clickCount]==2) {
    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
       
    [self performSelector:@selector(doubleMouseAction) withObject:nil afterDelay:[NSEvent doubleClickInterval]];       
    }
    
   else if ([theEventP clickCount]==3){
       [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
    [NSApp sendAction:self.tripleClick to:self.tripleTarget from:self ];
   }

}

-(void)mouseEntered:(NSEvent *)theEvent{
    [NSApp sendAction:self.hoverForTrackInfo to:self.hoverTrigger from:self];
    
}

-(void)mouseExited:(NSEvent *)theEvent{
    [NSApp sendAction:self.removeTrackInfo to:self.unhoverTrigger from:self];
}

-(void)cursorUpdate:(NSEvent *)event{
    [[NSCursor closedHandCursor] set];
  
}

-(void)doTheInvalidate{
    [scroller invalidate];
     scroller = nil;
}



//////////////////////////TEXT SCROLL SECTION////////////////////////////////////////



 - (void) dealloc {
 [scroller invalidate];
 }
 
 - (void) setText:(NSString *)newText {
 text = [newText copy];
  
 point = NSZeroPoint;
 
 //I grab the width of the string with it's attributes(font and size).
 stringWidth = [newText sizeWithAttributes:attrsDictionary].width;
 
 if (scroller == nil && speed > 0 && text != nil) {
 
     [self setTheTextMoving];
 }
 }
 
 - (void) setSpeed:(NSTimeInterval)newSpeed {
 if (newSpeed != speed) {
     speed = newSpeed;
     [self doTheInvalidate];
     
 if (speed > 0 && text != nil) {
      [self setTheTextMoving];
       }
    }
 }

-(void)setTheTextMoving{
    [self doTheInvalidate];
    scroller = [NSTimer scheduledTimerWithTimeInterval:[self speed]
                                        target:self selector:@selector(moveText)
                                        userInfo:nil
                                        repeats:YES];
    [self moveText];
}

 - (void) moveText{
     point.x = point.x - MOVEINDEX;
     point.y = SCROLLINGTEXTHEIGHTADJUSTEMENT;
     [self setNeedsDisplay:YES];
    }

- (BOOL)acceptsFirstResponder
{
    return YES;
}



 - (void)drawRect:(NSRect)dirtyRect {
     //Progress Bar at the top to indicate current player position.
     [[NSColor blackColor] set];
     NSRect musicTime = NSMakeRect(NSMinX(dirtyRect),
                                   NSMaxY(dirtyRect)-2.5,
                                   SCROLLINGTEXTWIDTH/[_delegate progressBar:self],
                                   1.2);
     NSRectFill(musicTime);
     
/////////////////////////My Own Take on it, WHICH BTW IS WAAAY BETTER!!//////////////////////////////
 
 if (stringWidth>dirtyRect.size.width) {
 //I added TEXTADJUSTMENT so as to space out the text, otherwise they're attached  end to end and unreadable.
 if (point.x + stringWidth +TEXTADJUSTMENT < 0) {
 point.x += stringWidth +TEXTADJUSTMENT;
 }
 }
 else if (dirtyRect.size.width>stringWidth){
 if (point.x + dirtyRect.size.width < 0) {
 point.x += dirtyRect.size.width;
 }
 }
      //Set custom text attributes for the scrolling text
 //this is what's responsible for moving the text, it redraws the text at the point provided.
 [text drawAtPoint:point withAttributes:attrsDictionary];
 
 if (point.x < 0) {
 
 NSPoint otherPoint = point;
 //If the text is longer than than the size of the "dirtyRect"
 if (stringWidth>dirtyRect.size.width) {
 //I added "TEXTADJUSTMENT" so as to space out the text, otherwise they're attached  end to end and unreadable.
 otherPoint.x += stringWidth +TEXTADJUSTMENT;
 }
 else if (dirtyRect.size.width>stringWidth){
 otherPoint.x += dirtyRect.size.width;
 }
 
     //Set custom text attributes for the scrolling text
     //this is what's responsible for moving the text, it redraws the text at the point provided.
 [text drawAtPoint:otherPoint withAttributes:attrsDictionary];
     
 }
     if ([self morph]) {
         NSRect petitRect =  NSMakeRect(0, 0, 22.00, 22.00);
        [self setFrameSize:petitRect.size];
         //[self setFrame:petitRect];
      [_image drawInRect:petitRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
         [tibw killWindow];
      [self setNeedsDisplay:YES];
 }

 }


/////////////////////////////////////END OF TEXT SCROLL SECTION///////////////////////////////////////



@end
