//
//  TrackInfoBubbleView.m
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/23/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import "TrackInfoBubbleView.h"
#define RADIUS 10
#define ARROW_WIDTH 15
#define ARROW_HEIGHT 15

@implementation TrackInfoBubbleView
{
    
    NSImage *currentSongImage;
    NSImage *star;
    
    NSPoint dest;
    
    NSFont *font;
    NSDictionary *fontAttr;
    NSColor *fontColor;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    
          currentSongImage = [[NSImage alloc] initWithData:[[[_delegate getTrackInfo:self] objectAtIndex:0] rawData]];
          [currentSongImage setSize:NSMakeSize(100,100)];
      
     //Setting font properties, all there is to do is define the attributes, add them in a dictionary and add as attribute when drawing the strings.
        font = [NSFont fontWithName:@"Helvetica Neue light" size:13.0];
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        fontColor = [NSColor whiteColor];
     
        fontAttr = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,style, NSParagraphStyleAttributeName, fontColor,NSForegroundColorAttributeName ,nil];
        
        
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    NSRect bgRect = dirtyRect;
    
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    

    currentSongImage = [[NSImage alloc] initWithData:[[[_delegate getTrackInfo:self] objectAtIndex:0] rawData]];
    
    if (!currentSongImage) {
        currentSongImage = [NSImage imageNamed:@"placeholder"];
    }
    
    [currentSongImage setSize:NSMakeSize(100,100)];

 
    NSColor *bgColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.8];
    
    NSBezierPath * roundedSq = [NSBezierPath bezierPath];
    
     //summit of the triangle, keeping it safe so i can close find it more easily later.
     NSPoint alphaOmega = NSMakePoint(midX, maxY);
     
     
     [roundedSq moveToPoint:NSMakePoint(minX, maxY)];
     [roundedSq moveToPoint:alphaOmega];
     //descent from the top of the rect to create right hand side of the triangle, the pointy part of the rectangle
     NSPoint rightSideOfArrow = NSMakePoint(midX+ARROW_WIDTH, maxY-ARROW_HEIGHT);
     
     //the line for the right hand side of the arrow/
     [roundedSq lineToPoint:rightSideOfArrow];
     
     //Top right curve
     [roundedSq appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY-ARROW_HEIGHT)
     toPoint:NSMakePoint(maxX, midY)
     radius:RADIUS];
     
     [roundedSq appendBezierPathWithArcFromPoint:NSMakePoint(maxX, midY)
     toPoint:NSMakePoint(maxX, minY)
     radius:RADIUS];
     
     
     //bottom right curve
     [roundedSq appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY)
     toPoint:NSMakePoint(midY, minX)
     radius:RADIUS];
     
     
     //bottom left curve
     [roundedSq appendBezierPathWithArcFromPoint: NSMakePoint(minX,minY )
     toPoint:NSMakePoint(minX, midY)
     radius:RADIUS];
     
     //Point that marks the intersection with the other side of the triangle
     NSPoint leftSideOfArrow = NSMakePoint(rightSideOfArrow.x-2*ARROW_WIDTH, rightSideOfArrow.y);
     
    
     //Top left curve
     [roundedSq appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY-ARROW_HEIGHT)
     toPoint:leftSideOfArrow
     radius:RADIUS];
     //final line to meet left sode of arrow.
     [roundedSq lineToPoint:leftSideOfArrow];
     //line to meet the summit.
     [roundedSq lineToPoint:alphaOmega];
     
     [bgColor set];
     [roundedSq closePath];
     
     [roundedSq stroke];
     [roundedSq fill];

    
    float textWidth = roundedSq.bounds.size.width;
    float distfromtop = roundedSq.bounds.size.height;
    float distfrompix = 10+currentSongImage.size.width;
//[[NSImage alloc] initWithData:[[[_delegate getTrackInfo:self] objectAtIndex:0] rawData]]
     switch ([[[_delegate getTrackInfo:self] objectAtIndex:5] intValue]) {
     case 0:
     {
          star = [NSImage imageNamed:@"nostar"];
         break;
     }
     case 20:
     {
             star = [NSImage imageNamed:@"1star"];
            break;
     }
     case 40:
     {
             star = [NSImage imageNamed:@"2star"];
            break;
     }
     case 60:
     {
             star = [NSImage imageNamed:@"3star"];
            break;
     }
     case 80:
     {
            star = [NSImage imageNamed:@"4star"];
            break;
     }
    case 100:
    {
              star = [NSImage imageNamed:@"5star"];
             break;
    }
     default:
     break;
     }
    
    
    [currentSongImage drawAtPoint:NSMakePoint(5,5) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [star drawAtPoint:NSMakePoint(distfrompix, distfromtop-110) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [[[_delegate getTrackInfo:self] objectAtIndex:2] drawInRect:NSMakeRect(distfrompix, (distfromtop-35),(textWidth-(distfrompix+5)), 20) withAttributes:fontAttr];
   
    [[[_delegate getTrackInfo:self] objectAtIndex:1] drawInRect:NSMakeRect(distfrompix, (distfromtop-55),(textWidth-(distfrompix+5)), 20) withAttributes:fontAttr];
    
    [[[_delegate getTrackInfo:self] objectAtIndex:3] drawInRect:NSMakeRect(distfrompix, (distfromtop-75),(textWidth-(distfrompix+5)), 20) withAttributes:fontAttr];
    
    [[[_delegate getTrackInfo:self] objectAtIndex:4] drawInRect:NSMakeRect(textWidth-50, (distfromtop-110),(textWidth-(distfrompix+5)), 20) withAttributes:fontAttr];

  //  NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
   // [style setLineBreakMode:NSLineBreakByTruncatingTail];
    
   // [string drawWithRect:NSMakeRect(distfrompix, (distfromtop-45),(textWidth-distfrompix), 20) options:NSLineBreakByTruncatingTail];
   

}
-(void)refresh{
    [self setNeedsDisplay:YES];
}

@end
