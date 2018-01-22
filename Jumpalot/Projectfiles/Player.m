//
//  Player.m
//  Jumpalot
//
//  Created by David Fono on 12-08-29.
//
//

//#define MAX_SPEED 600
//#define MIN_SPEED 200
//#define BOOST_SPEED 125
//#define DECEL_FROM_MAX_TIME 2
//#define HYPER_SPEED 1000
//#define HYPER_LENGTH 3

#define COMBO_TIME 1 //0.75
//#define SPEED_LEVEL_1_COLOR ccc3(188,255,188)
//#define SPEED_LEVEL_2_COLOR ccc3(255,255,188)
//#define SPEED_LEVEL_3_COLOR ccc3(255,188,188)
//#define SPEED_LEVEL_4_COLOR ccc3(255,188,255)
#define SPEED_LEVEL_1_COLOR ccc3(34,141,255)
#define SPEED_LEVEL_2_COLOR ccc3(182,255,100)
#define SPEED_LEVEL_3_COLOR ccc3(255,202,27)
#define SPEED_LEVEL_4_COLOR ccc3(255,0,146)

#define MIN_ATTRACTION_RADIUS 50
#define MAX_ATTRACTION_RADIUS 200
#define HYPER_ATTRACTION_RADIUS 300

#define BOOST_CHARGE_TIME 4


#define ENERGY_CHARGE_BLOCK 4

#define POINTS_BLOCK 5

#define BOMB_SLOWDOWN 50
#define BOMB_ENERGY_DRAIN 5

#import "Player.h"
#import "Block.h"
#import "ActionLayer.h"
#import "PlayerParticleTrail.h"
#import "GameScene.h"
#import "Score.h"
#import "SimpleAudioEngine.h"
#import "PlayerDriveConfig.h"
#import "PlayerSprite.h"
#import "Asteroid.h"

@interface Player()

- (void)startHyper;
- (void)endHyper;
- (void)startTrailWithColor:(ccColor3B)color duration:(ccTime)duration;
- (void)endTrail;
- (void)explodeAndDie;
- (void)generateComboEffectWithPreviousVelocity:(CGPoint)previousVelocity;

@end

@implementation Player

- (id)init
{
    if ( self = [super init] )
    {
        _driveConfig = [PlayerDriveConfig driveConfigWithLevel:[PlayerDriveConfig sharedLevelSetting]];
        
        _haloSprite = [[CCSprite alloc] initWithFile:@"circle.png"];
        _haloSprite.opacity = 32;
        [self addChild:_haloSprite];
        
        _haloBoostSprite = [[CCSprite alloc] initWithFile:@"circle.png"];
        _haloBoostSprite.opacity = 64;
        _haloBoostSprite.color = ccc3(128, 128, 255);
        [self addChild:_haloBoostSprite];
        
        _sprite = [[PlayerSprite alloc] initWithType:_driveConfig.level];
        _sprite.scale = 1.25;
        [self addChild:_sprite];
        
        _psBoostHalo = [CCParticleSystemQuad particleWithFile:@"boostHalo.plist"];
        _psBoostHalo.position = CGPointZero;
        _psBoostHalo.visible = NO;
        [self addChild:_psBoostHalo];
        [_psBoostHalo stopSystem];
                
        _radius = _sprite.contentSize.height/2;
        
        _state = PlayerStateNormal;
        
        _boostChargePercentage = 0;
        
        _velocity = ccp(0, 0);
        
        _attractionRadius = self.moveSpeed / _driveConfig.maxSpeed * MAX_ATTRACTION_RADIUS;
        _haloSprite.scale = _attractionRadius / (_haloSprite.contentSize.width/2);
        
        _driftCountdown = 0;
        _comboCountdown = 0;
        
        _energyPercentage = 100;
    }
    return self;
}

- (CGFloat)minMoveSpeed
{
    return _driveConfig.minSpeed;
}

- (CGFloat)maxMoveSpeed
{
    return _driveConfig.maxSpeed;
}

- (void)update:(ccTime)delta
{
    [_sprite update:delta];
    
    // sprite flip correction
    int screenMoveAngle = CC_RADIANS_TO_DEGREES([ActionLayer sharedActionLayer].viewAngle + self.moveAngle);
    if ( screenMoveAngle < 0 )
        screenMoveAngle += 360;
    else if ( screenMoveAngle >= 360 )
        screenMoveAngle -= 360;
    int rotation = -_sprite.rotation;
    int difference = (abs(screenMoveAngle-rotation)+180) % 360 - 180;
    _sprite.flipX = abs(difference) > 90;
    
    if ( _state == PlayerStateNormal )
    {
        // rotation
        if ( _rotateDir != 0 && ![_sprite hasTempState] )
        {
            _sprite.rotation += 500*delta * _rotateDir;
            if ( _sprite.rotation < 0 )
                _sprite.rotation += 360;
            else if ( _sprite.rotation >= 360 )
                _sprite.rotation -= 360;
            
            if ( abs(_sprite.rotation-_rotateTo) < 500*delta )
            {
                _rotateDir = 0;
                _sprite.state = PlayerSpriteStateLanding;
            }
        }
        
        // drain and charge
        _boostChargePercentage = 0; //MIN(_boostChargePercentage + 100 / BOOST_CHARGE_TIME * delta, 100);
        _energyPercentage = MAX(_energyPercentage - _driveConfig.energyDrainSpeed*delta, 0);
        _driveConfig.energyDrainSpeed += _driveConfig.energyDrainAccel * delta;
        
        // decelerate or drift
        float decel = (self.moveSpeed - _driveConfig.minSpeed) / _driveConfig.decelFactor;
        if ( _driftCountdown > 0 )
            _driftCountdown -= delta;
        else
            self.moveSpeed = MAX(self.moveSpeed - decel*delta, _driveConfig.minSpeed);
        
        // combo timer
        if ( _comboCountdown > 0)
            _comboCountdown -= delta;
        
        // halo management
        _attractionRadius = MIN_ATTRACTION_RADIUS + (self.moveSpeed - _driveConfig.minSpeed) / (_driveConfig.maxSpeed - _driveConfig.minSpeed) * (MAX_ATTRACTION_RADIUS-MIN_ATTRACTION_RADIUS);
        _haloSprite.scale = _attractionRadius / (_haloSprite.contentSize.width/2);
        _haloBoostSprite.scale = _boostChargePercentage/100 * _haloSprite.scale;
        
        // boost charge halo management
        if ( _boostChargePercentage == 100 && !_psBoostHalo.visible )
        {
            _psBoostHalo.visible = YES;
            [_psBoostHalo resetSystem];
        }
        else if ( _boostChargePercentage < 100 && _psBoostHalo.visible )
        {
            _psBoostHalo.visible = NO;
            [_psBoostHalo stopSystem];
        }
        
        if ( _psBoostHalo.visible )
        {
            _psBoostHalo.startRadius = _attractionRadius;
            _psBoostHalo.endRadius = _attractionRadius - 5;
//            _psBoostHalo.scale = _attractionRadius / _psBoostHalo.startRadius;            
        }
        
        // DEATH
        if ( _energyPercentage <= 0 )
        {
            _state = PlayerStateDying;
            
            [_sprite setTempState:PlayerSpriteStateDamage forLength:10];
            [_sprite runAction:[CCRotateBy actionWithDuration:1 angle:360]];
            
            [self runAction:[CCSequence actions:
                             [CCDelayTime actionWithDuration:1],
                             [CCCallFunc actionWithTarget:self selector:@selector(explodeAndDie)],
                             nil]];
            
            [[ActionLayer sharedActionLayer] onPlayerDying];
        }
    }
    else if ( _state == PlayerStateHyper )
    {
        // orient
        _sprite.rotation = -(screenMoveAngle-90);
        _sprite.flipX = NO;
    }
}

- (CGFloat)moveAngle
{
    return ccpToAngle(_velocity);
}

- (void)setMoveAngle:(CGFloat)moveAngle
{
    _velocity = ccpMult(ccpForAngle(moveAngle), self.moveSpeed);
}

- (CGFloat)moveSpeed
{
    return ccpLength(_velocity);
}

- (void)setMoveSpeed:(CGFloat)moveSpeed
{
    _velocity = ccpMult(ccpNormalize(_velocity), moveSpeed);
}

- (void)setTargetBlock:(CCNode *)targetBlock
{
    if ( _targetBlock != targetBlock )
    {
        _targetBlock = targetBlock;
        
        if ( _state == PlayerStateNormal )
        {
            // reorient
            if ( _targetBlock )
            {
                CGPoint blockPos = [self convertToNodeSpace:[_targetBlock convertToWorldSpace:CGPointZero]];
                CGFloat angleToBlock = ccpToAngle(blockPos);
                
                _rotateTo = -CC_RADIANS_TO_DEGREES(M_PI/2 + angleToBlock);
                if ( _rotateTo < 0 )
                    _rotateTo += 360;
                else if ( _rotateTo >= 360 )
                    _rotateTo -= 360;
                
                CGFloat diff = _rotateTo - _sprite.rotation;
                if ( diff > 180 )
                    diff -= 360;
                else if ( diff < -180 )
                    diff += 360;
                
                if ( diff > 0 )
                    _rotateDir = 1;
                else
                    _rotateDir = -1;
                
                if ( (_rotateDir == -1 && !_sprite.flipX) || (_rotateDir == 1 && _sprite.flipX) )
                    _sprite.state = PlayerSpriteStateFlipB;
                else
                    _sprite.state = PlayerSpriteStateFlipA;
                
                [_sprite clearTempState];
            }
            else
            {
                _sprite.state = PlayerSpriteStateJumping;
                _rotateDir = 0;
            }
        }
    }
}

- (void)bounceOffBlock:(id)blockOrAsteroid atAngle:(CGFloat)angle
{
    CGPoint previousVelocity = _velocity;
    
    //self.moveAngle = angle * 2 - self.moveAngle;
    CGPoint n = ccpForAngle(angle);
    _velocity = ccpAdd(ccpMult(n, -2 * ccpDot(_velocity, n)), _velocity);    
    
    float boostMultiplier = 1;
    if ( [blockOrAsteroid isKindOfClass:[Block class]] )
        boostMultiplier = [(Block *)blockOrAsteroid boostMultiplier];
    
    if ( _state == PlayerStateHyper )
    {
        // add energy
        _energyPercentage = MIN(_energyPercentage + ENERGY_CHARGE_BLOCK/5 * boostMultiplier, 100);
        
        // return to full speed after hitting a repel block
        if ( [blockOrAsteroid isKindOfClass:[Block class]] && [(Block *)blockOrAsteroid repel] )
            self.moveSpeed = _driveConfig.hyperSpeed;
    }
    else
    {
        // increase speed
        self.moveSpeed = MIN(self.moveSpeed + _driveConfig.boostSpeed * boostMultiplier, _driveConfig.maxSpeed);
        
        // add energy
        _energyPercentage = MIN(_energyPercentage + ENERGY_CHARGE_BLOCK * boostMultiplier, 100);
        if ( _comboCountdown > 0 )
            _energyPercentage = MIN(_energyPercentage + ENERGY_CHARGE_BLOCK/2, 100);        

        // handle combos and entering hyper
        if ( _comboCountdown > 0 )
        {
            if ( self.moveSpeed >= _driveConfig.maxSpeed - 1 ) //-1 epsilon
            {
                [self startHyper];
            }
            
            [self generateComboEffectWithPreviousVelocity:previousVelocity];
            [GameScene sharedGameScene].score.combos++;
        }

        // do stuff if hyper didn't happen
        if ( _state != PlayerStateHyper )
        {
            [self startTrailWithColor:ccc3(255, 255, 255) duration:COMBO_TIME];
            _comboCountdown = COMBO_TIME;
            _driftCountdown = 0.25;
        }
    }
    
    [[GameScene sharedGameScene].score addPoints:POINTS_BLOCK];
    
    Float32 pitch = 1 + (self.moveSpeed-_driveConfig.minSpeed)/(_driveConfig.maxSpeed-_driveConfig.minSpeed)*0.75;
    [[SimpleAudioEngine sharedEngine] playEffect:@"chime.caf" pitch:pitch pan:0.0f gain:0.7f];
    [[SimpleAudioEngine sharedEngine] playEffect:@"bounce.caf" pitch:1.0f pan:0.0f gain:0.5f];
}

- (void)bounceOffBombAtAngle:(CGFloat)angle
{
    self.moveAngle = ( angle * 2 - self.moveAngle ) + CC_DEGREES_TO_RADIANS( -80 + arc4random()%160 ); //2nd term is a random effect
    self.moveSpeed = MAX(self.moveSpeed - BOMB_SLOWDOWN, _driveConfig.minSpeed);
    _energyPercentage = MAX(self.energyPercentage - BOMB_ENERGY_DRAIN, 0);
    
    [_sprite setTempState:PlayerSpriteStateDamage forLength:1];

}

- (void)collectJunk
{
    _driftCountdown += 0.25;
    //self.moveSpeed = MIN(self.moveSpeed + BOOST_SPEED_MINOR, MAX_SPEED-1);
}

- (void)zoom
{
    self.moveSpeed = MIN(self.moveSpeed + _driveConfig.boostSpeed, _driveConfig.maxSpeed - 1);
    _driftCountdown = 0.5;
    
    PlayerParticleTrail *p = [[PlayerParticleTrail alloc] initWithParticleSystem:[CCParticleSystemQuad particleWithFile:@"zoomerStart.plist"]];
    [[ActionLayer sharedActionLayer] addPlayerParticleTrail:p];
    
    [self startTrailWithColor:ccc3(128, 255, 128) duration:0.5];
    
    _comboCountdown = 0;
    
    int screenMoveAngle = CC_RADIANS_TO_DEGREES([ActionLayer sharedActionLayer].viewAngle + self.moveAngle);
    [_sprite setTempState:PlayerSpriteStateHyper forLength:0.5];
    _sprite.rotation = -(screenMoveAngle-90);
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"boost.caf" pitch:1.0f pan:0.0f gain:0.7f];
}

- (void)boostAtAngle:(CGFloat)angle
{
    if ( _boostChargePercentage < 100 )
        return;
    
    self.moveAngle = angle;
    self.moveSpeed = MIN(self.moveSpeed + _driveConfig.boostSpeed, _driveConfig.maxSpeed - 1);
    
    _boostChargePercentage = 0;
    _comboCountdown = 0;
    
    int screenMoveAngle = CC_RADIANS_TO_DEGREES([ActionLayer sharedActionLayer].viewAngle + self.moveAngle);
    [_sprite setTempState:PlayerSpriteStateHyper forLength:0.5];
    _sprite.rotation = -(screenMoveAngle-90);
    
    PlayerParticleTrail *p = [[PlayerParticleTrail alloc] initWithParticleSystem:[CCParticleSystemQuad particleWithFile:@"boostStart.plist"]];    
    [[ActionLayer sharedActionLayer] addPlayerParticleTrail:p];
    
    [self startTrailWithColor:ccc3(180, 180, 255) duration:0.5];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"boost.caf" pitch:1 pan:0 gain:1];
}

- (void)accelerateAtAngle:(CGFloat)angle accel:(CGFloat)accel
{
    CGPoint point = ccpMult(ccpForAngle(angle), accel);
    
    _velocity.x += point.x;
    _velocity.y += point.y;
}

- (void)launchFromBase
{
    _velocity = ccp(0, (_driveConfig.minSpeed + _driveConfig.maxSpeed)/2);
    _driftCountdown = 0.75;
    
    CCParticleSystem *ps = [CCParticleSystemQuad particleWithFile:@"hyperStart.plist"];
    PlayerParticleTrail *p = [[PlayerParticleTrail alloc] initWithParticleSystem:ps];
    [[ActionLayer sharedActionLayer] addPlayerParticleTrail:p];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"boost.caf" pitch:1.0f pan:0.0f gain:0.7f];
}

- (BOOL)canCollide
{
    return _state == PlayerStateNormal || _state == PlayerStateHyper;
}


- (void)startHyper
{
    _state = PlayerStateHyper;
    _sprite.state = PlayerSpriteStateHyper;
    
    self.moveSpeed = _driveConfig.hyperSpeed;
    _attractionRadius = HYPER_ATTRACTION_RADIUS;
    
    _comboCountdown = 0;
    _driftCountdown = 0;
    
    [self scheduleOnce:@selector(endHyper) delay:_driveConfig.hyperLength];
    
    _trailHyper = [[PlayerParticleTrail alloc] initWithParticleSystem:[CCParticleSystemQuad particleWithFile:@"hyperTrail.plist"]];
    [[ActionLayer sharedActionLayer] addPlayerParticleTrail:_trailHyper];
    
    CCParticleSystem *ps = [CCParticleSystemQuad particleWithFile:@"hyperStart.plist"];
    PlayerParticleTrail *p = [[PlayerParticleTrail alloc] initWithParticleSystem:ps];
    [[ActionLayer sharedActionLayer] addPlayerParticleTrail:p];
    
    [self startTrailWithColor:ccc3(255, 128, 128) duration:_driveConfig.hyperLength];
    
    _hyperSound = [[SimpleAudioEngine sharedEngine] playEffect:@"hyper.caf" pitch:1.0f pan:0.0f gain:0.7f];
    
    [GameScene sharedGameScene].score.hypers++;
}

- (void)endHyper
{
    _state = PlayerStateNormal;
    _sprite.state = PlayerSpriteStateJumping;
    
    self.moveSpeed = _driveConfig.maxSpeed * 0.7;
    
    [_trailHyper stop];
    _trailHyper = nil;
    
    [[SimpleAudioEngine sharedEngine] stopEffect:_hyperSound];
}

- (void)startTrailWithColor:(ccColor3B)color duration:(ccTime)duration
{
    [[ActionLayer sharedActionLayer] startPlayerStreakWithColor:color];
    [self unschedule:@selector(endTrail)];
    [self scheduleOnce:@selector(endTrail) delay:duration];
}

- (void)endTrail
{
    [[ActionLayer sharedActionLayer] stopPlayerStreak];
}

- (void)explodeAndDie
{
    _state = PlayerStateDead;
    
    self.moveSpeed = 0;
    
    CCParticleSystemQuad *explosion = [CCParticleSystemQuad particleWithFile:@"deathExplosion.plist"];
    explosion.position = CGPointZero;
    explosion.positionType = kCCPositionTypeGrouped;
    explosion.autoRemoveOnFinish = YES;
    [self addChild:explosion];
    
    [_sprite removeFromParentAndCleanup:YES];
    [_haloSprite removeFromParentAndCleanup:YES];
    [_haloBoostSprite removeFromParentAndCleanup:YES];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"bomb.caf" pitch:1.0f pan:0.0f gain:0.7f];
    
    [[ActionLayer sharedActionLayer] onPlayerDead];
}

- (void)generateComboEffectWithPreviousVelocity:(CGPoint)previousVelocity
{
    CGFloat angle = ccpToAngle(ccpMult(ccpAdd(ccpNeg(previousVelocity), _velocity), 0.5));
    angle = ( (int)CC_RADIANS_TO_DEGREES(angle) + 360 ) % 360;
    
    CGPoint regPoint = ccp(0, 0.5);
    
    CGFloat totalAngle = ( (int)angle + (int)CC_RADIANS_TO_DEGREES([ActionLayer sharedActionLayer].viewAngle) ) % 360;
    if ( totalAngle > 90 && totalAngle < 270 )
    {
        angle += 180;
        regPoint = ccp(1, 0.5);
    }
    
    NSString *comboText;
    ccColor3B comboColor;
    
    if ( self.moveSpeed >= _driveConfig.hyperSpeed - 1 ) //-1 epsilon
    {
        comboText = @"HYPER";
        comboColor = SPEED_LEVEL_4_COLOR;
    }
    else if ( self.moveSpeed >= _driveConfig.ultraSpeed )
    {
        comboText = @"ULTRA";
        comboColor = SPEED_LEVEL_3_COLOR;
    }
    else if ( self.moveSpeed >= _driveConfig.megaSpeed )
    {
        comboText = @"MEGA";
        comboColor = SPEED_LEVEL_2_COLOR;
    }
    else 
    {
        comboText = @"SUPER";
        comboColor = SPEED_LEVEL_1_COLOR;
    }
    
    comboColor = ccc3((comboColor.r+255)/2, (comboColor.g+255)/2, (comboColor.b+255)/2);
    
    CCLabelTTF *comboLabel = [CCLabelTTF labelWithString:comboText fontName:FONT_D3_ALPHABET fontSize:40];
    comboLabel.anchorPoint = regPoint;
    comboLabel.rotation = -angle;
    comboLabel.color = comboColor;
    
    [comboLabel runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.25],
                           [CCFadeTo actionWithDuration:0.5 opacity:0],
                           nil]];
    
    [[ActionLayer sharedActionLayer] addNodeToEffectsNode:comboLabel atScreenPosition:[self convertToWorldSpace:CGPointZero]];
}

@end
