/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "ActionLayer.h"
#import "SimpleAudioEngine.h"
#import "Player.h"
#import "Background.h"
#import "PlayerParticleTrail.h"
#import "Block.h"
#import "PropAreasManager.h"
#import "PropArea.h"
#import "PropAreaGlobal.h"
#import "Junk.h"
#import "Zoomer.h"
#import "Bomb.h"
#import "Asteroid.h"
#import "CCShake.h"
#import "PlayerStreak.h"
#import "Score.h"
#import "GameScene.h"
#import "PlayerDriveConfig.h"
#import "LaunchShip.h"
#import "Clouds.h"
#import "MusicController.h"
#import "LevelUpEffect.h"

static ActionLayer *sharedActionLayer;

@interface ActionLayer ()

- (void)launchPlayer;
- (void)zoom:(float)targetZoom speed:(float)speed delta:(ccTime)delta;
- (void)scroll:(CGPoint)delta;
- (void)updateMovingPieces:(ccTime)delta;
- (void)applyGravityToPlayer:(ccTime)delta;
- (void)testPlayerBlockCollisions:(CGPoint)scrollDelta;
- (void)testPlayerJunkCollisions;
- (void)testPlayerZoomerCollisions;
- (void)testPlayerBombCollisions;
- (void)updateProps;
- (void)updateDynamicPropAreas;
- (void)removeBlocksFromPlayerPathAndOrientPlayerToBlocksOnPath;
- (void)levelUp;

@end

@implementation ActionLayer

+ (ActionLayer *)sharedActionLayer
{
    return sharedActionLayer;
}

- (CGFloat)maxZoomOut
{
    return _player.driveConfig.maxZoom;
}

- (CGFloat)maxVisibleRadius
{
    return 652 * self.maxZoomOut;
}

- (CGFloat)visibleRadius
{
    return _screenDiagonalRadius * _zoom;
}


- (id)initWithBackground:(Background *)background
{
	if ((self = [super init]))
	{        
        sharedActionLayer = self;
        
        self.touchEnabled = YES;
        
        CCDirector* director = [CCDirector sharedDirector];
        
        _screenDiagonalRadius = ccpLength(director.screenCenter);
        
        _rotationNodeBackground1 = [[CCNode alloc] init];
        _rotationNodeBackground1.position = director.screenCenter;
        [self addChild:_rotationNodeBackground1];
        
        _rotationNodeForeground = [[CCNode alloc] init];
        _rotationNodeForeground.position = director.screenCenter;
        [self addChild:_rotationNodeForeground];

        if ( background )
        {
            _background = background;
            [_background removeFromParent];
        }
        else
        {
            _background = [[Background alloc] init];
            [_background setBackgroundLevel:1];
        }
        _background.position = CGPointZero;
        [_rotationNodeBackground1 addChild:_background];
        
        _batchNodeForeground = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"objectSprites.pvr"] capacity:300];
        [_rotationNodeForeground addChild:_batchNodeForeground];
        
        _batchNodeBlocksOutline = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"paneloutlinetex.pvr"] capacity:200];
        _batchNodeBlocksOutline.blendFunc = ccBlendFuncMake(GL_SRC_ALPHA, GL_ONE);
        [_rotationNodeForeground addChild:_batchNodeBlocksOutline];
        
        _batchNodeBlocks = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"paneltex.pvr"] capacity:200];
        [_rotationNodeForeground addChild:_batchNodeBlocks];
        
        _batchNodeJunk = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"junkSprites.pvr.ccz"] capacity:200];
        [_rotationNodeForeground addChild:_batchNodeJunk];
        
        _batchNodesParticlesParent = [[CCNode alloc] init];
        [_rotationNodeForeground addChild:_batchNodesParticlesParent];
        
        _batchNodesParticles = [NSMutableDictionary dictionary];
        
        _player = [[Player alloc] init];
        _player.position = director.screenCenter;
        _player.scale = 1;
        [self addChild:_player z:999];        
        
        _launchShip = [[LaunchShip alloc] initWithPlayer:_player];
        _launchShip.position = director.screenCenter;
        [self addChild:_launchShip];
        
        _clouds = [[Clouds alloc] init];
        _clouds.position = director.screenCenter;
        [self addChild:_clouds];
        
        _propAreas = [[PropAreasManager alloc] initWithDynamic: [GameScene sharedGameScene].score.level==1 ];
        _propAreas.position = CGPointZero;
        [_rotationNodeForeground addChild:_propAreas];
        
        _effectsNode = [[CCNode alloc] init];
        _effectsNode.position = CGPointZero;
        [_rotationNodeForeground addChild:_effectsNode];
        
        _playerTrailNode = [[CCNode alloc] init];
        _playerTrailNode.position = CGPointZero;
        [_rotationNodeForeground addChild:_playerTrailNode];
        
        _playerStreak = [[PlayerStreak alloc] init];
        _playerStreak.position = CGPointZero;
        [_rotationNodeForeground addChild:_playerStreak];
        
        _viewAngle = 0;
        
        _zoom = 1;
        
        // extra stuff                
        _boostTapLabel = [CCLabelTTF labelWithString:@"TAP!" fontName:FONT_D3_ALPHABET fontSize:35];
        _boostTapLabel.position = ccpAdd(director.screenCenter, ccp(0, -100));
        _boostTapLabel.visible = NO;
        [self addChild:_boostTapLabel];
	}

	return self;
}

- (void)registerWithTouchDispatcher
{
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)onEnter
{
    [super onEnter];
}

- (void)onExit
{
    [super onExit];
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    sharedActionLayer = nil;
}

- (void)beginWithIntro:(BOOL)doIntro
{
    _player.visible = NO;
    _beforeLaunch = YES;

    if ( doIntro )
    {
        _waitingForCloudFadeIn = YES;
        [_clouds fadeIn:0.7 onComplete:^(){
            _background.scale = 1; // resets scale set in MainMenuScene
            _background.rotation = 0;
            _zoom = 8;
            [_clouds zoomClouds:6];
            [[SimpleAudioEngine sharedEngine] playEffect:@"launchWhoosh.caf"];
            _waitingForCloudFadeIn = NO;
        }];
    }
    else
    {
        _zoom = 1;
        [_launchShip skipScrollInAndStartSequence];
        [_clouds removeFromParentAndCleanup:YES];
    }
}

- (void)onLaunchShipSequenceComplete
{
    _waitingForTapToLaunch = YES;
    
    _startTapLabel = [CCLabelTTF labelWithString:@"TAP" fontName:FONT_D3_ALPHABET fontSize:35];
    _startTapLabel.position = ccpAdd([CCDirector sharedDirector].screenCenter, ccp(0, 100));
    [_startTapLabel runAction:[CCBlink actionWithDuration:10 blinks:20]];
    [self addChild:_startTapLabel];
    
    [_delegate actionLayerBecameReadyForLaunch];
}

- (void)launchPlayer
{
    [_launchShip hidePlayer];
    [_launchShip scrollOut];
    
    _player.visible = YES;
    [_player launchFromBase];
    
    _beforeLaunch = NO;
    _controlsActive = YES;
    
    [[MusicController sharedController] resume];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ( !_controlsActive )
        return YES;
    
    if ( !_panningTouch )
    {
        _touchLastPt = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
        _touchStartTime = [[NSDate date] timeIntervalSince1970];
        
        if ( _touchLastPt.y < CONTROL_AREA_HEIGHT )
            _panningTouch = touch;
    }
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ( !_controlsActive || _waitingForCloudFadeIn )
        return;
    
    if ( touch == _panningTouch )
    {
        CGPoint pt = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
        
        //CGFloat rotation = - (pt.x - _touchLastPt.x) * 0.56;
        CGFloat rotation = ccpLength(ccpSub(pt, _touchLastPt)) * 0.56;
        if ( pt.x - _touchLastPt.x > 0 ) rotation *= -1;
        
        _player.moveAngle += CC_DEGREES_TO_RADIANS(rotation);
        
        _viewAngle -= CC_DEGREES_TO_RADIANS(rotation);
        if ( _viewAngle < 0)
            _viewAngle += 2*M_PI;
        else if ( _viewAngle > 2*M_PI )
            _viewAngle -= 2*M_PI;
        
        _touchLastPt = pt;
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ( touch.tapCount > 0 && _waitingForTapToLaunch )
    {
        _waitingForTapToLaunch = NO;
        [_startTapLabel removeFromParentAndCleanup:YES];
        [self launchPlayer];
    }
    
    if ( !_controlsActive )
        return;
    
    if ( touch == _panningTouch )
    {
        _panningTouch = nil;
    }
    
    if ( touch.tapCount > 0 ) //if ( [[NSDate date] timeIntervalSince1970] - _touchStartTime < 0.1 )
    {
            CGPoint pt = [_rotationNodeForeground convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]]];
            // this point is relative to the player, in gameworld space
            // offset the point depending on player's velocity, try to guess where the player meant to go if they had tapped faster
            pt.x -= _player.velocity.x * 0.2;
            pt.y -= _player.velocity.y * 0.2;
            
            [_player boostAtAngle:ccpToAngle(pt)];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self ccTouchEnded:touch withEvent:event];
}

- (void)update:(ccTime)delta
{
    if ( _levelUp || _waitingForCloudFadeIn )
        return;

    _rotationNodeBackground1.rotation = -CC_RADIANS_TO_DEGREES(_viewAngle);
    _rotationNodeForeground.rotation = -CC_RADIANS_TO_DEGREES(_viewAngle);
    
    if ( !_beforeLaunch && !_waitingForTapToLaunch )
    {
        [_player update:delta];
        [self updateMovingPieces:delta];
    }
    
    // calculate desired zoom
    if ( _beforeLaunch )
    {
        [self zoom:1 speed:2 delta:delta];
        
        if ( _zoom == 1 && !_launchShip.started )
            [_launchShip scrollInAndStartSequence];
    }
    else
    {
        float zx = MIN((_player.moveSpeed-_player.minMoveSpeed)/(_player.maxMoveSpeed-_player.minMoveSpeed), 1);
        float zy = -1 * powf((1-zx), 2) + 1;
        float targetZoom = _player.driveConfig.minZoom + zy * (_player.driveConfig.maxZoom - _player.driveConfig.minZoom);
        [self zoom:targetZoom speed:2 delta:delta];
    }
    
    if ( _beforeLaunch || _waitingForTapToLaunch )
        return;
    
    // generate objects before scrolling so the sprites get placed
    [_propAreas generateGlobalProps:delta];
    [_propAreas cleanupGlobalProps];
    [self updateDynamicPropAreas];    

    // scroll
    CGPoint d = ccp(-_player.velocity.x * delta, -_player.velocity.y * delta);
    [self scroll:d];
    
    // make sure to test collisions immediately after scrolling, so we can reliably use the player's velocity to get their previous point
    [self removeBlocksFromPlayerPathAndOrientPlayerToBlocksOnPath];
    [self testPlayerBlockCollisions:d];
    [self testPlayerJunkCollisions];
    [self testPlayerZoomerCollisions];
    [self testPlayerBombCollisions];
    [self applyGravityToPlayer:delta];
    
    [self updateProps];
    
    [_background update:delta]; // visual bg update
        
    // remove faded effects
    for ( int i=_effectsNode.children.count-1; i>=0; i-- )
    {
        CCNode *node = [_effectsNode.children objectAtIndex:i];
        if ( [node isKindOfClass:[CCSprite class]] )
        {
            CCSprite *sprite = (CCSprite *)node;
            if ( sprite.opacity == 0 )
                [sprite removeFromParentAndCleanup:YES];
        }
    }
    for ( int i=_playerTrailNode.children.count-1; i>=0; i-- )
    {
        PlayerParticleTrail *trail = (PlayerParticleTrail *)[_playerTrailNode.children objectAtIndex:i];
        if ( [trail readyToRemove] )
        {
            [trail removeFromParentAndCleanup:YES];
            //NSLog(@"removed player trail");
        }
    }
    
    // show boost prompt
    if ( _player.driveConfig.level==1 && _player.moveSpeed < _player.minMoveSpeed*1.2 && _player.boostChargePercentage == 100 )
    {
        [self toggleBoostTap:YES];
    }
    else if ( _boostTapShowing )
    {
        [self toggleBoostTap:NO];
    }
}

- (void)updateMovingPieces:(ccTime)delta
{
    for ( Asteroid *asteroid in _propAreas.globalArea.asteroids )
    {
        [asteroid update:delta];
    }
}

- (void)zoom:(float)targetZoom speed:(float)speed delta:(ccTime)delta;
{
    if ( !_beforeLaunch )
        targetZoom = MIN(MAX(targetZoom, _player.driveConfig.minZoom), _player.driveConfig.maxZoom);
    
    if ( targetZoom > _zoom )
    {
        _zoom += speed * delta;
        _zoom = MIN(_zoom, targetZoom);
    }
    else if ( targetZoom < _zoom )
    {
        _zoom -= speed * delta;
        _zoom = MAX(_zoom, targetZoom);
    }
    
    _rotationNodeBackground1.scale = 1 / (1 + (_zoom-1)*0.25);
    _rotationNodeForeground.scale = 1 / _zoom;
    _player.scale = 1 / _zoom;
    
    _viewZoom = _zoom;
}

- (void)scroll:(CGPoint)delta
{
    [_background scrollBack:ccpMult(delta, 0.2)];
    [_background scrollFront:ccpMult(delta, 0.6)];
    [_propAreas scroll:delta];
    [_playerStreak scroll:delta];
    
    for ( CCNode *node in _effectsNode.children )
        node.position = ccpAdd(node.position, delta);
    
    for ( PlayerParticleTrail *particle in _playerTrailNode.children )
        [particle scroll:delta];
}

- (void)addSpriteToForeground:(CCSprite *)sprite z:(ForegroundZ)z
{
    sprite.texture = _batchNodeForeground.texture;
    [_batchNodeForeground addChild:sprite z:z];
}

- (void)addBlockSprite:(CCSprite *)sprite outline:(CCSprite *)outline
{
    sprite.texture = _batchNodeBlocks.texture;
    [_batchNodeBlocks addChild:sprite];
    
    outline.texture = _batchNodeBlocksOutline.texture;
    [_batchNodeBlocksOutline addChild:outline];
}

- (void)addJunkSprite:(CCSprite *)sprite
{
    sprite.texture = _batchNodeJunk.texture;
    [_batchNodeJunk addChild:sprite];
}

- (void)addParticlesToForeground:(CCParticleSystem *)ps
{
    NSNumber *textureName = [NSNumber numberWithInt:ps.texture.name];
    CCParticleBatchNode *batchNode = [_batchNodesParticles objectForKey:textureName];
    if ( !batchNode )
    {
        batchNode = [CCParticleBatchNode batchNodeWithTexture:ps.texture capacity:3000];
        [_batchNodesParticlesParent addChild:batchNode];
        [_batchNodesParticles setObject:batchNode forKey:textureName];
        //NSLog(@"particle batch node created");
    }
    [batchNode addChild:ps z:0 tag:0];
}

- (void)addNodeToEffectsNode:(CCNode *)node atScreenPosition:(CGPoint)pt
{
    node.position = [_effectsNode convertToNodeSpace:pt];
    [_effectsNode addChild:node];
}

- (void)addPlayerParticleTrail:(PlayerParticleTrail *)particle
{
    [_playerTrailNode addChild:particle];
}

- (void)startPlayerStreakWithColor:(ccColor3B)color
{
    [_playerStreak setColor:color];    
    [_playerStreak start];
}

- (void)stopPlayerStreak
{
    [_playerStreak stop];
}

- (void)onPlayerDying
{
    _controlsActive = NO;
    
    [[MusicController sharedController] stop];
}

- (void)onPlayerDead
{
    [[GameScene sharedGameScene] onPlayerDead];
}

- (void)toggleControls:(BOOL)toggle
{
    if ( toggle )
    {
        _controlsActive = YES;
    }
    else
    {
        _controlsActive = NO;
        _panningTouch = nil;
        _touchStartTime = 0;
        _touchLastPt = CGPointZero;
    }
}




#pragma mark Private

- (void)testPlayerJunkCollisions
{
    if ( ![_player canCollide] )
        return;
    
    CGPoint playerPos = _player.position;
    playerPos = [_propAreas convertToNodeSpace:playerPos];
    
    PropArea *area = [_propAreas areaWithPoint:playerPos];
    if ( area )
    {
        for ( Junk *junk in area.junks )
        {
            CGPoint junkPos = ccpAdd(area.position, junk.position);
            if ( !junk.collected && ccpDistance(junkPos, playerPos) <= junk.radius + _player.attractionRadius )
            {
                [_player collectJunk];
                [junk collect];
            }
        }
    }
}

- (void)testPlayerZoomerCollisions
{
    if ( ![_player canCollide] )
        return;
    
    CGPoint playerPos = _player.position;
    playerPos = [_propAreas convertToNodeSpace:playerPos];
    
    PropArea *area = [_propAreas areaWithPoint:playerPos];
    if ( area )
    {
        for ( Zoomer *zoomer in area.zoomers )
        {
            CGPoint zoomerPos = ccpAdd(area.position, zoomer.position);
            if ( ccpDistance(zoomerPos, playerPos) <= zoomer.radius && zoomer.active )
            {
                [_player zoom];
                [zoomer hit];
                break;
            }
        }
    }
}

- (void)testPlayerBombCollisions
{
    if ( ![_player canCollide] )
        return;
    
    CGPoint playerPos = _player.position;
    playerPos = [_propAreas convertToNodeSpace:playerPos];
    
    PropArea *area = [_propAreas areaWithPoint:playerPos];
    if ( area )
    {
        for ( Bomb *bomb in area.bombs )
        {
            CGPoint bombPos = ccpAdd(area.position, bomb.position);
            if ( !bomb.exploded && ccpDistance(bombPos, playerPos) <= bomb.radius )
            {
                CGFloat tangentAngle = ccpToAngle(ccpPerp(ccpSub(playerPos, bombPos)));
                
                [_player bounceOffBombAtAngle:tangentAngle];
                [bomb explode];
                
                [self runAction:[CCShake actionWithDuration:0.5 amplitude:ccp(20,20) dampening:true shakes:10]];
                
                break;
            }
        }
    }
}

- (void)testPlayerBlockCollisions:(CGPoint)scrollDelta
{
    if ( ![_player canCollide] )
        return;
    
    CGPoint playerPos = _player.position;
    playerPos = [_propAreas convertToNodeSpace:playerPos];
    
    CGPoint lastPlayerPos = ccpAdd(playerPos, scrollDelta);
    
    PropArea *area = [_propAreas areaWithPoint:playerPos];
    if ( area )
    {        
        for ( Block *block in area.blocks )
        {
            if ( block.charges == 0 )
                continue;
            
            CGPoint blockPos = ccpAdd(area.position, block.position);
            // is it close enough for a possible collision?
            if ( ccpDistance(blockPos, playerPos) <= block.haloRadius + _player.radius )
            {
                // do the full check
                CGPoint pt = ccpSub(playerPos, blockPos);
                pt = ccpRotateByAngle(pt, CGPointZero, -block.blockAngle);
                
                CGPoint lastPt = ccpSub(lastPlayerPos, blockPos);
                //lastPt = ccpMult(lastPt, 10); // move further out for better stability
                lastPt = ccpRotateByAngle(lastPt, CGPointZero, -block.blockAngle);
                
                CGFloat radiusW = block.radiusW + _player.radius;
                CGFloat radiusH = block.radiusH + _player.radius;
                
                CGFloat penTop = radiusH - pt.y;
                CGFloat penBottom = radiusH + pt.y;
                CGFloat penRight = radiusW - pt.x;
                CGFloat penLeft = radiusW + pt.x;
                
                if ( penTop >= 0 && penBottom >=0 && penLeft >= 0 && penRight >= 0 )
                {
                    CGFloat lastPlayerAngle = atan2f(lastPt.y, lastPt.x);
                    CGFloat blockDiagonal = atan2f(radiusH, radiusW);
                    
//CGFloat prevPlayerMoveAngle = _player.moveAngle;
//CGFloat hitAngle;
                    
                    if ( lastPlayerAngle >= blockDiagonal && lastPlayerAngle <= M_PI-blockDiagonal ) // top
                    //if ( penTop < penBottom && penTop < penLeft && penTop < penRight )
                    {
                        CGPoint scroll = ccpMult(ccpRotateByAngle(ccp(0, penTop), CGPointZero, block.blockAngle), -1);
                        [self scroll:scroll];
                        
                        [_player bounceOffBlock:block atAngle:block.blockAngle+M_PI_2];
                        [block hitAtAngle:M_PI_2];
//                        hitAngle = M_PI_2;
                    }
                    else if ( lastPlayerAngle <= -blockDiagonal && lastPlayerAngle >= -M_PI+blockDiagonal ) // bottom
                    //else if ( penBottom < penTop && penBottom < penLeft && penBottom < penRight )
                    {
                        CGPoint scroll = ccpMult(ccpRotateByAngle(ccp(0, -penBottom), CGPointZero, block.blockAngle), -1);
                        [self scroll:scroll];
                        
                        [_player bounceOffBlock:block atAngle:block.blockAngle-M_PI_2];
                        [block hitAtAngle:-M_PI_2];
//                        hitAngle = -M_PI_2;
                    }
                    else if ( lastPlayerAngle <= blockDiagonal && lastPlayerAngle >= -blockDiagonal ) // right
                    //else if ( penRight < penLeft && penRight < penTop && penRight < penBottom )
                    {
                        CGPoint scroll = ccpMult(ccpRotateByAngle(ccp(penRight, 0), CGPointZero, block.blockAngle), -1);
                        [self scroll:scroll];
                        
                        [_player bounceOffBlock:block atAngle:block.blockAngle];
                        [block hitAtAngle:0];
//                        hitAngle = 0;
                    }
                    else // left
                    //else if ( penLeft < penRight && penLeft < penTop && penLeft < penBottom )
                    {
                        CGPoint scroll = ccpMult(ccpRotateByAngle(ccp(-penLeft, 0), CGPointZero, block.blockAngle), -1);
                        [self scroll:scroll];
                        
                        [_player bounceOffBlock:block atAngle:block.blockAngle+M_PI];
                        [block hitAtAngle:M_PI];
//                        hitAngle = M_PI;
                    }
                    
//                    NSLog(@"%@, %f, %f, %f, %@, %@, %f, %f, %f", NSStringFromCGPoint(blockPos), block.blockAngle, radiusW, radiusH, NSStringFromCGPoint(lastPlayerPos), NSStringFromCGPoint(lastPt), CC_RADIANS_TO_DEGREES(prevPlayerMoveAngle), CC_RADIANS_TO_DEGREES(_player.moveAngle), CC_RADIANS_TO_DEGREES(hitAngle));
                    
                }
            }
        }
    }
//    NSLog(@"loop complete");
    
    for ( Asteroid *asteroid in _propAreas.globalArea.asteroids )
    {
        if ( asteroid.charges == 0 )
            continue;        
        
        CGPoint blockPos = asteroid.position;
        CGFloat dist = ccpDistance(blockPos, playerPos);
        if ( dist < asteroid.radius + _player.radius )
        {
            CGFloat pen = asteroid.radius + _player.radius - dist;
            CGFloat angleToBlock = ccpToAngle(ccpSub(blockPos, playerPos));
            
            [self scroll:ccp(cosf(angleToBlock)*pen, sinf(angleToBlock)*pen)];
            [_player bounceOffBlock:asteroid atAngle:angleToBlock+M_PI];
            [asteroid hit];
        }
    }
}

- (void)applyGravityToPlayer:(ccTime)delta
{
    if ( _player.state == PlayerStateDead )
        return;
    
    CGPoint playerPos = [_propAreas convertToNodeSpace:_player.position];
    
    for ( PropArea *area in _propAreas.areas )
    {
        for ( Block *block in area.blocks )
        {
            if ( block.repel && block.charges )
            {
                CGPoint blockPos = ccpAdd(area.position, block.position);
                CGFloat dist = ccpDistance(blockPos, playerPos);
                if ( dist <= block.repelRange )
                {
                    CGFloat angle = ccpToAngle(ccpSub(playerPos, blockPos));
                    CGFloat accel = block.repelForce / powf(dist, 0.5) * delta;
                    [_player accelerateAtAngle:angle accel:accel];
                }
            }
        }
        
        for ( Bomb *bomb in area.bombs )
        {
            if ( bomb.attract && !bomb.exploded )
            {
                CGPoint bombPos = ccpAdd(area.position, bomb.position);
                CGFloat dist = ccpDistance(bombPos, playerPos);
                if ( dist <= bomb.attractRange )
                {
                    CGFloat angle = ccpToAngle(ccpSub(bombPos, playerPos));
                    CGFloat accel = bomb.attractForce / powf(dist, 0.5) * delta;
                    [_player accelerateAtAngle:angle accel:accel];
                }

            }
        }
    }
}

- (void)updateProps
{
    // Update the physical positioning of prop components using the latest state of everything
    CGPoint playerPos = [_player convertToWorldSpace:CGPointZero];
    for ( PropArea *propArea in _propAreas.areas )
    {
        for ( Zoomer *zoomer in propArea.zoomers )
        {
            CGPoint playerPosRel = [zoomer convertToNodeSpace:playerPos];
            [zoomer updateAngleToPlayer:ccpToAngle(playerPosRel)];
        }
    }
}

- (void)updateDynamicPropAreas
{
    [_propAreas updateDynamicProps];
}

- (void)removeBlocksFromPlayerPathAndOrientPlayerToBlocksOnPath
{
    CGPoint playerPosInPropSpace = [_propAreas convertToNodeSpace:_player.position];
    CCNode *targetBlock = nil;
    CGFloat targetBlockDist = 9999999;
    for ( PropArea *area in _propAreas.areas )
    {
        for ( int i=area.blocks.count-1; i>=0; i-- )
        {
            Block *block = [area.blocks objectAtIndex:i];
            BOOL wasOnScreen = block.isOnScreen;
            if ( [block updateIsOnScreen] )
            {
                CGPoint blockPos = ccpAdd(area.position, block.position);
                CGPoint center = ccpSub(blockPos, playerPosInPropSpace);
                
                if ( fabsf(ccpToAngle(center)-_player.moveAngle) < M_PI_2 )
                {
                    CGFloat radiusW = block.radiusW + _player.radius;
                    CGFloat radiusH = block.radiusH + _player.radius;
                    
                    CGPoint tl = ccpRotateByAngle(ccp(center.x-radiusW, center.y+radiusH), center, block.blockAngle);
                    CGPoint tr = ccpRotateByAngle(ccp(center.x+radiusW, center.y+radiusH), center, block.blockAngle);
                    CGPoint bl = ccpRotateByAngle(ccp(center.x-radiusW, center.y-radiusH), center, block.blockAngle);
                    CGPoint br = ccpRotateByAngle(ccp(center.x+radiusW, center.y-radiusH), center, block.blockAngle);
                    
                    BOOL tlAbove = _player.velocity.y * tl.x - _player.velocity.x * tl.y > 0;
                    BOOL trAbove = _player.velocity.y * tr.x - _player.velocity.x * tr.y > 0;
                    BOOL blAbove = _player.velocity.y * bl.x - _player.velocity.x * bl.y > 0;
                    BOOL brAbove = _player.velocity.y * br.x - _player.velocity.x * br.y > 0;
                    
                    if ( !( (tlAbove && trAbove && blAbove && brAbove) || (!tlAbove && !trAbove && !blAbove && !brAbove) ) )
                    {
                        // IN PATH
                        if ( !wasOnScreen && !block.repel && !_propAreas.isDynamic && !(_zoom < _player.driveConfig.minZoom*1.1 ) )
                        {
                            [area removeBlock:block];
                        }
                        else
                        {
                            if ( ccpLength(center) < targetBlockDist && ccpLength(center) < MAX(radiusW,radiusH)+300 )
                            {
                                targetBlock = block;
                                targetBlockDist = ccpLength(center);
                            }
                        }
                    }
                }
            }
        }
    }
    
    // might want to orient to an asteroid
    for ( Asteroid *asteroid in _propAreas.globalArea.asteroids )
    {
        CGPoint center = ccpSub(asteroid.position, playerPosInPropSpace);
        CGFloat dist = ccpLength(center);
        CGFloat angleDiff = ccpToAngle(center)-_player.moveAngle;
        if ( angleDiff < -M_PI )
            angleDiff += 2*M_PI;
        if ( angleDiff > M_PI )
            angleDiff -= 2*M_PI;
        
        if ( fabsf(angleDiff) < M_PI_2 )
        {
            CGFloat passByDist = tanf(fabsf(angleDiff)) * dist;
            if ( passByDist < asteroid.radius && dist < targetBlockDist )
            {
                targetBlock = asteroid;
                targetBlockDist = dist;
            }
        }
    }
    
    _player.targetBlock = targetBlock;
}

- (void)levelUp
{
    [self toggleControls:NO];
    
    if ( [GameScene sharedGameScene].score.level == 2 )
        _propAreas.isDynamic = NO;
    
    _levelUp = [[LevelUpEffect alloc] initWithLevel:[GameScene sharedGameScene].score.level];
    [self addChild:_levelUp z:_player.zOrder-1];
}

- (void)onLevelUpStarted
{
    [_background setBackgroundLevel:[GameScene sharedGameScene].score.level];
    [_propAreas resetAndRepopulateAreas];
    _levelUp.canFinish = YES;
}

- (void)onLevelUpFinished
{
    [self toggleControls:YES];
    
    [self removeChild:_levelUp cleanup:YES];
    _levelUp = nil;
    
    [_delegate actionLayerDidCompleteLevelUp];
}

- (void)toggleBoostTap:(BOOL)toggle
{
    if ( toggle && !_boostTapShowing )
    {
        _boostTapShowing = YES;
        
        [_boostTapLabel runAction:[CCBlink actionWithDuration:1000 blinks:3000]];
    }
    else if ( !toggle && _boostTapShowing )
    {
        _boostTapShowing = NO;
        
        [_boostTapLabel stopAllActions];
        _boostTapLabel.visible = NO;
    }
}

@end
