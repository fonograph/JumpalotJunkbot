//
//  Score.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#define STARTING_LEVEL 1

#import "Score.h"

@interface Score()

- (void)setJunkToLevelUpForLevel;

@end

@implementation Score

- (id)init
{
    if ( self = [super init] )
    {
        if ( STARTING_LEVEL > 1 )
        {
            _level = STARTING_LEVEL - 1;
            [self setJunkToLevelUpForLevel];
            _junks = _junksToLevelUp;
        }
        
        _level = STARTING_LEVEL;
        [self setJunkToLevelUpForLevel];
    }
    return self;
}

- (int)junksRemainingToLevelUp
{
    return _junksToLevelUp - _junks;
}

- (void)addPoints:(int)points
{
    _points += points;
}

- (void)levelUp
{
    _level++;
    [self setJunkToLevelUpForLevel];
}

- (void)setJunkToLevelUpForLevel
{
    if ( _level == 1 )
        _junksToLevelUp = 30;
    else if ( _level == 2 )
        _junksToLevelUp = 60;
    else if ( _level == 3 )
        _junksToLevelUp = 90;
    else if ( _level == 4 )
        _junksToLevelUp = 130;
    else if ( _level == 5 )
        _junksToLevelUp = 180;
    else if ( _level == 6 )
        _junksToLevelUp = 240;
    else
        _junksToLevelUp = -1;
}

@end
