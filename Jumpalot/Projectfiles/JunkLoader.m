//
//  JunkLoader.m
//  Jumpalot
//
//  Created by David Fono on 2013-06-28.
//
//

#import "JunkLoader.h"
#import "JunkCategory.h"
#import "JunkType.h"

@implementation JunkLoader

+ (void)loadJunk
{
    for ( int c=1; c<=4; c++ )
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"junk%d", c] ofType:@"txt"];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [content componentsSeparatedByString:@"\n"];
        
        JunkCategory *category = [JunkCategory categoryForIndex:c];
        
        int i=0;
        NSString *name;
        NSString *spriteName;
        NSString *description;
        for ( NSString *line in lines )
        {
            if ( i%4 == 0 )
            {
                // name
                name = [line copy];
            }
            else if ( i%4 == 1 )
            {
                // sprite name
                spriteName = [line copy];
            }
            else if ( i%4 == 2 )
            {
                // description
                description = [line copy];
                JunkType *type = [[JunkType alloc] initWithCategory:category name:name sprite:spriteName description:description];
                [category.types addObject:type];
                
                NSAssert(type.tweetText.length <= 140, @"Junk description is too long for %@", name);
            }
            
            i++;
        }
    }
}

@end
