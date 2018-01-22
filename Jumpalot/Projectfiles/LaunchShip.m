//
//  LaunchShip.m
//  Jumpalot
//
//  Created by David Fono on 2013-09-08.
//
//

#import "LaunchShip.h"
#import "ActionLayer.h"
#import "SimpleAudioEngine.h"
#import "Player.h"
#import "PlayerDriveConfig.h"

@implementation LaunchShip

- (id)initWithPlayer:(Player *)p
{
    if ( self = [super init] )
    {
        _spriteBack = [CCSprite spriteWithFile:@"launchBack.png"];
        _spriteFloor = [CCSprite spriteWithFile:@"launchFloor.png"];
        _spriteDoorLeft = [CCSprite spriteWithFile:@"launchDoorLeft.png"];
        _spriteDoorRight = [CCSprite spriteWithFile:@"launchDoorRight.png"];
        _spriteFrontTop = [CCSprite spriteWithFile:@"launchFrontTop.png"];
        _spriteFrontBottom = [CCSprite spriteWithFile:@"launchFrontBottom.png"];
        
        _spriteBack.anchorPoint = CGPointZero;
        _spriteFloor.anchorPoint = CGPointZero;
        _spriteDoorLeft.anchorPoint = CGPointZero;
        _spriteDoorRight.anchorPoint = CGPointZero;
        _spriteFrontTop.anchorPoint = CGPointZero;
        _spriteFrontBottom.anchorPoint = CGPointZero;
        
        _spritePlayer = [CCNode node];
        CCSprite *player = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerSprites.pvr"]];
        [player setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"player%d_sleep.png", p.driveConfig.level]]];
        CCSprite *shadow = [CCSprite spriteWithFile:@"launchShadow.png"];
        shadow.position = ccp(0, -23);
        [_spritePlayer addChild:shadow];
        [_spritePlayer addChild:player];
        
        _zzz = [CCArray array];
        
        
        CGPoint pos = ccp(-160, -284);
        _spriteBack.position = pos;
        _spriteFloor.position = ccpAdd(pos, ccp(0, -100));
        _spritePlayer.position = ccp(0, -100);
        _spriteDoorLeft.position = pos;
        _spriteDoorRight.position = pos;
        _spriteFrontBottom.position = pos;
        _spriteFrontTop.position = ccp(pos.x, pos.y + _spriteFrontBottom.contentSize.height);
        
        [self addChild:_spriteBack];
        [self addChild:_spriteFloor];
        [self addChild:_spriteDoorLeft];
        [self addChild:_spriteDoorRight];
        [self addChild:_spriteFrontTop];
        [self addChild:_spritePlayer];
        [self addChild:_spriteFrontBottom];
        
        self.visible = NO;
    }
    return self;
}

- (void)startSequence
{
    [_spriteDoorLeft runAction:[CCMoveBy actionWithDuration:2 position:ccp(-90, 0)]];
    [_spriteDoorRight runAction:[CCMoveBy actionWithDuration:2 position:ccp(90, 0)]];
    
    //sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"launchDoors.caf"];
    
    [_spriteFloor runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                                              two:[CCMoveBy actionWithDuration:2 position:ccp(0, 100)]]];
    [_spritePlayer runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                                               two:[CCMoveBy actionWithDuration:2 position:ccp(0, 100)]]];
    
    //sound
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                                      two:[CCCallFuncO actionWithTarget:[SimpleAudioEngine sharedEngine] selector:@selector(playEffect:) object:@"launchFloor.caf"]]];
    
    // ending
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:3]
                                      two:[CCCallFunc actionWithTarget:[ActionLayer sharedActionLayer] selector:@selector(onLaunchShipSequenceComplete)]]];
    
    
    [self scheduleUpdate];
    
    _started = YES;
}

- (void)hidePlayer
{
    _spritePlayer.visible = NO;
}

- (void)scrollInAndStartSequence
{
    self.visible = YES;
    self.position = ccpAdd(self.position, ccp(0, -425));
    [self runAction:[CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1.5 position:ccp(0, 425)] rate:3]];
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                                      two:[CCCallFunc actionWithTarget:self selector:@selector(startSequence)]]];
    
    _started = YES;
}

- (void)skipScrollInAndStartSequence
{
    self.visible = YES;
    [self startSequence];
    
    _started = YES;
}

- (void)scrollOut
{
    [self runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:0.75 position:ccp(0, -425)]
                                      two:[CCCallFunc actionWithTarget:self selector:@selector(remove)]]];
}

- (void)update:(ccTime)delta
{
    // ZZZs
    if ( _zzz.count == 0 || ((CCSprite *)[_zzz objectAtIndex:_zzz.count-1]).scale >= 0.33 )
    {
        CCSprite *z = [CCSprite spriteWithFile:@"launchZ.png"];
        z.scale = 0;
        z.position = ccp(17, 17);
        [_spritePlayer addChild:z];
        [_zzz addObject:z];
        
        [z runAction:[CCMoveBy actionWithDuration:4.2 position:ccp(20, 35)]];
        [z runAction:[CCSequence actions:
                      [CCScaleTo actionWithDuration:3 scale:1],
                      [CCFadeOut actionWithDuration:1.2],
                      [CCCallBlockN actionWithBlock:^(CCNode *node){
            [node removeFromParentAndCleanup:YES];
        }],
                      nil]];
         
    }
}

- (void)remove
{
    [self unscheduleUpdate];
    [self removeFromParentAndCleanup:YES];
}

@end
