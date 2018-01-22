//
//  PropAreConfig.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-12.
//
//

#import "PropAreaRandomizer.h"
#import "GameScene.h"
#import "Score.h"
#import "JunkType.h"
#import "JunkCategory.h"

static PropAreaRandomizer *sharedRandomizer;

@implementation PropAreaRandomizer

+ (PropAreaRandomizer *)sharedRandomizer
{
    if ( !sharedRandomizer )
        sharedRandomizer = [[PropAreaRandomizer alloc] init];
    return sharedRandomizer;
}

- (JunkType *)typeForJunk
{
    int level = [GameScene sharedGameScene].score.level;
    
    int odds[4] = {0, 0, 0, 0};
    
    if ( level == 1 )
    {
        odds[0] = 45;
        odds[1] = 5;
    }
    else if ( level == 2 )
    {
        odds[0] = 40;
        odds[1] = 10;
    }
    else if ( level == 3 )
    {
        odds[0] = 30;
        odds[1] = 15;
        odds[2] = 5;
    }
    else if ( level == 4 )
    {
        odds[0] = 25;
        odds[1] = 15;
        odds[2] = 10;
    }
    else if ( level == 5 )
    {
        odds[0] = 15;
        odds[1] = 15;
        odds[2] = 15;
        odds[3] = 5;
    }
    else if ( level == 6 )
    {
        odds[0] = 10;
        odds[1] = 15;
        odds[2] = 15;
        odds[3] = 10;
    }
    else if ( level == 7 )
    {
        odds[0] = 5;
        odds[1] = 15;
        odds[2] = 15;
        odds[3] = 15;
    }
    
    JunkCategory *category;
    
    int r = arc4random() % (odds[0]+odds[1]+odds[2]+odds[3]);
    int s = 0;
    for ( int i=0; i<4 && !category; i++)
    {
        s += odds[i];
        if ( s > r )
        {
            category = [JunkCategory categoryForIndex:i+1];
        }
    }

    if ( !category )
        category = [JunkCategory categoryForIndex:1];
    
    
    // TYPE    
    int t = ( arc4random() % category.types.count ) / ( arc4random() % 5 + 1);
    return [category.types objectAtIndex:t];
}

@end
