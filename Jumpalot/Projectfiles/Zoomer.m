//
//  Zoomer.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-17.
//
//

#import "Zoomer.h"
#import "ActionLayer.h"

@interface Zoomer()

- (void)reactivate;

@end

@implementation Zoomer


- (id)init
{
    if ( self = [super init] )
    {
        _ps = [CCParticleSystemQuad particleWithFile:@"zoomer.plist"];
        _ps.positionType = kCCPositionTypeGrouped;
        [[ActionLayer sharedActionLayer] addParticlesToForeground:_ps];
        
        _sprite = [CCSprite spriteWithSpriteFrameName:@"zoomer.png"];
        _sprite.opacity = 64;
        [[ActionLayer sharedActionLayer] addSpriteToForeground:_sprite z:ForegroundZZoomer];
        
        self.zoomerSize = CGSizeMake(120, 120);
        
        //[self scheduleUpdate];
    }
    return self;
}

- (void)updatePositionRelativeToTopContainer:(CGPoint)position
{
    _sprite.position = position;
    _ps.position = position;
}

- (void)setZoomerSize:(CGSize)zoomerSize
{
    _zoomerSize = zoomerSize;
    
    _sprite.scaleX = _zoomerSize.width / _sprite.contentSize.width * 0.8;
    _sprite.scaleY = _zoomerSize.height / _sprite.contentSize.height * 0.8;
    
    self.contentSize = CGSizeMake(_sprite.contentSize.width * _sprite.scaleX, _sprite.contentSize.height * _sprite.scaleY);
    
    _radius = _zoomerSize.width/2;
    
    _ps.posVar = ccp(_radius/sqrtf(1.75), _radius/sqrtf(1.75));
}


- (void)update:(ccTime)delta
{
    /*
    CGPoint globalPos = [self convertToWorldSpace:CGPointZero];
    CGRect globalRect = CGRectMake(globalPos.x-_radius, globalPos.y-_radius, _radius*2, _radius*2);
    BOOL inScreen = CGRectIntersectsRect([CCDirector sharedDirector].screenRect, globalRect);
    if ( inScreen && !_ps.parent )
    {
        [self addChild:_ps];
    }
    else if ( !inScreen && _ps.parent )
    {
        [self removeChild:_ps cleanup:NO];
    }
     */
}

- (void)onExit
{
    [super onExit];
    [super unscheduleUpdate];
    
    [_sprite removeFromParentAndCleanup:YES];
    [_ps removeFromParentAndCleanup:YES];
}

- (void)reset
{
    _active = YES;
    [_ps resetSystem];
}

- (void)hit
{
    _active = NO;
    [_ps stopSystem];
    
    [self scheduleOnce:@selector(reactivate) delay:1];
}

- (void)reactivate
{
    _active = YES;
    [_ps resetSystem];
}

- (void)updateAngleToPlayer:(CGFloat)angle
{
    _ps.angle = CC_RADIANS_TO_DEGREES(angle) + 180;
}


@end
