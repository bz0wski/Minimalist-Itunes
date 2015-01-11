//
//  ParsingForRapGenius.m
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/22/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import "ParsingForRapGenius.h"

@implementation ParsingForRapGenius{

    
}
- (id)init
{
    self = [super init];
    if (self) {
      
    }
    return self;
}

-(NSString*)parseString:(NSString *)albumArtist songName:(NSString *)songName checkStep:(int)level{
  
if (![albumArtist isEqualToString:@""] && ![songName isEqualToString:@""]) {
  //  NSMutableString *albumArtistInfo = [NSMutableString string];
   // NSMutableString *songNameInfo = [NSMutableString string];
    
    
//////CHECKING TO SEE IF THE SONG TITLE HAS PARENTHESIS IN IT'S NAME///////////
    if([self containsString:songName substring:@"("] || [self containsString:songName substring:@"["]){
        songName = [self splitSongTitle:songName];
    }

    songName = [[[[[[[[[songName stringByReplacingOccurrencesOfString:@"&" withString:@"and"] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"'" withString:@""] stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"ê" withString:@"e"] stringByReplacingOccurrencesOfString:@"â" withString:@"a"] stringByReplacingOccurrencesOfString:@"à" withString:@"a"] stringByReplacingOccurrencesOfString:@"," withString:@""]stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    NSLog(@"SONG NAME : %@",songName);
    
     albumArtist = [[[[[[[[albumArtist stringByReplacingOccurrencesOfString:@"." withString:@""]stringByReplacingOccurrencesOfString:@"," withString:@"" ] stringByReplacingOccurrencesOfString:@"é" withString:@"e"]stringByReplacingOccurrencesOfString:@"ê" withString:@"e"] stringByReplacingOccurrencesOfString:@"â" withString:@"a"] stringByReplacingOccurrencesOfString:@"à" withString:@"a"] stringByReplacingOccurrencesOfString:@"é" withString:@"e"]stringByReplacingOccurrencesOfString:@"'" withString:@""] ;
    
////////////CHECKING TO SEE IF THE ARTISTE NAME HAS "&" IN IT, LIKE "Jay Z & Kanye West"//////////////
    if ([self containsString:albumArtist substring:@"&"]) {
        // NSLog(@"has & in artiste name");
        switch (level) {
            case 1:
            {
                NSArray *useFirstName = [albumArtist componentsSeparatedByString:@" &"];
                albumArtist = @"";
                albumArtist = [albumArtist stringByAppendingString:[useFirstName objectAtIndex:0]];
               // NSLog(@"LEVEL 1 :[%@]",albumArtist);
                break;
            }
            case 2:
            {
                NSArray *useSecondName = [albumArtist componentsSeparatedByString:@"& "];
                albumArtist = @"";
                if ([useSecondName count]>=1) {
                     albumArtist = [albumArtist stringByAppendingString:[useSecondName objectAtIndex:1]];
                   // NSLog(@"LEVEL 2 :[%@]",albumArtist);
                }
               
                break;
            }
               //usefirstname-and-usesecondname
            default:
                albumArtist = [albumArtist stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
                break;
        }
       
    }

///////CHECKING TO SEE IF THE ARTISTE NAME HAS "$" IN IT, LIKE "A$AP Rocky"//////////////
    if ([self containsString:albumArtist substring:@"$"]) {
      //  NSLog(@"has $ in artiste name");
        
        if([self containsString:albumArtist substring:@"ferg"]){
            albumArtist = [albumArtist stringByReplacingOccurrencesOfString:@"$" withString:@"s"];
        }
        else{
            albumArtist = [albumArtist stringByReplacingOccurrencesOfString:@"$" withString:@"-"];
        }
    
    }
    
    
/////////////////////////FINAL STEP, REMOVING SPACES AND ADDING - /////////////////////////////////////
  
    
    albumArtist = [albumArtist stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    albumArtist = [albumArtist stringByAppendingString:@"-"];
    
    
    songName = [songName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    songName = [songName stringByAppendingString:@"-"];
    
    //remove multiple dash in song name
    NSString *pattern = @"(-)\\1{1,}";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];

    NSArray *matches = [regex matchesInString:songName options:0 range:NSMakeRange(0,[songName length])];
    if ([matches count] != 0 && matches != nil) {
        for (NSTextCheckingResult *match in matches) {
           // NSString* matchText = [songName substringWithRange:[match range]];
            //  NSLog(@"match: %@", matchText);
            //  NSRange group1 = [match rangeAtIndex:1];
            //  NSLog(@"Result : %@", [songName substringWithRange:[match range]]);
            songName = [songName stringByReplacingCharactersInRange:[match range] withString:@"-"];
        }
    }
   
    NSLog(@"http://www.rapgenius.com/%@%@lyrics",albumArtist,songName);
    return [NSString stringWithFormat:@"http://www.rapgenius.com/%@%@lyrics",albumArtist,songName];

}
else
    return nil;
    }
   




- (BOOL) containsString:(NSString*)mainstring substring:(NSString*)subs
{
    NSRange range = [mainstring rangeOfString: subs options:NSCaseInsensitiveSearch];
    BOOL found = ( range.location != NSNotFound );
    return found;
    
}


-(NSString *)splitSongTitle:(NSString *)stringToSplit{
    char singleChar;
    int i = 0;
  //  long tl = 0;
    BOOL remix = NO;
    BOOL first;
    NSString *stringToReturn = [NSString string];
    
    if ([self containsString:stringToSplit substring:@"remix"] ) {
        //NSLog(@"This is a remix.");
        remix = YES;
    }
    
    first = [stringToSplit rangeOfString:@"("].location < [stringToSplit rangeOfString:@"["].location? YES:NO;
   
    if (first) {
        
        singleChar = [stringToSplit characterAtIndex:i];
        while (singleChar != '(') {
            singleChar = [stringToSplit characterAtIndex:i];
            i++;
        }
    
        
        stringToReturn = [stringToSplit substringWithRange:NSMakeRange(0, i-1)];
        
        ///remove all leading and trailing whitespace
        stringToReturn = [stringToReturn stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    }
    else if (!first) {
        singleChar = [stringToSplit characterAtIndex:i];
        while (singleChar != '[') {
            singleChar = [stringToSplit characterAtIndex:i];
            i++;
        }
        
        stringToReturn = [stringToSplit substringWithRange:NSMakeRange(0, (i-1))];
         ///remove all leading and trailing whitespace
        stringToReturn = [stringToReturn stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    if (remix) {
        stringToReturn = [stringToReturn stringByAppendingString:@" remix"];
    }
    
   //NSLog(@"AFTER SPLIT %@++++",stringToReturn);
    return stringToReturn;
}

@end
