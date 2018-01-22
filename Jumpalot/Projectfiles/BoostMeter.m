//
//  BoostMeter.m
//  Jumpalot
//
//  Created by David Fono on 2012-12-30.
//
//

#import "BoostMeter.h"
#import "Player.h"

@implementation BoostMeter

- (id)init
{
    if ( self = [super init] )
    {
//        CCSprite *sprite = [CCSprite spriteWithFile:@"meter.png"];
//        
//        _display = [[CCProgressTimer alloc] initWithSprite:sprite];
//        _display.position = ccp(sprite.contentSize.width/2, sprite.contentSize.height/2);
//        
//        self.contentSize = sprite.contentSize;
//        
//        [self addChild:_display];
    }
    return self;
}

- (void)setPercentage:(float)percentage
{
    _display.percentage = percentage;
}

- (void)update:(ccTime)delta
{
    _display.percentage = _player.boostChargePercentage;
}

@end
