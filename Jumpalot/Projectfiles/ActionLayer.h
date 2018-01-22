/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"

typedef enum {
    ForegroundZGravityAura,
    ForegroundZBlockHalo,
    ForegroundZBlock,
    ForegroundZJunkHalo,
    ForegroundZJunk,
    ForegroundZZoomer,
    ForegroundZBomb
} ForegroundZ;

@protocol ActionLayerDelegate <NSObject>

- (void)actionLayerDidCompleteLevelUp;
- (void)actionLayerBecameReadyForLaunch;

@end



@class Player, Background, BlockManager, PropAreasManager, PlayerParticleTrail, PlayerStreak, LaunchShip, Clouds, LevelUpEffect;

@interface ActionLayer : CCLayer
{
    CCNode *_rotationNodeBackground1;
    CCNode *_rotationNodeForeground;
    CCNode *_effectsNode;
    CCNode *_playerTrailNode;
    PlayerStreak *_playerStreak;
    Background *_background;
    CGFloat _zoom;
    
    CCNode *_batchNodesParticlesParent;
    NSMutableDictionary *_batchNodesParticles; // indexed on texture "name"
    
    CCSpriteBatchNode *_batchNodeForeground;
    CCSpriteBatchNode *_batchNodeBlocksOutline;
    CCSpriteBatchNode *_batchNodeBlocks;
    CCSpriteBatchNode *_batchNodeJunk;

    UITouch *_panningTouch;
    NSTimeInterval _touchStartTime;
    CGPoint _touchLastPt;
    
    CCLabelTTF *_startTapLabel;
    BOOL _waitingForTapToLaunch;
    
    CCLabelTTF *_boostTapLabel;
    BOOL _boostTapShowing;
    
    LevelUpEffect *_levelUp;
    
    CGFloat _screenDiagonalRadius;
    
    LaunchShip *_launchShip;
    BOOL _beforeLaunch;
    
    Clouds *_clouds;
    BOOL _waitingForCloudFadeIn;
}

@property (readonly) CGFloat viewAngle;
@property (readonly) CGFloat viewZoom;
@property (readonly) Player *player;
@property (readonly) PropAreasManager *propAreas;
@property (readonly) BOOL controlsActive;
@property (weak, nonatomic) id<ActionLayerDelegate> delegate;

+ (ActionLayer *)sharedActionLayer;

- (CGFloat)maxZoomOut;
- (CGFloat)maxVisibleRadius;
- (CGFloat)visibleRadius;

- (id)initWithBackground:(Background *)background;
- (void)beginWithIntro:(BOOL)doIntro;
- (void)onLaunchShipSequenceComplete;
- (void)update:(ccTime)delta;
- (void)addSpriteToForeground:(CCSprite *)sprite z:(ForegroundZ)z;
- (void)addJunkSprite:(CCSprite *)sprite;
- (void)addBlockSprite:(CCSprite *)sprite outline:(CCSprite *)outline;
- (void)addParticlesToForeground:(CCParticleSystem *)ps;
- (void)addNodeToEffectsNode:(CCNode *)node atScreenPosition:(CGPoint)pt;
- (void)addPlayerParticleTrail:(PlayerParticleTrail *)particle;
- (void)startPlayerStreakWithColor:(ccColor3B)color;
- (void)stopPlayerStreak;
- (void)onPlayerDying;
- (void)onPlayerDead;
- (void)levelUp;
- (void)onLevelUpStarted;
- (void)onLevelUpFinished;
- (void)toggleControls:(BOOL)toggle;
- (void)toggleBoostTap:(BOOL)toggle;

@end
