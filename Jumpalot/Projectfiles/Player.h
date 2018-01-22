//
//  Player.h
//  Jumpalot
//
//  Created by David Fono on 12-08-29.
//
//

@class Block, PlayerParticleTrail, PlayerDriveConfig, PlayerSprite;

typedef enum {
    PlayerStateNormal,
    PlayerStateHyper,
    PlayerStateDying,
    PlayerStateDead
} PlayerState;

@interface Player : CCNode
{
    PlayerSprite *_sprite;
    CCSprite *_haloSprite;
    CCSprite *_haloBoostSprite;
    
    CGFloat _rotateTo; //sprite rotation units
    int _rotateDir; //1 or -1
    
    CGFloat _driftCountdown;    
    CGFloat _comboCountdown;
    
    CCParticleSystemQuad *_psBoostHalo;
    PlayerParticleTrail *_trailHyper;
    
    int _hyperSound;
}

@property (readonly, nonatomic) PlayerState state;
@property (readonly, nonatomic) PlayerDriveConfig *driveConfig;
@property (nonatomic) CGFloat moveSpeed;
@property (nonatomic) CGFloat moveAngle; // in prop space
@property (readonly, nonatomic) CGPoint velocity; // in prop space
@property (readonly, nonatomic) CGFloat radius;
@property (readonly, nonatomic) CGFloat attractionRadius;
@property (readonly, nonatomic) CGFloat boostChargePercentage;
@property (readonly, nonatomic) CGFloat energyPercentage;
@property (readonly, nonatomic) CGFloat maxMoveSpeed;
@property (readonly, nonatomic) CGFloat minMoveSpeed;
@property (strong, nonatomic) CCNode *targetBlock;

- (void)update:(ccTime)delta;
- (void)bounceOffBlock:(id)blockOrAsteroid atAngle:(CGFloat)angle;
- (void)bounceOffBombAtAngle:(CGFloat)angle;
- (void)collectJunk;
- (void)zoom;
- (void)boostAtAngle:(CGFloat)angle;
- (void)accelerateAtAngle:(CGFloat)angle accel:(CGFloat)accel;
- (void)launchFromBase;
- (BOOL)canCollide;

@end
