//
//  ParsingForRapGenius.h
//  Minimalist Itunes
//
//  Created by Salim Ahmed on 2/22/14.
//  Copyright (c) 2014 Salim Ahmed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingForRapGenius : NSObject

-(NSString*)parseString:(NSString*)albumArtist songName:(NSString*)songName checkStep:(int)level;

@end
