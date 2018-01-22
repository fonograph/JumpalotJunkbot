//
//  EnergyMeter.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-18.
//
//

#define CHANGE_SPEED 20

#import "EnergyMeter.h"
#import "Player.h"

@implementation EnergyMeter

- (id)init
{
    if ( self = [super init] )
    {
        self.contentSize = CGSizeMake([CCDirector sharedDirector].screenSize.width, 15);
        _alpha = 0.5;
        _percentage = 100;
    }
    return self;
}

- (void)setPercentage:(float)percentage
{
    // update contains all the gametime logic, this is actually just used by Help
    _percentage = percentage;
    _redness = _percentage <= 100 ? (_percentage-100)/-100 : 0;
}

- (void)update:(ccTime)delta
{
    if ( _player )
    {
        if ( abs(_percentage - _player.energyPercentage) <= CHANGE_SPEED * delta )
        {
            _percentage = _player.energyPercentage;
            _alpha = 0.5;
            _redness = _percentage <= 100 ? (_percentage-100)/-100 : 0;
        }
        else
        {
            _percentage += _player.energyPercentage > _percentage ? CHANGE_SPEED*delta : -CHANGE_SPEED*delta;
            _alpha = 1;
            _redness = _player.energyPercentage > _percentage ? 0 : 1;
        }
    }
}

- (void)draw
{
    [super draw];
    
    ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    ccColor4F color = ccc4f(1, 1-_redness, 1-_redness, _alpha);
    ccDrawSolidRect(ccp(0, 0), ccp(self.contentSize.width * _percentage/100, self.contentSize.height), color);
    
    ccGLBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}


@end
